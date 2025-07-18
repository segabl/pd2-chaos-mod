ChaosModifierPlayerDamageAura = ChaosModifier.class("ChaosModifierPlayerDamageAura")
ChaosModifierPlayerDamageAura.conflict_tags = { "PlayerDistance" }
ChaosModifierPlayerDamageAura.duration = 45

function ChaosModifierPlayerDamageAura:can_trigger()
	return table.size(managers.groupai:state():all_char_criminals()) > 1
end

function ChaosModifierPlayerDamageAura:start()
	self._effects = {}
end

function ChaosModifierPlayerDamageAura:update(t, dt)
	local criminals = managers.groupai:state():all_char_criminals()
	local player_unit = managers.player:local_player()

	for u_key, effect in pairs(self._effects) do
		if not criminals[u_key] then
			World:effect_manager():fade_kill(effect)
			self._effects[u_key] = nil
		end
	end

	for u_key, data in pairs(criminals) do
		if not self._effects[u_key] and alive(data.unit) and data.unit ~= player_unit then
			self._effects[u_key] = World:effect_manager():spawn({
				effect = Idstring("effects/particles/explosions/poison_gas"),
				parent = data.unit:orientation_object()
			})
		end
	end

	if not alive(player_unit) or self._next_t and self._next_t > t then
		return
	end

	for _, data in pairs(criminals) do
		if alive(data.unit) and data.unit ~= player_unit then
			if mvector3.distance_sq(data.unit:movement():m_pos(), player_unit:movement():m_pos()) < 300 ^ 2 then
				player_unit:character_damage():damage_simple({
					variant = "bullet",
					damage = 1
				})
				player_unit:character_damage():_hit_direction(data.unit:movement():m_pos(), data.unit:movement():m_pos() - player_unit:movement():m_pos())
				self._next_t = t + 0.25
				break
			end
		end
	end
end

function ChaosModifierPlayerDamageAura:stop()
	for _, effect in pairs(self._effects) do
		World:effect_manager():fade_kill(effect)
	end
end

return ChaosModifierPlayerDamageAura
