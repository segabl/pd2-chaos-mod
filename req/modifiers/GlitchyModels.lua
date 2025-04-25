ChaosModifierGlitchyModels = ChaosModifier.class("ChaosModifierGlitchyModels")
ChaosModifierGlitchyModels.duration = 30

function ChaosModifierGlitchyModels:start()
	self._units = {}
	self._offset = Vector3()
	self._ids_model = Idstring("model")
	self._slotmask = managers.slot:get_mask("bullet_impact_targets")
end

function ChaosModifierGlitchyModels:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + 0.1

	local cam_pos = managers.viewport:get_current_camera_position()
	local units = World:find_units_quick("all", self._slotmask)
	for _, unit in pairs(units) do
		local unit_data = self._units[unit:key()]
		if not unit_data then
			unit_data = {
				unit = unit,
				moving = unit:moving(),
				models = unit:get_objects_by_type(self._ids_model),
				offsets = {}
			}
			self._units[unit:key()] = unit_data
		end

		for _, model in pairs(unit_data.models) do
			local dis = mvector3.distance(cam_pos, model:position())
			if dis < 10000 then
				local offset_data = unit_data.offsets[model:key()]
				if not offset_data then
					offset_data = {
						model = model,
						pos = model:local_position()
					}
					unit_data.offsets[model:key()] = offset_data
				end

				unit:set_moving(true)

				mvector3.set_static(self._offset, math.rand(-1, 1), math.rand(-1, 1), math.rand(-1, 1))
				mvector3.multiply(self._offset, math.max(0.5, (dis / 1000) ^ 1.5))
				model:set_local_position(offset_data.pos + self._offset)
			end
		end
	end
end

function ChaosModifierGlitchyModels:stop()
	for _, unit_data in pairs(self._units) do
		if alive(unit_data.unit) then
			unit_data.unit:set_moving(unit_data.moving)
			for _, offset_data in pairs(unit_data.offsets) do
				if alive(offset_data.model) then
					offset_data.model:set_local_position(offset_data.pos)
				end
			end
		end
	end
end

return ChaosModifierGlitchyModels
