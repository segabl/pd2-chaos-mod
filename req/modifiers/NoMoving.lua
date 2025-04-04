ChaosModifierNoMoving = ChaosModifier.class("ChaosModifierNoMoving")
ChaosModifierNoMoving.register_name = "ChaosModifierPlayerMovement"
ChaosModifierNoMoving.duration = 3

function ChaosModifierNoMoving:start()
	self:pre_hook(PlayerStandard, "_update_movement", function(playerstate)
		playerstate._move_dir = nil
		playerstate._normal_move_dir = nil
	end)
end

return ChaosModifierNoMoving
