ChaosModifierCrabPeople = ChaosModifier.class("ChaosModifierCrabPeople")
ChaosModifierCrabPeople.register_name = "ChaosModifierPlayerMovement"
ChaosModifierCrabPeople.duration = 20

function ChaosModifierCrabPeople:start()
	self:pre_hook(PlayerStandard, "_update_movement", function(playerstate)
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

return ChaosModifierCrabPeople
