if not ChaosMod then

	ChaosMod = {}
	ChaosMod.mod_instance = ModInstance
	ChaosMod.mod_path = ModPath
	ChaosMod.required = {}
	ChaosMod.modifiers = {} ---@type table<string, ChaosModifier>
	ChaosMod.active_modifiers = {} ---@type table<string, ChaosModifier>
	ChaosMod.hud_modifiers = {} ---@type HUDChaosModifier[]
	ChaosMod.next_modifier_t = 0
	ChaosMod.max_active = 6
	ChaosMod.settings = {
		min_cooldown = 20,
		max_cooldown = 30,
		prevent_repeat = 0.25,
		disabled_modifiers = {}
	}

	dofile(ChaosMod.mod_path .. "req/ChaosModifier.lua")
	dofile(ChaosMod.mod_path .. "req/HUDChaosModifier.lua")

	function ChaosMod:load_settings()
		if io.file_is_readable(SavePath .. "ChaosMod.json") then
			local data = io.load_as_json(SavePath .. "ChaosMod.json")
			for k, v in pairs(data) do
				if type(self.settings[k]) == type(v) then
					self.settings[k] = v
				end
			end
		end
	end

	function ChaosMod:save_settings()
		io.save_as_json(self.settings, SavePath .. "ChaosMod.json")
	end

	function ChaosMod:load_modifiers(path)
		path = path or self.mod_path .. "req/modifiers/"
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
		elseif table.size(self.active_modifiers) < self.max_active then
			local selector = WeightedSelector:new()
			for class_name, modifier in pairs(self.modifiers) do
				local register_name = modifier.register_name or class_name
				if not self.settings.disabled_modifiers[class_name] and not self.active_modifiers[register_name] and (skip_trigger_check or modifier:can_trigger()) then
					selector:add(modifier, modifier.weight)
				end
			end

			modifier_class = selector:select()
			if not modifier_class then
				return
			end

			local new_weight = modifier_class.weight * math.map_range_clamped(self.settings.prevent_repeat, 0, 1, 1, 0)
			local to_add = (modifier_class.weight - new_weight) / (table.size(self.modifiers) - 1)
			for _, modifier in pairs(self.modifiers) do
				modifier.weight = modifier == modifier_class and new_weight or modifier.weight + to_add
			end
		else
			return
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
					self.next_modifier_t = t + math.rand(self.settings.min_cooldown, self.settings.max_cooldown)
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

	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInitChaosMod", function(loc)
		if HopLib then
			HopLib:load_localization(ChaosMod.mod_path .. "loc/", loc)
		else
			loc:load_localization_file(ChaosMod.mod_path .. "loc/english.txt")
		end
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

	Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusChaosMod", function(_, nodes)

		local slider_min_cooldown, slider_max_cooldowwn

		MenuHelper:NewMenu("chaos_mod")

		function MenuCallbackHandler:chaos_mod_value(item)
			ChaosMod.settings[item:name()] = item:value()
			if item:name() == "min_cooldown" and item:value() > slider_max_cooldowwn:value() then
				slider_max_cooldowwn:set_value(slider_min_cooldown:value())
			elseif item:name() == "max_cooldown" and item:value() < slider_min_cooldown:value() then
				slider_min_cooldown:set_value(slider_max_cooldowwn:value())
			end
		end

		function MenuCallbackHandler:chaos_mod_modifier_toggle(item)
			ChaosMod.settings.disabled_modifiers[item:name()] = item:value() == "off" or nil
		end

		function MenuCallbackHandler:chaos_mod_save()
			ChaosMod:save_settings()
		end

		slider_min_cooldown = MenuHelper:AddSlider({
			menu_id = "chaos_mod",
			id = "min_cooldown",
			title = "menu_chaos_mod_min_cooldown",
			desc = "menu_chaos_mod_min_cooldown_desc",
			value = ChaosMod.settings.min_cooldown,
			min = 10,
			max = 90,
			step = 1,
			show_value = true,
			display_precision = 0,
			callback = "chaos_mod_value",
			priority = 4
		})

		slider_max_cooldowwn = MenuHelper:AddSlider({
			menu_id = "chaos_mod",
			id = "max_cooldown",
			title = "menu_chaos_mod_max_cooldown",
			desc = "menu_chaos_mod_max_cooldown_desc",
			value = ChaosMod.settings.max_cooldown,
			min = 10,
			max = 90,
			step = 1,
			show_value = true,
			display_precision = 0,
			callback = "chaos_mod_value",
			priority = 3
		})

		MenuHelper:AddSlider({
			menu_id = "chaos_mod",
			id = "prevent_repeat",
			title = "menu_chaos_mod_prevent_repeat",
			desc = "menu_chaos_mod_prevent_repeat_desc",
			value = ChaosMod.settings.prevent_repeat,
			min = 0,
			max = 1,
			step = 0.05,
			show_value = true,
			is_percentage = true,
			display_precision = 0,
			display_scale = 100,
			callback = "chaos_mod_value",
			priority = 2
		})

		MenuHelper:AddDivider({
			menu_id = "chaos_mod",
			size = 16,
			priority = 1
		})

		for modifier_name in pairs(ChaosMod.modifiers) do
			MenuHelper:AddToggle({
				menu_id = "chaos_mod",
				id = modifier_name,
				title = modifier_name,
				value = not ChaosMod.settings.disabled_modifiers[modifier_name],
				callback = "chaos_mod_modifier_toggle"
			})
		end

		nodes.chaos_mod = MenuHelper:BuildMenu("chaos_mod", { back_callback = "chaos_mod_save" })
		MenuHelper:AddMenuItem(nodes.blt_options, "chaos_mod", "menu_chaos_mod")
	end)

	ChaosMod:load_modifiers()
	ChaosMod:load_settings()

end

if RequiredScript and not ChaosMod.required[RequiredScript] then

	local fname = ChaosMod.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(fname) then
		dofile(fname)
	end

	ChaosMod.required[RequiredScript] = true

end
