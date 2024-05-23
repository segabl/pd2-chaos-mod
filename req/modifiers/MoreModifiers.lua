ChaosModifierMoreModifiers = ChaosModifier.class("ChaosModifierMoreModifiers")
ChaosModifierMoreModifiers.duration = 30

function ChaosModifierMoreModifiers:start()
	self:override(ChaosMod, "cooldown_mul", 0.35)
end

return ChaosModifierMoreModifiers
