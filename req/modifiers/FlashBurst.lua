ChaosModifierFlashBurst = ChaosModifier.class("ChaosModifierFlashBurst")

function ChaosModifierFlashBurst:start()
	self._num_calls = 4

	self:queue("detonate", 0.5)
end

function ChaosModifierFlashBurst:detonate()
	self._num_calls = self._num_calls - 1

	local nav_segs = {}
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if not nav_segs[data.seg] then
			nav_segs[data.seg] = true
			managers.groupai:state():detonate_smoke_grenade(managers.navigation:find_random_position_in_segment(data.seg), nil, 1, true)
		end
	end

	if self._num_calls > 0 then
		self:queue("detonate", 0.5)
	end
end

return ChaosModifierFlashBurst
