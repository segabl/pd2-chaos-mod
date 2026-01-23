ChaosModifierLightMultiplier = ChaosModifier.class("ChaosModifierLightMultiplier")
ChaosModifierLightMultiplier.conflict_tags = { "NoLights" }
ChaosModifierLightMultiplier.duration = 60

function ChaosModifierLightMultiplier:start()
	self._lights = {}
	for _, unit in pairs(World:find_units_quick("all")) do
		for _, light in pairs(unit:get_objects_by_type(Idstring("light"))) do
			table.insert(self._lights, {
				light,
				light:multiplier()
			})
		end
	end
end

function ChaosModifierLightMultiplier:update(t, dt)
	local time_elapsed, time_left = self:time_elapsed(t), self:time_left(t)
	if time_elapsed < 5 then
		for _, light_data in pairs(self._lights) do
			if alive(light_data[1]) then
				light_data[1]:set_multiplier(math.map_range(time_elapsed, 0, 5, light_data[2], light_data[2] * 50))
			end
		end
	elseif time_left < 5 then
		for _, light_data in pairs(self._lights) do
			if alive(light_data[1]) then
				light_data[1]:set_multiplier(math.map_range(time_left, 5, 0, light_data[2] * 50, light_data[2]))
			end
		end
	end
end

function ChaosModifierLightMultiplier:stop()
	for _, light_data in pairs(self._lights) do
		if alive(light_data[1]) then
			light_data[1]:set_multiplier(light_data[2])
		end
	end
end

return ChaosModifierLightMultiplier
