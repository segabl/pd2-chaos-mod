---@class ChaosModifierExplodingEnemies : ChaosModifier
ChaosModifierExplodingEnemies = class(ChaosModifier)
ChaosModifierExplodingEnemies.class_name = "ChaosModifierExplodingEnemies"
ChaosModifierExplodingEnemies.duration = 30
ChaosModifierExplodingEnemies.run_as_client = true

function ChaosModifierExplodingEnemies:start()
	Hooks:PostHook(CopDamage, "_on_death", self.class_name, function(copdamage)
		local pos = copdamage._unit:movement():m_com()
		local range = 500
		managers.explosion:give_local_player_dmg(pos, range, 50)
		managers.explosion:play_sound_and_effects(pos, math.UP, range, {
			effect = "effects/payday2/particles/explosions/grenade_explosion",
			sound_event = "grenade_explode",
			camera_shake_max_mul = 4,
			sound_muffle_effect = true,
			feedback_range = range * 2
		})
	end)
end

function ChaosModifierExplodingEnemies:stop()
	Hooks:RemovePostHook(self.class_name)
end

return ChaosModifierExplodingEnemies
