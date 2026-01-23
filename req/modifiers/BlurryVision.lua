ChaosModifierBlurryVision = ChaosModifier.class("ChaosModifierBlurryVision")
ChaosModifierBlurryVision.duration = 30

function ChaosModifierBlurryVision:update(t, dt)
	local a = 1
	local time_elapsed, time_left = self:time_elapsed(t), self:time_left(t)
	if time_elapsed < 5 then
		a = math.map_range_clamped(time_elapsed, 0, 5, 0, 1)
	elseif time_left < 5 then
		a = math.map_range_clamped(time_left, 5, 0, 1, 0)
	end
	managers.environment_controller:set_concussion_value(a * 0.85)
end

function ChaosModifierBlurryVision:stop()
	managers.environment_controller:set_concussion_value(0)
end

return ChaosModifierBlurryVision
