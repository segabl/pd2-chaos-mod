if not ChaosMod then

	ChaosMod = {}
	ChaosMod.mod_instance = ModInstance
	ChaosMod.mod_path = ModPath
	ChaosMod.required = {}
	ChaosMod.modifiers = {} ---@type table<string, ChaosModifier>
	ChaosMod.active_modifiers = {} ---@type table<string, ChaosModifier>
	ChaosMod.hud_modifiers = {} ---@type HUDChaosModifier[]
	ChaosMod.queued_calls = {}
	ChaosMod.paused_t = 0
	ChaosMod.next_modifier_t = 0
	ChaosMod.cooldown_mul = 1
	ChaosMod.settings = {
		min_cooldown = 20,
		max_cooldown = 30,
		prevent_repeat = 0.5,
		max_active = 5,
		stealth_enabled = 1,
		panel_x = 1,
		panel_y = 0.45,
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
			local modifier = blt.vm.dofile(path .. file)
			if type(modifier) == "table" then
				if modifier.enabled then
					self.modifiers[modifier.class_name] = modifier
				end
			else
				log("[Chaos Mod] " .. path .. file .. " did not return a modifier")
			end
		end
	end

	function ChaosMod:can_modifier_trigger(modifier, skip_trigger_check)
		if self.settings.disabled_modifiers[modifier.class_name] then
			return false, false
		end

		for _, active_modifier in pairs(self.active_modifiers) do
			if active_modifier:conflicts_with(modifier) then
				return false, false
			end
		end

		if not skip_trigger_check and not modifier:can_trigger() then
			return false, true
		end

		if managers.groupai:state():enemy_weapons_hot() then
			return true, true
		end

		if modifier.loud_only then
			return false, true
		end

		return self.settings.stealth_enabled == 3 or self.settings.stealth_enabled == 2 and modifier.stealth_safe, true
	end

	function ChaosMod:activate_modifier(name, seed, skip_trigger_check)
		if not Utils:IsInHeist() then
			return
		end

		local modifier_class
		if name then
			modifier_class = self.modifiers[name]
			if not modifier_class or not skip_trigger_check and not modifier_class:can_trigger() then
				log("[Chaos Mod] " .. (modifier_class and "Modifier " .. name .. " can't trigger" or "Modifier " .. name .. " does not exist"))
				return
			end
		elseif skip_trigger_check or table.size(self.active_modifiers) < math.round(self.settings.max_active) then
			local selector = WeightedSelector:new()
			local update_weight_modifiers = {}
			for _, modifier in pairs(self.modifiers) do
				local can_trigger, update_weight = self:can_modifier_trigger(modifier, skip_trigger_check)
				if can_trigger then
					selector:add(modifier, modifier.weight * modifier.weight_mul)
				end
				if update_weight then
					table.insert(update_weight_modifiers, modifier)
				end
			end

			modifier_class = selector:select()
			if not modifier_class then
				return
			end

			local new_weight = modifier_class.weight * math.map_range_clamped(self.settings.prevent_repeat, 0, 1, 1, 0)
			local to_add = (modifier_class.weight - new_weight) / (#update_weight_modifiers - 1)
			for _, modifier in pairs(update_weight_modifiers) do
				modifier.weight = modifier == modifier_class and new_weight or modifier.weight + to_add
			end
		else
			return
		end

		for _, active_modifier in pairs(self.active_modifiers) do
			if active_modifier:conflicts_with(modifier_class) then
				active_modifier:destroy()
			end
		end

		local modifier = modifier_class:new(seed)
		self.active_modifiers[modifier_class.class_name] = modifier
		table.insert(self.hud_modifiers, modifier._hud_modifier)

		return true
	end

	function ChaosMod:complete_modifier(name, peer_id)
		for _, modifier in pairs(self.active_modifiers) do
			if modifier.class_name == name then
				modifier:complete(peer_id)
			end
		end
	end

	function ChaosMod:stop_modifier(name)
		for _, modifier in pairs(self.active_modifiers) do
			if modifier.class_name == name then
				modifier._expired = true
			end
		end
	end

	function ChaosMod:time()
		return TimerManager:main():time() - self.paused_t
	end

	function ChaosMod:delta_time()
		return TimerManager:main():delta_time()
	end

	function ChaosMod:update()
		if self._paused_t then
			self.paused_t = self.paused_t + TimerManager:main():time() - self._paused_t
			self._paused_t = nil
		end

		local t = self:time()
		local dt = self:delta_time()

		if Network:is_server() then
			if not Utils:IsInHeist() or self.settings.stealth_enabled == 1 and not managers.groupai:state():enemy_weapons_hot() then
				self.next_modifier_t = t + math.rand(5, 10)
			elseif self.next_modifier_t < t then
				if self:activate_modifier() then
					self.next_modifier_t = t + math.rand(self.settings.min_cooldown, self.settings.max_cooldown) * self.cooldown_mul
				else
					self.next_modifier_t = t + 1
				end
			end
		end

		for k, modifier in pairs(self.active_modifiers) do
			if modifier:expired(t, dt) then
				modifier:destroy()
				self.active_modifiers[k] = nil
			elseif Network:is_server() or modifier.run_as_client then
				modifier:update(t, dt)
			end
		end

		for i, hud_modifier in table.reverse_ipairs(self.hud_modifiers) do
			if hud_modifier:expired(t, dt) then
				hud_modifier:destroy()
				table.remove(self.hud_modifiers, i)
			else
				hud_modifier:update(t, dt, i)
			end
		end

		for k, v in pairs(self.queued_calls) do
			if t >= v.t then
				v.func()
				if self.queued_calls[k] == v then
					self.queued_calls[k] = nil
				end
			end
		end
	end

	function ChaosMod:paused_update()
		if not self._paused_t then
			self._paused_t = TimerManager:main():time()
		end
	end

	function ChaosMod:stop_all_modifiers()
		for k, modifier in pairs(self.active_modifiers) do
			modifier:destroy()
			self.active_modifiers[k] = nil
		end
	end

	function ChaosMod:queue(id, time, func)
		self.queued_calls[id] = {
			t = self:time() + time,
			func = func
		}
	end

	function ChaosMod:unqueue(id)
		self.queued_calls[id] = nil
	end

	function ChaosMod:anim_over(duration, func)
		func = func or function() end
		func(0)
		local start_t = self:time()
		while true do
			coroutine.yield()
			local t = self:time()
			if t >= start_t + duration then
				break
			else
				func((t - start_t) / duration)
			end
		end
		func(1)
	end

	---@return Panel
	function ChaosMod:panel(can_be_hidden)
		if not self._ws then
			self._ws = managers.gui_data:create_fullscreen_workspace()
		end
		return can_be_hidden and managers.hud:panel(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) or self._ws:panel()
	end

	---@return Gui
	function ChaosMod:world_gui()
		if not self._world_gui then
			self._world_gui = World:newgui()
		end
		return self._world_gui
	end

	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInitChaosMod", function(loc)
		if HopLib then
			HopLib:load_localization(ChaosMod.mod_path .. "loc/", loc)
		else
			loc:load_localization_file(ChaosMod.mod_path .. "loc/english.txt")
		end
	end)

	Hooks:Add("GameSetupUpdate", "GameSetupUpdateChaosMod", function(t, dt)
		ChaosMod:update()
	end)

	Hooks:Add("GameSetupPausedUpdate", "GameSetupPausedUpdateChaosMod", function(t, dt)
		ChaosMod:paused_update()
	end)

	if Network:is_client() then
		NetworkHelper:AddReceiveHook("ActivateChaosModifier", "ActivateChaosModifier", function(data, sender)
			if sender == 1 then
				local class_name, seed = unpack(data:split("|"))
				ChaosMod:activate_modifier(class_name, tonumber(seed), true)
			end
		end)

		NetworkHelper:AddReceiveHook("StopChaosModifier", "StopChaosModifier", function(data, sender)
			if sender == 1 then
				ChaosMod:stop_modifier(data)
			end
		end)
	end

	NetworkHelper:AddReceiveHook("CompleteChaosModifier", "CompleteChaosModifier", function(data, sender)
		ChaosMod:complete_modifier(data, sender)
	end)

	Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusChaosMod", function(_, nodes)

		local slider_min_cooldown, slider_max_cooldown
		local modifier_toggles = {}
		local menu_id = "chaos_mod"
		local panel_menu_id = "chaos_mod_panel"
		local modifiers_menu_ids = {}

		MenuHelper:NewMenu(menu_id)
		MenuHelper:NewMenu(panel_menu_id)

		function MenuCallbackHandler:chaos_mod_value(item)
			local item_name, item_value = item:name(), item:value()
			ChaosMod.settings[item_name] = item_value
			if item_name == "min_cooldown" and item_value > slider_max_cooldown:value() then
				slider_max_cooldown:set_value(slider_min_cooldown:value())
			elseif item_name == "max_cooldown" and item_value < slider_min_cooldown:value() then
				slider_min_cooldown:set_value(slider_max_cooldown:value())
			end
		end

		function MenuCallbackHandler:chaos_mod_modifier_toggle(item)
			ChaosMod.settings.disabled_modifiers[item:name()] = item:value() == "off" or nil
		end

		function MenuCallbackHandler:chaos_mod_toggle_all(item)
			local value = item:name() == "enable_all" and "on" or "off"
			for _, toggle in pairs(modifier_toggles) do
				toggle:set_value(value)
				self:chaos_mod_modifier_toggle(toggle)
			end
			managers.system_menu:show({
				title = managers.localization:text("dialog_information_title"),
				text = managers.localization:text(value == "on" and "menu_chaos_mod_enable_all_dialog" or "menu_chaos_mod_disable_all_dialog"),
				button_list = {
					{ text = managers.localization:text("dialog_ok") }
				}
			})
		end

		function MenuCallbackHandler:chaos_mod_save()
			ChaosMod:save_settings()
		end

		slider_min_cooldown = MenuHelper:AddSlider({
			menu_id = menu_id,
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
			priority = 90
		})

		slider_max_cooldown = MenuHelper:AddSlider({
			menu_id = menu_id,
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
			priority = 80
		})

		MenuHelper:AddSlider({
			menu_id = menu_id,
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
			priority = 70
		})

		MenuHelper:AddSlider({
			menu_id = menu_id,
			id = "max_active",
			title = "menu_chaos_mod_max_active",
			desc = "menu_chaos_mod_max_active_desc",
			value = ChaosMod.settings.max_active,
			min = 1,
			max = 10,
			step = 1,
			show_value = true,
			display_precision = 0,
			callback = "chaos_mod_value",
			priority = 60
		})

		MenuHelper:AddMultipleChoice({
			menu_id = menu_id,
			id = "stealth_enabled",
			title = "menu_chaos_mod_stealth_enabled",
			desc = "menu_chaos_mod_stealth_enabled_desc",
			value = ChaosMod.settings.stealth_enabled,
			items = { "menu_chaos_mod_all_off", "menu_chaos_mod_stealth_on", "menu_chaos_mod_all_on" },
			callback = "chaos_mod_value",
			priority = 50
		})

		MenuHelper:AddDivider({
			menu_id = menu_id,
			size = 8,
			priority = 40
		})

		MenuHelper:AddButton({
			menu_id = menu_id,
			id = "panel",
			title = "menu_chaos_mod_panel",
			desc = "menu_chaos_mod_panel_desc",
			next_node = panel_menu_id,
			priority = 30
		})

		MenuHelper:AddSlider({
			menu_id = panel_menu_id,
			id = "panel_x",
			title = "menu_chaos_mod_panel_x",
			desc = "menu_chaos_mod_panel_x_desc",
			value = ChaosMod.settings.panel_x,
			min = 0,
			max = 1,
			step = 0.05,
			show_value = true,
			is_percentage = true,
			display_precision = 0,
			display_scale = 100,
			callback = "chaos_mod_value",
			priority = 90
		})

		MenuHelper:AddSlider({
			menu_id = panel_menu_id,
			id = "panel_y",
			title = "menu_chaos_mod_panel_y",
			desc = "menu_chaos_mod_panel_y_desc",
			value = ChaosMod.settings.panel_y,
			min = 0,
			max = 1,
			step = 0.05,
			show_value = true,
			is_percentage = true,
			display_precision = 0,
			display_scale = 100,
			callback = "chaos_mod_value",
			priority = 80
		})

		MenuHelper:AddDivider({
			menu_id = menu_id,
			size = 8,
			priority = 20
		})

		local modifiers_per_menu = 23
		local sorted_modifiers = table.map_keys(ChaosMod.modifiers, function(a, b)
			local loc_a = managers.localization:text(a):gsub("%p", "")
			local loc_b = managers.localization:text(b):gsub("%p", "")
			return loc_a:lower() > loc_b:lower()
		end)
		local num_pages = math.ceil(#sorted_modifiers / modifiers_per_menu)
		modifiers_per_menu = math.ceil(#sorted_modifiers / num_pages)

		local num_modifiers = 0
		local page_num = 1
		local from_letter, to_letter
		while #sorted_modifiers > 0 do
			local modifiers_menu_id = "chaos_mod_modifiers_" .. page_num

			if num_modifiers == 0 then
				MenuHelper:NewMenu(modifiers_menu_id)
				table.insert(modifiers_menu_ids, modifiers_menu_id)
			end

			if num_modifiers < modifiers_per_menu then
				local modifier = table.remove(sorted_modifiers)

				if num_modifiers == 0 then
					from_letter = utf8.sub(managers.localization:text(modifier):gsub("%p", ""), 1, 1)
				end
				to_letter = utf8.sub(managers.localization:text(modifier):gsub("%p", ""), 1, 1)

				table.insert(modifier_toggles, MenuHelper:AddToggle({
					menu_id = modifiers_menu_id,
					id = modifier,
					title = modifier,
					value = not ChaosMod.settings.disabled_modifiers[modifier],
					callback = "chaos_mod_modifier_toggle",
					priority = -num_modifiers
				}))

				num_modifiers = num_modifiers + 1
			end

			if num_modifiers >= modifiers_per_menu or #sorted_modifiers == 0 then
				MenuHelper:AddButton({
					menu_id = menu_id,
					id = "modifiers_" .. page_num,
					title = managers.localization:text("menu_chaos_mod_modifiers", { FROM = from_letter:upper(), TO = to_letter:upper() }),
					desc = managers.localization:text("menu_chaos_mod_modifiers_desc"),
					localized = false,
					next_node = modifiers_menu_id,
					priority = -page_num
				})
				num_modifiers = 0
				page_num = page_num + 1
			end
		end

		MenuHelper:AddDivider({
			menu_id = menu_id,
			size = 8,
			priority = -100
		})

		MenuHelper:AddButton({
			menu_id = menu_id,
			id = "enable_all",
			title = "menu_chaos_mod_enable_all",
			desc = "menu_chaos_mod_enable_all_desc",
			callback = "chaos_mod_toggle_all",
			priority = -110
		})

		MenuHelper:AddButton({
			menu_id = menu_id,
			id = "disable_all",
			title = "menu_chaos_mod_disable_all",
			desc = "menu_chaos_mod_disable_all_desc",
			callback = "chaos_mod_toggle_all",
			priority = -120
		})

		nodes[menu_id] = MenuHelper:BuildMenu(menu_id, { back_callback = "chaos_mod_save" })
		nodes[panel_menu_id] = MenuHelper:BuildMenu(panel_menu_id, { back_callback = "chaos_mod_save" })
		for _, modifiers_menu_id in pairs(modifiers_menu_ids) do
			nodes[modifiers_menu_id] = MenuHelper:BuildMenu(modifiers_menu_id, { back_callback = "chaos_mod_save" })
		end

		MenuHelper:AddMenuItem(nodes.blt_options, menu_id, "menu_chaos_mod")
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
