ChaosModifierLowGravity = ChaosModifier.class("ChaosModifierLowGravity")
ChaosModifierLowGravity.conflict_tags = { "Gravity" }
ChaosModifierLowGravity.duration = 40
ChaosModifierLowGravity.gravity_mul = 0.25

function ChaosModifierLowGravity:start()
	self:override(DefaultPhysXMover, "set_gravity", function(mover, vec, ...)
		return self:get_override(DefaultPhysXMover, "set_gravity")(mover, vec * self.gravity_mul, ...)
	end)

	local player_unit = managers.player:local_player()
	if alive(player_unit) and player_unit:mover() then
		player_unit:mover():set_gravity(player_unit:mover():gravity())
	end
end

function ChaosModifierLowGravity:stop()
	local player_unit = managers.player:local_player()
	if alive(player_unit) and player_unit:mover() then
		player_unit:mover():set_gravity(player_unit:mover():gravity() / self.gravity_mul)
	end
end

return ChaosModifierLowGravity
