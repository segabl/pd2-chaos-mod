ChaosModifierNoSound = ChaosModifier.class("ChaosModifierNoSound")
ChaosModifierNoSound.duration = 30

function ChaosModifierNoSound:start()
	SoundDevice:set_rtpc("option_sfx_volume", managers.user:get_setting("sfx_volume"))
end

function ChaosModifierNoSound:update(t, dt)
	local vol = 0
	local time_elapsed, time_left = self:time_elapsed(t), self:time_left(t)
	if time_elapsed < 0.5 then
		vol = math.map_range(time_elapsed, 0, 0.5, managers.user:get_setting("sfx_volume"), 0)
	elseif time_left < 0.5 then
		vol = math.map_range(time_left, 0.5, 0, 0, managers.user:get_setting("sfx_volume"))
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
