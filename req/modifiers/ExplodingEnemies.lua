ChaosModifierExplodingEnemies = ChaosModifier.class("ChaosModifierExplodingEnemies")
ChaosModifierExplodingEnemies.stealth_safe = false
ChaosModifierExplodingEnemies.duration = 30

function ChaosModifierExplodingEnemies:start()
	self:post_hook(CopDamage, "_on_death", function(copdamage)
		local pos = copdamage._unit:movement():m_com()
		local range = 500
		local damage = math.min(copdamage._HEALTH_INIT / 4, 50)
		local normal = math.UP
		DelayedCalls:Add(self.class_name .. tostring(copdamage._unit:key()), 0.1, function()
			managers.explosion:give_local_player_dmg(pos, range, damage)
			managers.explosion:play_sound_and_effects(pos, normal, range, {
				effect = "effects/payday2/particles/explosions/grenade_explosion",
				sound_event = "grenade_explode",
				camera_shake_max_mul = 4,
				sound_muffle_effect = true,
				feedback_range = range * 2
			})
			if Network:is_server() then
				managers.explosion:detect_and_give_dmg({
					player_damage = 0,
					hit_pos = pos,
					range = range,
					collision_slotmask = managers.slot:get_mask("explosion_targets"),
					curve_pow = 0.5,
					damage = damage / 2
				})
			else
				managers.explosion:client_damage_and_push(pos, normal, nil, damage / 2, range, 0.5)
			end
		end)
	end)
end

return ChaosModifierExplodingEnemies
