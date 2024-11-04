ChaosModifierLowGravity = ChaosModifier.class("ChaosModifierLowGravity")
ChaosModifierLowGravity.register_name = "ChaosModifierGravity"
ChaosModifierLowGravity.duration = 40
ChaosModifierLowGravity.gravity_mul = 0.25

function ChaosModifierLowGravity:start()
	local set_gravity_original = DefaultPhysXMover.set_gravity
	self:override(DefaultPhysXMover, "set_gravity", function(mover, vec, ...)
		return set_gravity_original(mover, vec * self.gravity_mul, ...)
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
