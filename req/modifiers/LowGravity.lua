ChaosModifierLowGravity = ChaosModifier.class("ChaosModifierLowGravity")
ChaosModifierLowGravity.run_as_client = true
ChaosModifierLowGravity.duration = 40

function ChaosModifierLowGravity:start()
	local player_unit = managers.player:local_player()
	if alive(player_unit) and player_unit:mover() then
		player_unit:mover():set_gravity(player_unit:mover():gravity() * 0.25)
	end

	local set_gravity_original = DefaultPhysXMover.set_gravity
	self:override(DefaultPhysXMover, "set_gravity", function(mover, vec, ...)
		return set_gravity_original(mover, vec * 0.25, ...)
	end)
end

function ChaosModifierLowGravity:stop()
	local player_unit = managers.player:local_player()
	if alive(player_unit) and player_unit:mover() then
		player_unit:mover():set_gravity(player_unit:mover():gravity() * 16)
	end
end

return ChaosModifierLowGravity
