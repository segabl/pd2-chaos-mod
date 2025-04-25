ChaosModifierLowAnimationFps = ChaosModifier.class("ChaosModifierLowAnimationFps")
ChaosModifierLowAnimationFps.duration = 60
ChaosModifierLowAnimationFps.delta = 1 / 5

function ChaosModifierLowAnimationFps:start()
	self._units = {}

	self.set_animation_lod = Unit.set_animation_lod
	self:override(Unit, "set_animation_lod", function(unit, ...)
		self._units[unit:key()] = {
			unit = unit,
			lods = { ... }
		}
		return self.set_animation_lod(unit, math.ceil(self.delta / TimerManager:game():delta_time()), 0, 0, 0)
	end)

	self:override(CopMovement, "anim_clbk_force_ragdoll", function() end)

	local _update_stance = FPCameraPlayerBase._update_stance
	local dt_sum = 0
	self:override(FPCameraPlayerBase, "_update_stance", function(cambase, t, dt, ...)
		dt_sum = dt_sum + dt
		if dt_sum >= self.delta then
			_update_stance(cambase, t, dt, ...)
			dt_sum = 0
		end

		if cambase._fov.transition then
			local trans_data = cambase._fov.transition
			local elapsed_t = t - trans_data.start_t

			if trans_data.duration < elapsed_t then
				cambase._fov.fov = trans_data.end_fov
				cambase._fov.transition = nil
			else
				local progress = elapsed_t / trans_data.duration
				local progress_smooth = math.max(math.min(math.bezier({ 0, 0, 1, 1 }, progress), 1), 0)
				cambase._fov.fov = math.lerp(trans_data.start_fov, trans_data.end_fov, progress_smooth)
			end

			cambase._fov.dirty = true
		end
	end)

	self:check_units()
end

function ChaosModifierLowAnimationFps:check_units()
	for _, unit in pairs(World:find_units_quick("all")) do
		if unit:anim_state_machine() then
			if not self._units[unit:key()] then
				unit:set_animation_lod(1, 100000, 100000, 100000)
			else
				self.set_animation_lod(unit, math.ceil(self.delta / TimerManager:game():delta_time()), 0, 0, 0)
			end
		end
	end

	self:queue("check_units", 0.1)
end

function ChaosModifierLowAnimationFps:stop()
	self:unqueue("check_units")

	for _, data in pairs(self._units) do
		if alive(data.unit) then
			data.unit:set_animation_lod(unpack(data.lods))
		end
	end
end

return ChaosModifierLowAnimationFps
