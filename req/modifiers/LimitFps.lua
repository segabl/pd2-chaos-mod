ChaosModifierLimitFps = ChaosModifier.class("ChaosModifierLimitFps")
ChaosModifierLimitFps.duration = 25

function ChaosModifierLimitFps:start()
	setup:set_fps_cap(25)
	setup._framerate_low = true
end

function ChaosModifierLimitFps:stop()
	setup._framerate_low = nil
	setup:set_fps_cap(managers.user:get_setting("fps_cap"))
end

return ChaosModifierLimitFps
