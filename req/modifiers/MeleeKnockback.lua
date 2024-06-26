ChaosModifierMeleeKnockback = ChaosModifier.class("ChaosModifierMeleeKnockback")
ChaosModifierMeleeKnockback.run_in_stealth = false
ChaosModifierMeleeKnockback.duration = 60

function ChaosModifierMeleeKnockback:start()
	self:override(CopBrain._logic_variants.security, "attack", TankCopLogicAttack)
	self:override(CopLogicAttack, "_find_flank_pos", function(_, _, flank_tracker)
		return flank_tracker:field_position()
	end)
	self:pre_hook(PlayerDamage, "damage_melee", function(_, data)
		if data.push_vel then
			mvector3.multiply(data.push_vel, 10)
		end
	end)
end

return ChaosModifierMeleeKnockback
