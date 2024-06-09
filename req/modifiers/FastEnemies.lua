ChaosModifierFastEnemies = ChaosModifier.class("ChaosModifierFastEnemies")
ChaosModifierFastEnemies.duration = 45

function ChaosModifierFastEnemies:start()
	self:post_hook(CopMovement, "speed_modifier", function()
		return (Hooks:GetReturn() or 1) * 1.75
	end)
end

return ChaosModifierFastEnemies
