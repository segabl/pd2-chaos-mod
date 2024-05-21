if not ChaosMod then

	ChaosMod = {}
	ChaosMod.mod_path = ModPath
	ChaosMod.modifiers = {} ---@type table<string, ChaosModifier>
	ChaosMod.active_modifiers = {} ---@type table<string, ChaosModifier>
	ChaosMod.hud_modifiers = {} ---@type HUDChaosModifier[]
	ChaosMod.next_modifier_t = 0
	ChaosMod.cooldown_mul = 1

	dofile(ChaosMod.mod_path .. "req/ChaosModifier.lua")
	dofile(ChaosMod.mod_path .. "req/HUDChaosModifier.lua")

	function ChaosMod:load_modifiers()
		local path = self.mod_path .. "req/modifiers/"
		for _, file in pairs(file.GetFiles(path)) do
			local modifier = blt.vm.dofile(path .. file) ---@type ChaosModifier
			if type(modifier) == "table" then
				self.modifiers[modifier.class_name] = modifier
			else
				log(path .. file .. " did not return a modifier")
			end
		end
	end

	function ChaosMod:activate_modifier(name, seed, skip_trigger_check)
		local modifier_class
		if name then
			modifier_class = self.modifiers[name]
			if not modifier_class or not skip_trigger_check and not modifier_class:can_trigger() then
				log(modifier_class and "Modifier " .. name .. " can't trigger" or "Modifier " .. name .. " does not exist")
				return
			end
		else
			local available = {} ---@type ChaosModifier[]
			for _, modifier in pairs(self.modifiers) do
				local register_name = modifier.register_name or modifier.class_name
				if not self.active_modifiers[register_name] and (skip_trigger_check or modifier:can_trigger()) then
					table.insert(available, modifier)
				end
			end

			modifier_class = table.random(available)
			if not modifier_class then
				log("No modifiers that can be triggered are available")
				return
			end
		end

		local register_name = modifier_class.register_name or modifier_class.class_name
		local existing_modifier = self.active_modifiers[register_name]
		if existing_modifier then
			existing_modifier:destroy()
		end

		local modifier = modifier_class:new(seed)
		self.active_modifiers[register_name] = modifier

		table.insert(self.hud_modifiers, HUDChaosModifier:new(modifier))

		managers.hud:post_event("Play_star_hit")

		return true
	end

	function ChaosMod:update_modifiers(t, dt)
		if Network:is_server() then
			if not Utils:IsInHeist() or not managers.groupai:state():enemy_weapons_hot() then
				self.next_modifier_t = t + math.rand(5, 10)
			elseif self.next_modifier_t < t then
				if self:activate_modifier() then
					self.next_modifier_t = t + math.rand(20, 30) * self.cooldown_mul
				else
					self.next_modifier_t = t + 1
				end
			end
		end

		for k, modifier in pairs(self.active_modifiers) do
			if modifier:expired(t) then
				modifier:destroy()
				self.active_modifiers[k] = nil
			elseif Network:is_server() or modifier.run_as_client then
				modifier:update(t, dt)
			end
		end
	end

	function ChaosMod:update_modifiers_hud(t, dt)
		for i, hud_modifier in table.reverse_ipairs(self.hud_modifiers) do
			if hud_modifier:expired(t) then
				hud_modifier:destroy()
				table.remove(self.hud_modifiers, i)
			else
				hud_modifier:update(t, dt, i)
			end
		end
	end

	function ChaosMod:stop_all_modifiers()
		for k, modifier in pairs(self.active_modifiers) do
			modifier:destroy()
			self.active_modifiers[k] = nil
		end
	end

	function ChaosMod:enable_mutator(mutator_class)
		local mutator = managers.mutators:get_mutator(mutator_class)
		if mutator and not managers.mutators:is_mutator_active(mutator_class) then
			mutator:set_enabled(true)
			table.insert(managers.mutators:active_mutators(), { mutator = mutator })
		end
		return mutator
	end

	function ChaosMod:disable_mutator(mutator_class)
		for i, v in pairs(managers.mutators:active_mutators()) do
			if v.mutator:id() == mutator_class._type then
				v.mutator:set_enabled(false)
				table.remove(managers.mutators:active_mutators(), i)
				break
			end
		end
	end

	ChaosMod:load_modifiers()

	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInitChaosMod", function(loc)
		HopLib:load_localization(ChaosMod.mod_path .. "loc/", loc)
	end)

	Hooks:Add("GameSetupUpdate", "GameSetupUpdateChaosMod", function(t, dt)
		ChaosMod:update_modifiers(t, dt)
		ChaosMod:update_modifiers_hud(t, dt)
	end)

	if Network:is_client() then
		NetworkHelper:AddReceiveHook("ActivateChaosModifier", "ActivateChaosModifier", function(data)
			local class_name, seed = unpack(data:split("|"))
			ChaosMod:activate_modifier(class_name, tonumber(seed), true)
		end)
	end
end

HopLib:run_required(ChaosMod.mod_path .. "lua/")
