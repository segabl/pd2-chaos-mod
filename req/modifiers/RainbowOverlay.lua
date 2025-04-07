ChaosModifierRainbowOverlay = ChaosModifier.class("ChaosModifierRainbowOverlay")
ChaosModifierRainbowOverlay.register_name = "ChaosModifierScreenEffect"
ChaosModifierRainbowOverlay.duration = 45

function ChaosModifierRainbowOverlay:start()
	self._gradient = ChaosMod:panel():gradient({
		layer = -1000000,
		orientation = "vertical",
		blend_mode = "mulx2"
	})
end

function ChaosModifierRainbowOverlay:update(t, dt)
	local p = t - self._activation_t
	local a = math.map_range_clamped(p, 0, 2, 0, 1) * math.map_range_clamped(p, self.duration - 2, self.duration, 1, 0)
	local points = {}
	for i = 0, 360, 30 do
		table.insert(points, i / 360)
		table.insert(points, Color(hsv_to_rgb((t * 90 - i) % 360, a, 0.5 + a * 0.5)))
	end

	self._gradient:set_gradient_points(points)
end

function ChaosModifierRainbowOverlay:stop()
	if alive(self._gradient) then
		self._gradient:parent():remove(self._gradient)
	end
end

return ChaosModifierRainbowOverlay
