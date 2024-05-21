---@class ChaosModifierForceMove : ChaosModifier
ChaosModifierForceMove = class(ChaosModifier)
ChaosModifierForceMove.class_name = "ChaosModifierForceMove"
ChaosModifierForceMove.register_name = "ChaosModifierPlayerMovement"
ChaosModifierForceMove.run_as_client = true
ChaosModifierForceMove.duration = 20

function ChaosModifierForceMove:start()
	Hooks:PostHook(PlayerStandard, "_determine_move_direction", self.class_name, function(playerstate)
		mvector3.set_y(playerstate._stick_move, 1)
		mvector3.normalize(playerstate._stick_move)

		playerstate._move_dir = mvector3.copy(playerstate._stick_move)
		mvector3.rotate_with(playerstate._move_dir, Rotation(playerstate._cam_fwd_flat, math.UP))
		playerstate._normal_move_dir = mvector3.copy(playerstate._move_dir)
	end)
end

function ChaosModifierForceMove:stop()
	Hooks:RemovePostHook(self.class_name)
end

return ChaosModifierForceMove
