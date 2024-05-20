---@class ChaosModifierLimitFps : ChaosModifier
ChaosModifierLimitFps = class(ChaosModifier)
ChaosModifierLimitFps.class_name = "ChaosModifierLimitFps"
ChaosModifierLimitFps.name = "Console Experience"
ChaosModifierLimitFps.run_as_client = true
ChaosModifierLimitFps.duration = 30

function ChaosModifierLimitFps:start()
	setup:set_fps_cap(20)
	setup._framerate_low = true
end

function ChaosModifierLimitFps:stop()
	setup._framerate_low = nil
	setup:set_fps_cap(managers.user:get_setting("fps_cap"))
end

return ChaosModifierLimitFps
