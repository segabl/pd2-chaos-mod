ChaosModifierBlurryVision = ChaosModifier.class("ChaosModifierBlurryVision")
ChaosModifierBlurryVision.duration = 30

function ChaosModifierBlurryVision:update(t, dt)
	local p = t - self._activation_t
	local a = math.map_range_clamped(p, 0, 5, 0, 1) * math.map_range_clamped(p, self.duration - 1, self.duration, 1, 0)
	managers.environment_controller:set_concussion_value(a * 0.85)
end

function ChaosModifierBlurryVision:stop()
	managers.environment_controller:set_concussion_value(0)
end

return ChaosModifierBlurryVision
