ChaosModifierMeleeKnockback = ChaosModifier.class("ChaosModifierMeleeKnockback")
ChaosModifierMeleeKnockback.run_as_client = true
ChaosModifierMeleeKnockback.duration = 60

function ChaosModifierMeleeKnockback:start()
	self:pre_hook(PlayerDamage, "damage_melee", function(playerdamage, data)
		if data.push_vel then
			mvector3.multiply(data.push_vel, 10)
		end
	end)
end

return ChaosModifierMeleeKnockback
