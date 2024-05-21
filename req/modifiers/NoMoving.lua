---@class ChaosModifierNoMoving : ChaosModifier
ChaosModifierNoMoving = class(ChaosModifier)
ChaosModifierNoMoving.class_name = "ChaosModifierNoMoving"
ChaosModifierNoMoving.register_name = "ChaosModifierPlayerMovement"
ChaosModifierNoMoving.run_as_client = true
ChaosModifierNoMoving.duration = 3

function ChaosModifierNoMoving:start()
	Hooks:PostHook(PlayerStandard, "_determine_move_direction", self.class_name, function(playerstate)
		playerstate._move_dir = nil
		playerstate._normal_move_dir = nil
	end)
end

function ChaosModifierNoMoving:stop()
	Hooks:RemovePostHook(self.class_name)
end

return ChaosModifierNoMoving
