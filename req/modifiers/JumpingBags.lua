ChaosModifierJumpingBags = ChaosModifier.class("ChaosModifierJumpingBags")
ChaosModifierJumpingBags.run_as_client = false
ChaosModifierJumpingBags.duration = 60

function ChaosModifierJumpingBags:can_trigger()
	for _, v in pairs(World:find_units_quick("all", World:make_slot_mask(14))) do
		if v:carry_data() and not v:is_linked_to_unit() then
			return true
		end
	end
end

function ChaosModifierJumpingBags:start()
	self._push_vec = Vector3()
end

function ChaosModifierJumpingBags:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	local bags = {}
	for _, v in pairs(World:find_units_quick("all", World:make_slot_mask(14))) do
		if v:carry_data() and not v:is_linked_to_unit() and v:velocity():length() < 1 then
			table.insert(bags, v)
		end
	end

	self._next_t = t + 1 / #bags

	local bag = table.random(bags)
	if not bag then
		return
	end

	mvector3.set(self._push_vec, math.UP)
	mvector3.random_orthogonal(self._push_vec)
	mvector3.lerp(self._push_vec, self._push_vec, math.UP, math.rand(0.5, 1))
	mvector3.multiply(self._push_vec, math.random(200, 1000))

	bag:carry_data():set_position_and_throw(bag:position(), self._push_vec, 100)
end

return ChaosModifierJumpingBags
