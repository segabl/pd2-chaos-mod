ChaosModifierIncreasedFallDamage = ChaosModifier.class("ChaosModifierIncreasedFallDamage")
ChaosModifierIncreasedFallDamage.duration = 60

function ChaosModifierIncreasedFallDamage:start()
	self:override(tweak_data.upgrades.values.player.fall_damage_multiplier, 1, 1)
	self:override(tweak_data.upgrades.values.player.fall_health_damage_multiplier, 1, 1)
	self:pre_hook(PlayerDamage, "damage_fall", function(playerdamage, data)
		data.height = 100 + data.height * 2
	end)
end

return ChaosModifierIncreasedFallDamage
