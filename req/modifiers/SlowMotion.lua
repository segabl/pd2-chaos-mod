---@class ChaosModifierSlowMotion : ChaosModifier
ChaosModifierSlowMotion = class(ChaosModifier)
ChaosModifierSlowMotion.class_name = "ChaosModifierSlowMotion"
ChaosModifierSlowMotion.register_name = "ChaosModifierTimeSpeed"
ChaosModifierSlowMotion.run_as_client = true
ChaosModifierSlowMotion.duration = 10
ChaosModifierSlowMotion.speed = 0.5

function ChaosModifierSlowMotion:start()
	TimerManager:pausable():set_multiplier(self.speed)
	TimerManager:game_animation():set_multiplier(self.speed)
end

function ChaosModifierSlowMotion:stop()
	TimerManager:pausable():set_multiplier(1)
	TimerManager:game_animation():set_multiplier(1)
end

return ChaosModifierSlowMotion
