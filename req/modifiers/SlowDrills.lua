ChaosModifierSlowDrills = ChaosModifier.class("ChaosModifierSlowDrills")

function ChaosModifierSlowDrills:can_trigger()
	return table.size(TimerGui.active_units) > 0
end

function ChaosModifierSlowDrills:start()
	for _, unit in pairs(TimerGui.active_units) do
		if alive(unit) then
			local timer_gui = unit:timer_gui()
			timer_gui._chaos_multiplier = timer_gui._chaos_multiplier and timer_gui._chaos_multiplier * 0.5 or 0.5
			local mul = 1 + timer_gui._chaos_multiplier
			timer_gui._timer = timer_gui._timer * mul
			timer_gui._current_timer = timer_gui._current_timer * mul
			timer_gui._current_jam_timer = timer_gui and timer_gui._current_jam_timer * mul or timer_gui._current_jam_timer
			if timer_gui._jamming_intervals then
				for i, time in pairs(timer_gui._jamming_intervals) do
					timer_gui._jamming_intervals[i] = time * mul
				end
			end
		end
	end
end

return ChaosModifierSlowDrills
