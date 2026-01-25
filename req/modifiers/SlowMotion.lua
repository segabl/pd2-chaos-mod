ChaosModifierSlowMotion = ChaosModifier.class("ChaosModifierSlowMotion")
ChaosModifierSlowMotion.tags = { "TimeSpeed" }
ChaosModifierSlowMotion.conflict_tags = { "TimeSpeed" }
ChaosModifierSlowMotion.duration = 20
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
