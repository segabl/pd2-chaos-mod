---@class ChaosModifierCrabPeople : ChaosModifier
ChaosModifierCrabPeople = class(ChaosModifier)
ChaosModifierCrabPeople.class_name = "ChaosModifierCrabPeople"
ChaosModifierCrabPeople.register_name = "ChaosModifierPlayerMovement"
ChaosModifierCrabPeople.name = "Crab People"
ChaosModifierCrabPeople.run_as_client = true
ChaosModifierCrabPeople.duration = 20

function ChaosModifierCrabPeople:start()
	Hooks:PostHook(PlayerStandard, "_determine_move_direction", self.class_name, function(playerstate)
		if not playerstate._move_dir then
			return
		end

		mvector3.set_y(playerstate._stick_move, 0)
		mvector3.normalize(playerstate._stick_move)

		playerstate._move_dir = mvector3.copy(playerstate._stick_move)
		mvector3.rotate_with(playerstate._move_dir, Rotation(playerstate._cam_fwd_flat, math.UP))
		playerstate._normal_move_dir = mvector3.copy(playerstate._move_dir)
	end)
end

function ChaosModifierCrabPeople:stop()
	Hooks:RemovePostHook(self.class_name)
end

return ChaosModifierCrabPeople
