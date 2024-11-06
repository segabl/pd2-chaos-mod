ChaosModifierItchyTriggerFinger = ChaosModifier.class("ChaosModifierItchyTriggerFinger")
ChaosModifierItchyTriggerFinger.stealth_safe = false
ChaosModifierItchyTriggerFinger.duration = 40

function ChaosModifierItchyTriggerFinger:start()
	self._state = true

	self:post_hook(PlayerStandard, "_get_input", function(playerstate, t)
		if not self._next_t or self._next_t < t then
			self._state = not self._state
			self._next_t = t + (self._state and math.rand(0.1, 0.3) + (playerstate._running and 0.25 or 0) or math.rand(4, 8))
		end

		if self._state then
			local input = Hooks:GetReturn()
			input.btn_primary_attack_press = true
			input.btn_primary_attack_state = true
			if playerstate._running then
				input.btn_run_press = not playerstate._setting_hold_to_run
				input.btn_run_release = playerstate._setting_hold_to_run
			end
		end
	end)
end

return ChaosModifierItchyTriggerFinger
