ChaosModifierMeleeKnockback = ChaosModifier.class("ChaosModifierMeleeKnockback")
ChaosModifierMeleeKnockback.run_as_client = true
ChaosModifierMeleeKnockback.duration = 60

function ChaosModifierMeleeKnockback:start()
	self:override(CopBrain._logic_variants.security, "attack", TankCopLogicAttack)
	self:pre_hook(PlayerDamage, "damage_melee", function(_, data)
		if data.push_vel then
			mvector3.multiply(data.push_vel, 10)
		end
	end)
end

return ChaosModifierMeleeKnockback
