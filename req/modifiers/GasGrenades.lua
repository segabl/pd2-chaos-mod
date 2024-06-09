ChaosModifierGasGrenades = ChaosModifier.class("ChaosModifierGasGrenades")
ChaosModifierGasGrenades.run_as_client = false
ChaosModifierGasGrenades.duration = 45

function ChaosModifierGasGrenades:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + math.rand(5, 10)

	local positions = {}
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if not data.status and alive(data.unit) then
			table.insert(positions, data.m_pos)
		end
	end

	local pos = table.random(positions)
	if pos then
		managers.groupai:state():detonate_cs_grenade(pos, nil, 7)
	end
end

return ChaosModifierGasGrenades
