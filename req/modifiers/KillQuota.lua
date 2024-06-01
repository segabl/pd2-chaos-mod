ChaosModifierKillQuota = ChaosModifier.class("ChaosModifierKillQuota")
ChaosModifierKillQuota.run_as_client = true
ChaosModifierKillQuota.duration = 20

function ChaosModifierKillQuota:can_trigger()
	local gstate = managers.groupai:state()
	return gstate._hunt_mode or gstate._task_data.assault.active and (gstate._task_data.assault.phase == "build" or gstate._task_data.assault.phase == "sustain")
end

function ChaosModifierKillQuota:start()
	self._kills = 0
	self._target = 5

	local text = managers.localization:to_upper_text("ChaosModifierKillQuotaStart", {
		AMOUNT = tostring(self._target)
	})
	self:show_text(text, 2, true)

	managers.player:register_message(Message.OnEnemyKilled, "ChaosModifierKillQuota", function()
		if self._kills >= self._target then
			return
		end
		self._kills = self._kills + 1
		text = managers.localization:to_upper_text("ChaosModifierKillQuotaProgress", {
			AMOUNT = tostring(self._kills),
			TOTAL = tostring(self._target)
		})
		managers.hud:show_hint({ text = text, time = 2 })
	end)
end

function ChaosModifierKillQuota:stop()
	managers.player:unregister_message(Message.OnEnemyKilled, "ChaosModifierKillQuota")

	if self._kills < self._target then
		managers.player:set_player_state("incapacitated")
	end
end

return ChaosModifierKillQuota
