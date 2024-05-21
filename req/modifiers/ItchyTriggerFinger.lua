ChaosModifierItchyTriggerFinger = ChaosModifier.class("ChaosModifierItchyTriggerFinger")
ChaosModifierItchyTriggerFinger.run_as_client = true
ChaosModifierItchyTriggerFinger.duration = 40

function ChaosModifierItchyTriggerFinger:start()
	self._state = true

	self:post_hook(PlayerStandard, "_get_input", function(playerstate, t)
		if not self._next_t or self._next_t < t then
			self._state = not self._state
			self._next_t = t + (self._state and math.rand(0, 0.3) or math.rand(4, 8))
		end

		if self._state then
			local input = Hooks:GetReturn()
			input.btn_primary_attack_press = true
			input.btn_primary_attack_state = true
		end
	end)
end

return ChaosModifierItchyTriggerFinger
