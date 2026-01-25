ChaosModifierMeleeKnockback = ChaosModifier.class("ChaosModifierMeleeKnockback")
ChaosModifierMeleeKnockback.tags = { "EnemyMelee" }
ChaosModifierMeleeKnockback.conflict_tags = { "EnemyMelee" }
ChaosModifierMeleeKnockback.loud_only = true
ChaosModifierMeleeKnockback.duration = 60

function ChaosModifierMeleeKnockback:start()
	self:override(CopBrain._logic_variants.security, "attack", TankCopLogicAttack)
	self:override(CopLogicAttack, "_find_flank_pos", CopLogicAttack._find_pos_close_to_tracker)
	self:pre_hook(PlayerDamage, "damage_melee", function(playerdamage, data)
		if data.push_vel then
			mvector3.multiply(data.push_vel, 10)
			mvector3.set_z(data.push_vel, data.push_vel.z + 1)
		end
		playerdamage._unit:sound():play("hit_oil_drum")
	end)
end

return ChaosModifierMeleeKnockback
