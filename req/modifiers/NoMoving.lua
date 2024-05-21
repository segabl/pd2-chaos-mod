ChaosModifierNoMoving = ChaosModifier.class("ChaosModifierNoMoving")
ChaosModifierNoMoving.register_name = "ChaosModifierPlayerMovement"
ChaosModifierNoMoving.run_as_client = true
ChaosModifierNoMoving.duration = 3

function ChaosModifierNoMoving:start()
	self:post_hook(PlayerStandard, "_determine_move_direction", function(playerstate)
		playerstate._move_dir = nil
		playerstate._normal_move_dir = nil
	end)
end

return ChaosModifierNoMoving
