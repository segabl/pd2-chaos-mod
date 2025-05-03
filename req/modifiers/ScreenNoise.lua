ChaosModifierScreenNoise = ChaosModifier.class("ChaosModifierScreenNoise")
ChaosModifierScreenNoise.duration = 60

function ChaosModifierScreenNoise:start()
	local panel = ChaosMod:panel()
	self._image = panel:bitmap({
		layer = 100,
		alpha = 0.15,
		blend_mode = "add",
		texture = "core/textures/noise_sharp",
		wrap_mode = "wrap",
		w = panel:w(),
		h = panel:h()
	})

	self:update_noise()
end

function ChaosModifierScreenNoise:update_noise()
	self._image:set_texture_rect(math.random(self._image:w()), math.random(self._image:h()), self._image:w(), self._image:h())
	self:queue("update_noise", 0.1)
end

function ChaosModifierScreenNoise:stop()
	self:unqueue("update_noise")
	if alive(self._image) then
		self._image:parent():remove(self._image)
	end
end

return ChaosModifierScreenNoise
