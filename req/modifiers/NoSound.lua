ChaosModifierNoSound = ChaosModifier.class("ChaosModifierNoSound")
ChaosModifierNoSound.run_as_client = true
ChaosModifierNoSound.duration = 30

function ChaosModifierNoSound:start()
	SoundDevice:set_rtpc("option_sfx_volume", managers.user:get_setting("sfx_volume"))
end

function ChaosModifierNoSound:update(t, dt)
	local vol = 0
	if t < self._activation_t + 0.5 then
		vol = math.map_range(t, self._activation_t, self._activation_t + 0.5, managers.user:get_setting("sfx_volume"), 0)
	elseif t > self._activation_t + self.duration - 0.5 then
		vol = math.map_range(t, self._activation_t + self.duration - 0.5, self._activation_t + self.duration, 0, managers.user:get_setting("sfx_volume"))
	end
	SoundDevice:set_rtpc("option_sfx_volume", vol)
	XAudio._base_gains.sfx = vol / 100
end

function ChaosModifierNoSound:stop()
	local vol = managers.user:get_setting("sfx_volume")
	SoundDevice:set_rtpc("option_sfx_volume", vol)
	XAudio._base_gains.sfx = vol / 100
end

return ChaosModifierNoSound
