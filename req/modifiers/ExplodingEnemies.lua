ChaosModifierExplodingEnemies = ChaosModifier.class("ChaosModifierExplodingEnemies")
ChaosModifierExplodingEnemies.run_as_client = false
ChaosModifierExplodingEnemies.stealth_safe = false
ChaosModifierExplodingEnemies.duration = 30

function ChaosModifierExplodingEnemies:start()
	self:post_hook(CopDamage, "_on_death", function(copdamage)
		local pos = copdamage._unit:movement():m_com()
		local range = 500
		local damage = math.min(copdamage._HEALTH_INIT / 4, 50)
		local normal = math.UP
		local curve_pow = 0.5
		DelayedCalls:Add(self.class_name .. tostring(copdamage._unit:key()), 0.1, function()
			managers.explosion:play_sound_and_effects(pos, normal, range)
			managers.explosion:detect_and_give_dmg({
				player_damage = damage,
				hit_pos = pos,
				range = range,
				collision_slotmask = managers.slot:get_mask("explosion_targets"),
				curve_pow = curve_pow,
				damage = damage / 2
			})
			managers.network:session():send_to_peers_synched("sync_explosion_to_client", copdamage._unit, pos, normal, damage, range, curve_pow)
		end)
	end)
end

return ChaosModifierExplodingEnemies
