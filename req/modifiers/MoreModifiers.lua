ChaosModifierMoreModifiers = ChaosModifier.class("ChaosModifierMoreModifiers")
ChaosModifierMoreModifiers.duration = 30

function ChaosModifierMoreModifiers:start()
	ChaosModifierMoreModifiers._cooldown_mul = ChaosModifierMoreModifiers._cooldown_mul or ChaosMod.cooldown_mul
	ChaosMod.cooldown_mul = 0.35
end

function ChaosModifierMoreModifiers:stop()
	ChaosMod.cooldown_mul = ChaosModifierMoreModifiers._cooldown_mul
end

return ChaosModifierMoreModifiers