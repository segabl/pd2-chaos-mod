ChaosModifierBreakVehicles = ChaosModifier.class("ChaosModifierBreakVehicles")
ChaosModifierBreakVehicles.run_as_client = false
ChaosModifierBreakVehicles.disabled_levels = {
	deep = true,
	pbr = true,
	pex = true,
	vit = true
}

function ChaosModifierBreakVehicles:can_trigger()
	return not self.disabled_levels[Global.game_settings.level_id] and #managers.vehicle:get_all_vehicles() > 0
end

function ChaosModifierBreakVehicles:start()
	for _, v in pairs(managers.vehicle:get_all_vehicles()) do
		v:character_damage():damage_mission(v:character_damage()._current_max_health)
	end
end

return ChaosModifierBreakVehicles
