ChaosModifierSlowDrills = ChaosModifier.class("ChaosModifierSlowDrills")
ChaosModifierSlowDrills.activation_sound = "drill_end"

function ChaosModifierSlowDrills:can_trigger()
	for _, unit in pairs(TimerGui.active_units) do
		if alive(unit) then
			return true
		end
	end
end

function ChaosModifierSlowDrills:start()
	for _, unit in pairs(TimerGui.active_units) do
		if alive(unit) then
			local timer_gui = unit:timer_gui()
			timer_gui._chaos_multiplier = timer_gui._chaos_multiplier and timer_gui._chaos_multiplier * 0.5 or 0.5
			local add_time = timer_gui._timer * timer_gui._chaos_multiplier
			timer_gui._timer = timer_gui._timer + add_time
			timer_gui._current_timer = timer_gui._current_timer + add_time
			if timer_gui._jamming_intervals then
				local add_interval = add_time / #timer_gui._jamming_intervals / 2
				for i, time in ipairs(timer_gui._jamming_intervals) do
					timer_gui._jamming_intervals[i] = time + add_interval
				end
			end
			self:time_popup(unit, add_time * timer_gui:get_timer_multiplier())
		end
	end
end

function ChaosModifierSlowDrills:time_popup(unit, seconds)
	local pos = unit:position()
	local base = unit:base() or {}
	local texture, texture_rect = tweak_data.hud_icons:get_icon_data(base.is_drill and "wp_drill" or base.is_saw and "wp_saw" or "wp_hack")
	local panel = ChaosMod:panel(true):panel()
	local bitmap = panel:bitmap({
		texture = texture,
		texture_rect = texture_rect,
		color = HUDChaosModifier.colors.instant,
		w = 24,
		h = 24
	})
	local text = panel:text({
		text = string.format("+%us", math.ceil(seconds)),
		font = tweak_data.menu.pd2_large_font,
		font_size = 24,
		color = HUDChaosModifier.colors.instant
	})
	text:set_shape(text:text_rect())
	text:set_x(bitmap:right())
	text:set_center_y(bitmap:center_y())
	panel:set_size(text:right(), bitmap:bottom())
	panel:animate(function(o)
		over(5, function(t)
			local cam = managers.viewport:get_current_camera()
			if not alive(cam) then
				return
			end
			local screen_pos = managers.hud._workspace:world_to_screen(cam, pos)
			o:set_center(screen_pos.x, screen_pos.y - 50 * t ^ 0.5)
			o:set_alpha(math.map_range_clamped(t, 0.5, 1, 1, 0))
			o:set_visible(screen_pos.z > 0)
		end)
		o:parent():remove(o)
	end)
end

return ChaosModifierSlowDrills
