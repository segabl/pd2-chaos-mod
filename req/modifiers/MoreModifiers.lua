ChaosModifierMoreModifiers = ChaosModifier.class("ChaosModifierMoreModifiers")
ChaosModifierMoreModifiers.run_as_client = false
ChaosModifierMoreModifiers.duration = 30

function ChaosModifierMoreModifiers:start()
	self:override(ChaosMod, "cooldown_mul", 0.35)
end

return ChaosModifierMoreModifiers
