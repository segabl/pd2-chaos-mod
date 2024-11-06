ChaosModifierSecretCloaker = ChaosModifier.class("ChaosModifierSecretCloaker")
ChaosModifierSecretCloaker.run_as_client = false
ChaosModifierSecretCloaker.loud_only = true
ChaosModifierSecretCloaker.color = "enemy_change"
ChaosModifierSecretCloaker.duration = 90

function ChaosModifierSecretCloaker:start()
	self._last_spooc_t = 0

	self:post_hook(CopBrain, "post_init", function(copbrain)
		local chance = (TimerManager:game():time() - self._last_spooc_t) / 15
		if copbrain._logics.attack == CopLogicAttack and math.random() < chance then
			copbrain._logics = clone(copbrain._logics)
			copbrain._logics.attack = SpoocLogicAttack
			managers.hud:post_event("cloaker_spawn")
			managers.network:session():send_to_peers_synched("group_ai_event", managers.groupai:state():get_sync_event_id("cloaker_spawned"), 0)
			self._last_spooc_t = TimerManager:game():time()
		end
	end)

	self:post_hook(ActionSpooc, "on_exit", function(action)
		if not action._unit:base():has_tag("spooc") then
			action._unit:sound():play(action:get_sound_event("detect_stop"))
		end
	end)
end

return ChaosModifierSecretCloaker
