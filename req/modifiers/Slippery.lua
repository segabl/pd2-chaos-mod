ChaosModifierSlippery = ChaosModifier.class("ChaosModifierSlippery")
ChaosModifierSlippery.conflict_tags = { "PlayerMovement" }
ChaosModifierSlippery.duration = 40

function ChaosModifierSlippery:start()
	self:pre_hook(PlayerStandard, "_update_movement", function(playerstate, t, dt)
		if not self._move_dir then
			self._move_dir = playerstate._move_dir and mvector3.copy(playerstate._move_dir) or Vector3()
		end

		if playerstate._move_dir then
			local dot = mvector3.dot(self._move_dir, playerstate._move_dir)
			local mul = math.map_range(dot, -1, 1, 0.5, 1.5)
			mvector3.lerp(self._move_dir, self._move_dir, playerstate._move_dir, dt * mul)
		else
			mvector3.multiply(self._move_dir, math.max(0, 1 - dt * 0.5))
		end

		playerstate._move_dir = self._move_dir
		playerstate._normal_move_dir = self._move_dir
	end)
end

return ChaosModifierSlippery
