ChaosModifierMeleeKnockback = ChaosModifier.class("ChaosModifierMeleeKnockback")
ChaosModifierMeleeKnockback.loud_only = true
ChaosModifierMeleeKnockback.duration = 60

function ChaosModifierMeleeKnockback:start()
	self:override(CopBrain._logic_variants.security, "attack", TankCopLogicAttack)
	self:override(CopLogicAttack, "_find_flank_pos", function(data, _, flank_tracker)
		local field_pos = flank_tracker:field_position()
		local pos = Vector3(0, 0, 0)
		mvector3.direction(pos, field_pos, data.m_pos)
		mvector3.multiply(pos, 75)
		mvector3.add(pos, field_pos)
		return pos
	end)
	self:pre_hook(PlayerDamage, "damage_melee", function(playerdamage, data)
		if data.push_vel then
			mvector3.multiply(data.push_vel, 10)
			mvector3.set_z(data.push_vel, data.push_vel.z + 1)
		end
		playerdamage._unit:sound():play("hit_oil_drum")
	end)
end

return ChaosModifierMeleeKnockback
