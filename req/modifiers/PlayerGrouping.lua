ChaosModifierPlayerGrouping = ChaosModifier.class("ChaosModifierPlayerGrouping")
ChaosModifierPlayerGrouping.conflict_tags = { "PlayerDistance" }
ChaosModifierPlayerGrouping.duration = 45
ChaosModifierPlayerGrouping.radius = 600

function ChaosModifierPlayerGrouping:can_trigger()
	return table.size(managers.groupai:state():all_char_criminals()) > 1
end

function ChaosModifierPlayerGrouping:update(t, dt)
	local criminals = managers.groupai:state():all_char_criminals()
	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local player_pos = player_unit:movement():m_pos()
	local brush = Draw:brush(Color.green)
	for _, data in pairs(criminals) do
		if data.unit ~= player_unit and mvector3.distance_sq(data.m_pos, player_pos) < self.radius ^ 2 then
			brush:circle(player_pos + math.UP * 25, self.radius, 60, math.UP, 40)
			return
		end
	end

	local p = math.map_range(math.sin(t * 360 * 4), -1, 1, 0, 1)
	brush:set_color(Color(1, 1 - p, 0))
	brush:circle(player_pos + math.UP * 25, self.radius, 60, math.UP, 40)

	local pos_offset = Vector3()
	for _, data in pairs(criminals) do
		if data.unit ~= player_unit then
			mvector3.step(pos_offset, player_pos, data.m_pos, self.radius - 30)
			mvector3.set_z(pos_offset, player_pos.z + 25)
			brush:line(pos_offset, data.m_pos + math.UP * 25, 20)
		end
	end

	if self._next_t and self._next_t > t then
		return
	end

	player_unit:character_damage():damage_simple({
		variant = "bullet",
		damage = 0.5
	})
	self._next_t = t + 0.25
end

return ChaosModifierPlayerGrouping
