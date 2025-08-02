ChaosModifierJamDrills = ChaosModifier.class("ChaosModifierJamDrills")
ChaosModifierJamDrills.run_as_client = false

function ChaosModifierJamDrills:can_trigger()
	for _, unit in pairs(TimerGui.active_units) do
		if alive(unit) and unit:timer_gui()._can_jam and not unit:timer_gui()._jammed then
			return true
		end
	end
end

function ChaosModifierJamDrills:start()
	for _, unit in pairs(TimerGui.active_units) do
		if alive(unit) and unit:timer_gui()._can_jam and not unit:timer_gui()._jammed then
			unit:timer_gui():set_jammed(true)
		end
	end
end

return ChaosModifierJamDrills
