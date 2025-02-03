ChaosModifierSlowAndTanky = ChaosModifier.class("ChaosModifierSlowAndTanky")
ChaosModifierSlowAndTanky.duration = 30

function ChaosModifierSlowAndTanky:start()
	self:post_hook(PlayerStandard, "_get_max_walk_speed", function()
		return Hooks:GetReturn() * 0.35
	end)

	self:post_hook(PlayerDamage, "_max_armor", function()
		return Hooks:GetReturn() * 2
	end)

	self:post_hook(PlayerDamage, "_max_health", function()
		return Hooks:GetReturn() * 2
	end)

	self:override(PlayerMovement, "on_SPOOCed", function()
		return "countered"
	end)
end

return ChaosModifierSlowAndTanky
