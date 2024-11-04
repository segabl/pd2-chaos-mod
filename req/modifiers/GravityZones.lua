ChaosModifierGravityZones = ChaosModifier.class("ChaosModifierGravityZones")
ChaosModifierGravityZones.register_name = "ChaosModifierGravity"
ChaosModifierGravityZones.duration = 40

function ChaosModifierGravityZones:start()
	self._gravity_mul = 1

	self:post_hook(GroupAIStateBase, "on_criminal_nav_seg_change", function(state, unit, nav_seg_id)
		if unit ~= managers.player:local_player() then
			return
		end

		math.randomseed(self._seed * nav_seg_id)
		self._gravity_mul = math.rand(0, 2)
	end)
end

function ChaosModifierGravityZones:update(t, dt)
	local player_unit = managers.player:local_player()
	if alive(player_unit) and player_unit:mover() and player_unit:mover():gravity():length() > 0 then
		player_unit:mover():set_gravity(Vector3(0, 0, -982 * self._gravity_mul))
	end
end

function ChaosModifierGravityZones:stop()
	local player_unit = managers.player:local_player()
	if alive(player_unit) and player_unit:mover() and player_unit:mover():gravity():length() > 0 then
		player_unit:mover():set_gravity(Vector3(0, 0, -982))
	end
end

return ChaosModifierGravityZones
