ChaosModifierRandomPush = ChaosModifier.class("ChaosModifierRandomPush")
ChaosModifierRandomPush.duration = 30

function ChaosModifierRandomPush:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + math.rand(4, 8) * (math.random() < 0.1 and 0.2 or 1)

	local player_unit = managers.player:player_unit()
	if not alive(player_unit) then
		return
	end

	local push_dir = mvector3.copy(math.UP)
	mvector3.random_orthogonal(push_dir)
	mvector3.lerp(push_dir, push_dir, math.UP, math.rand(0.5, 1))
	mvector3.multiply(push_dir, 1000)

	player_unit:movement():push(push_dir)
	player_unit:camera():play_shaker(table.random({
		"melee_hit",
		"melee_hit_var2"
	}), 1)
end

return ChaosModifierRandomPush
