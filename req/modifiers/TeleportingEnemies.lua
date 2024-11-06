ChaosModifierTeleportingEnemies = ChaosModifier.class("ChaosModifierTeleportingEnemies")
ChaosModifierTeleportingEnemies.stealth_safe = false
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
	end)

	local function spawn_effect(action, action_desc, common_data)
		if not common_data.unit:in_slot(managers.slot:get_mask("enemies")) then
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
