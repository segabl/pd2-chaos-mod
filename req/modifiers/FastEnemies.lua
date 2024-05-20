---@class ChaosModifierFastEnemies : ChaosModifier
ChaosModifierFastEnemies = class(ChaosModifier)
ChaosModifierFastEnemies.class_name = "ChaosModifierFastEnemies"
ChaosModifierFastEnemies.name = "Cocaine is a hell of a drug"
ChaosModifierFastEnemies.run_as_client = true
ChaosModifierFastEnemies.duration = 45

function ChaosModifierFastEnemies:start()
	Hooks:PostHook(CopMovement, "speed_modifier", self.class_name, function()
		return (Hooks:GetReturn() or 1) * 1.5
	end)
end

function ChaosModifierFastEnemies:stop()
	Hooks:RemovePostHook(self.class_name)
end

return ChaosModifierFastEnemies
