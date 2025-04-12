ChaosModifierTeleportingEnemies = ChaosModifier.class("ChaosModifierTeleportingEnemies")
ChaosModifierTeleportingEnemies.stealth_safe = false
ChaosModifierTeleportingEnemies.duration = 45

function ChaosModifierTeleportingEnemies:start()
	self:pre_hook(CopLogicTravel, "upd_advance", function(data)
		if data.internal_data.warp_pos or not data.unit:movement():team().foes.criminal1 then
			return
		end

		local warp_pos
		if data.internal_data.coarse_path then
			warp_pos = CopLogicTravel._get_exact_move_pos(data, #data.internal_data.coarse_path)
		end

		if warp_pos and mvector3.distance_sq(warp_pos, data.m_pos) > 100 ^ 2 then
			data.objective.pos = warp_pos
			data.internal_data.warp_pos = warp_pos
		end
	end)

	local function spawn_effect(action, action_desc, common_data)
		if not common_data.unit:movement():team().foes.criminal1 then
			return
		end

		World:effect_manager():spawn({
			effect = Idstring("effects/particles/explosions/explosion_flash_grenade"),
			position = common_data.unit:movement():m_pos(),
			rotation = Rotation()
		})
	end

	self:pre_hook(CopActionWarp, "init", spawn_effect)
	self:post_hook(CopActionWarp, "init", spawn_effect)
end

return ChaosModifierTeleportingEnemies
