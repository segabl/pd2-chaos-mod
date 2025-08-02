ChaosModifierSlowDrills = ChaosModifier.class("ChaosModifierSlowDrills")

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
		end
	end
end

return ChaosModifierSlowDrills
