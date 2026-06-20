ChaosModifierBluescreen = ChaosModifier.class("ChaosModifierBluescreen")
ChaosModifierBluescreen.tags = { "ScreenRestriction" }
ChaosModifierBluescreen.conflict_tags = { "ScreenRestriction", "TimeSpeed" }
ChaosModifierBluescreen.duration = 5

function ChaosModifierBluescreen:start()
	self._percentages = { 0 }
	while self._percentages[#self._percentages] < 100 do
		local p = math.min(100, self._percentages[#self._percentages] + math.random(5, 15))
		table.insert(self._percentages, p)
	end

	self._panel = ChaosMod:panel():panel({
		layer = 10000000000
	})

	self._panel:rect({
		color = Color("1f67b3"),
		layer = -1
	})

	self._panel:text({
		x = self._panel:w() * 0.2,
		y = self._panel:h() * 0.2,
		text = ":(",
		font = tweak_data.menu.pd2_large_font,
		font_size = 150
	})

	self._error_text = self._panel:text({
		x = self._panel:w() * 0.2,
		y = self._panel:h() * 0.25 + 150,
		text = managers.localization:text("ChaosModifierBluescreenMainText", { PERCENTAGE = "0" }),
		font = tweak_data.menu.pd2_large_font,
		font_size = 38,
		w = self._panel:w() * 0.6,
		wrap = true
	})

	self._panel:text({
		x = self._panel:w() * 0.2,
		y = self._panel:h() * 0.7,
		text = managers.localization:text("ChaosModifierBluescreenInfoText"),
		font = tweak_data.menu.pd2_large_font,
		font_size = 18
	})

	TimerManager:pausable():set_multiplier(0)
	TimerManager:game_animation():set_multiplier(0)
end

function ChaosModifierBluescreen:update(t, dt)
	local p = self:progress(t) * 110
	local percentage = 0
	for _, v in ipairs(self._percentages) do
		if p >= v then
			percentage = v
		else
			break
		end
	end
	self._error_text:set_text(managers.localization:text("ChaosModifierBluescreenMainText", { PERCENTAGE = tostring(percentage) }))

	SoundDevice:set_rtpc("option_sfx_volume", 0)
	SoundDevice:set_rtpc("option_music_volume", 0)
	XAudio._base_gains.sfx = 0
	XAudio._base_gains.music = 0
end

function ChaosModifierBluescreen:stop()
	TimerManager:pausable():set_multiplier(1)
	TimerManager:game_animation():set_multiplier(1)

	local sfx_volume = managers.user:get_setting("sfx_volume")
	local music_volume = managers.user:get_setting("music_volume")
	SoundDevice:set_rtpc("option_sfx_volume", sfx_volume)
	SoundDevice:set_rtpc("option_music_volume", music_volume)
	XAudio._base_gains.sfx = sfx_volume / 100
	XAudio._base_gains.music = music_volume / 100

	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end
end

return ChaosModifierBluescreen
