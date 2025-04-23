ChaosModifierMeme = ChaosModifier.class("ChaosModifierMeme")
ChaosModifierMeme.duration = 30

function ChaosModifierMeme:start()
	SoundDevice:set_rtpc("downed_state_progression", 80)

	local set_rtpc = SoundDevice.set_rtpc
	self:override(getmetatable(SoundDevice), "set_rtpc", function(device, param, ...)
		if param ~= "downed_state_progression" then
			return set_rtpc(device, param, ...)
		end
	end)

	self._panel = ChaosMod:panel():panel()

	self._panel:text({
		text = managers.localization:text("ChaosModifierMemeText"),
		font = tweak_data.menu.pd2_large_font,
		font_size = 48,
		align = "center",
		vertical = "center",
		h = 72,
		y = math.ceil(self._panel:h() * 0.7)
	})

	self._panel:rect({
		color = Color.white,
		x = math.floor(self._panel:w() * 0.3) - 3,
		y = math.floor(self._panel:h() * 0.3) - 3,
		w = 3,
		h = math.ceil(self._panel:h() * 0.4) + 6
	})

	self._panel:rect({
		color = Color.white,
		x = math.ceil(self._panel:w() * 0.7),
		y = math.floor(self._panel:h() * 0.3) - 3,
		w = 3,
		h = math.ceil(self._panel:h() * 0.4) + 6
	})

	self._panel:rect({
		color = Color.white,
		x = math.floor(self._panel:w() * 0.3) - 3,
		y = math.floor(self._panel:h() * 0.3) - 3,
		w = math.ceil(self._panel:w() * 0.4) + 6,
		h = 3
	})

	self._panel:rect({
		color = Color.white,
		x = math.floor(self._panel:w() * 0.3) - 3,
		y = math.ceil(self._panel:h() * 0.7),
		w = math.ceil(self._panel:w() * 0.4) + 6,
		h = 3
	})

	managers.viewport:get_active_vp():set_dimensions(0.3, 0.3, 0.4, 0.4)
end

function ChaosModifierMeme:stop()
	SoundDevice:set_rtpc("downed_state_progression", 0)

	managers.viewport:get_active_vp():set_dimensions(0, 0, 1, 1)

	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end
end

return ChaosModifierMeme
