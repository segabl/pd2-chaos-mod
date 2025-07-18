ChaosModifierSoundPitch = ChaosModifier.class("ChaosModifierSoundPitch")
ChaosModifierSoundPitch.duration = 90

function ChaosModifierSoundPitch:start()
	math.randomseed(self._seed)
	SoundDevice:set_rtpc("game_speed", math.random() < 0.7 and 1.5 or 0.5)
end

function ChaosModifierSoundPitch:stop()
	SoundDevice:set_rtpc("game_speed", 1)
end

return ChaosModifierSoundPitch
