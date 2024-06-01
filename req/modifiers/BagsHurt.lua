ChaosModifierBagsHurt = ChaosModifier.class("ChaosModifierBagsHurt")
ChaosModifierBagsHurt.run_as_client = true
ChaosModifierBagsHurt.duration = 30

function ChaosModifierBagsHurt:can_trigger()
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if alive(data.unit) and data.unit:movement():current_state_name() == "carry" then
			return true
		end
	end

	for _, v in pairs(World:find_units_quick("all", World:make_slot_mask(14))) do
		if v:carry_data() then
			return true
		end
	end
end

function ChaosModifierBagsHurt:start()
	managers.player:force_drop_carry()
end

function ChaosModifierBagsHurt:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + 0.25

	local player_unit = managers.player:local_player()
	if not alive(player_unit) or player_unit:movement():current_state_name() ~= "carry" then
		return
	end

	player_unit:character_damage():damage_simple({
		variant = "bullet",
		damage = 1
	})
end

return ChaosModifierBagsHurt
