ChaosModifierBagsHurt = ChaosModifier.class("ChaosModifierBagsHurt")
ChaosModifierBagsHurt.duration = 30

function ChaosModifierBagsHurt:can_trigger()
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if alive(data.unit) and data.unit:movement():current_state_name() == "carry" then
			return true
		end
	end

	for _, unit in pairs(World:find_units_quick("all", World:make_slot_mask(14))) do
		if unit:carry_data() then
			return true
		end
	end
end

function ChaosModifierBagsHurt:start()
	self._effects = {}

	managers.player:drop_carry()
end

function ChaosModifierBagsHurt:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + 0.25

	for u_key, data in pairs(self._effects) do
		if not alive(data.unit) then
			World:effect_manager():fade_kill(data.effect)
			self._effects[u_key] = nil
		end
	end

	for _, unit in pairs(World:find_units_quick("all", World:make_slot_mask(14))) do
		if unit:carry_data() and not self._effects[unit:key()] then
			self._effects[unit:key()] = {
				unit = unit,
				effect = World:effect_manager():spawn({
					effect = Idstring("effects/particles/fire/small_light_fire"),
					parent = unit:orientation_object()
				})
			}
		end
	end

	local player_unit = managers.player:local_player()
	if not alive(player_unit) or player_unit:movement():current_state_name() ~= "carry" then
		return
	end

	player_unit:character_damage():damage_simple({
		variant = "bullet",
		damage = 1
	})
end

function ChaosModifierBagsHurt:stop()
	for _, data in pairs(self._effects) do
		World:effect_manager():fade_kill(data.effect)
	end
end

return ChaosModifierBagsHurt
