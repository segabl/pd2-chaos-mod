ChaosModifierTeleportingEnemies = ChaosModifier.class("ChaosModifierTeleportingEnemies")
ChaosModifierTeleportingEnemies.run_in_stealth = false
ChaosModifierTeleportingEnemies.run_as_client = false
ChaosModifierTeleportingEnemies.duration = 30

function ChaosModifierTeleportingEnemies:start()
	self:pre_hook(CopLogicTravel, "upd_advance", function(data)
		if data.internal_data.warp_pos or not data.unit:in_slot(managers.slot:get_mask("enemies")) then
			return
		end

		if not data.objective.pos and data.internal_data.coarse_path then
			data.objective.pos = CopLogicTravel._get_exact_move_pos(data, #data.internal_data.coarse_path)
		end

		data.internal_data.warp_pos = data.objective.pos

		if data.internal_data.warp_pos and (not data.teleport_start_effect_t or data.teleport_start_effect_t + 5 < data.t) then
			data.teleport_start_effect_t = data.t
			World:effect_manager():spawn({
				effect = Idstring("effects/particles/explosions/explosion_flash_grenade"),
				position = data.m_pos,
				rotation = Rotation()
			})
		end
	end)

	self:pre_hook(CopLogicTravel, "_on_destination_reached", function(data)
		if data.teleport_start_effect_t and (not data.teleport_stop_effect_t or data.teleport_stop_effect_t + 5 < data.t) then
			data.teleport_stop_effect_t = data.t
			World:effect_manager():spawn({
				effect = Idstring("effects/particles/explosions/explosion_flash_grenade"),
				position = data.m_pos,
				rotation = Rotation()
			})
		end
	end)
end

return ChaosModifierTeleportingEnemies
