ChaosModifierPlayerGrouping = ChaosModifier.class("ChaosModifierPlayerGrouping")
ChaosModifierPlayerGrouping.register_name = "ChaosModifierPlayerDistance"
ChaosModifierPlayerGrouping.duration = 45

function ChaosModifierPlayerGrouping:can_trigger()
	return table.size(managers.groupai:state():all_char_criminals()) > 1
end

function ChaosModifierPlayerGrouping:start()
	self._lights = {}
end

function ChaosModifierPlayerGrouping:update(t, dt)
	local criminals = managers.groupai:state():all_char_criminals()
	local player_unit = managers.player:local_player()

	for u_key, light in pairs(self._lights) do
		if alive(light) then
			if criminals[u_key] then
				light:set_multiplier(25 + 10 * math.sin(t * 90))
			else
				World:delete_light(light)
				self._lights[u_key] = nil
			end
		end
	end

	for u_key, data in pairs(criminals) do
		if not self._lights[u_key] and alive(data.unit) and data.unit ~= player_unit then
			local light = World:create_light("spot|specular")
			light:set_spot_angle_end(179)
			light:set_near_range(195)
			light:set_far_range(625)
			light:set_color(Vector3(0, 1, 0))
			light:link(data.unit:orientation_object())
			light:set_local_position(Vector3(0, 0, 200))
			self._lights[u_key] = light
		end
	end

	if not alive(player_unit) or self._next_t and self._next_t > t then
		return
	end

	for _, data in pairs(criminals) do
		if alive(data.unit) and data.unit ~= player_unit then
			local dis_sq = mvector3.distance_sq(data.unit:movement():m_pos(), player_unit:movement():m_pos())
			if dis_sq < 600 ^ 2 then
				return
			end
		end
	end

	player_unit:character_damage():damage_simple({
		variant = "bullet",
		damage = 0.5
	})
	self._next_t = t + 0.25
end

function ChaosModifierPlayerGrouping:stop()
	for _, light in pairs(self._lights) do
		if alive(light) then
			World:delete_light(light)
		end
	end
end

return ChaosModifierPlayerGrouping
