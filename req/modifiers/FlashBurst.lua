ChaosModifierFlashBurst = ChaosModifier.class("ChaosModifierFlashBurst")
ChaosModifierFlashBurst.run_in_stealth = false
ChaosModifierFlashBurst.run_as_client = false

function ChaosModifierFlashBurst:start()
	self._num_calls = 4

	self:queue("detonate", 0.5)
end

function ChaosModifierFlashBurst:detonate()
	self._num_calls = self._num_calls - 1

	local check_pos = Vector3()
	local check_tracker = managers.navigation:create_nav_tracker(check_pos)
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		mvector3.set(check_pos, math.UP)
		mvector3.random_orthogonal(check_pos)
		mvector3.multiply(check_pos, math.random(600))
		mvector3.add(check_pos, data.m_pos)
		check_tracker:move(check_pos)
		managers.groupai:state():detonate_smoke_grenade(check_tracker:field_position(), nil, 1, true)
	end
	managers.navigation:destroy_nav_tracker(check_tracker)

	if self._num_calls > 0 then
		self:queue("detonate", 0.5)
	end
end

return ChaosModifierFlashBurst
