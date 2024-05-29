ChaosModifierBreakVehicles = ChaosModifier.class("ChaosModifierBreakVehicles")

function ChaosModifierBreakVehicles:can_trigger()
	return #managers.vehicle:get_all_vehicles() > 0
end

function ChaosModifierBreakVehicles:start()
	for _, v in pairs(managers.vehicle:get_all_vehicles()) do
		v:character_damage():damage_mission(v:character_damage()._current_max_health)
	end
end

return ChaosModifierBreakVehicles
