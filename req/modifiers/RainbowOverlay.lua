ChaosModifierRainbowOverlay = ChaosModifier.class("ChaosModifierRainbowOverlay")
ChaosModifierRainbowOverlay.tags = { "ScreenEffect" }
ChaosModifierRainbowOverlay.conflict_tags = { "ScreenEffect" }
ChaosModifierRainbowOverlay.duration = 45

function ChaosModifierRainbowOverlay:start()
	self._gradient = ChaosMod:panel():gradient({
		layer = -1000000,
		orientation = "vertical",
		blend_mode = "mulx2"
	})
end

function ChaosModifierRainbowOverlay:update(t, dt)
	local a = 1
	local time_elapsed, time_left = self:time_elapsed(t), self:time_left(t)
	if time_elapsed < 2 then
		a = math.map_range_clamped(time_elapsed, 0, 2, 0, 1)
	elseif time_left < 2 then
		a = math.map_range_clamped(time_left, 2, 0, 1, 0)
	end
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
