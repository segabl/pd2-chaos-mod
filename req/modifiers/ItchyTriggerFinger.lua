---@class ChaosModifierItchyTriggerFinger : ChaosModifier
ChaosModifierItchyTriggerFinger = class(ChaosModifier)
ChaosModifierItchyTriggerFinger.class_name = "ChaosModifierItchyTriggerFinger"
ChaosModifierItchyTriggerFinger.name = "Itchy Trigger Finger"
ChaosModifierItchyTriggerFinger.run_as_client = true
ChaosModifierItchyTriggerFinger.duration = 40

function ChaosModifierItchyTriggerFinger:start()
	self._state = true

	Hooks:PostHook(PlayerStandard, "_get_input", self.class_name, function(playerstate, t)
		if self._next_t and self._next_t < t then
			self._state = not self._state
			self._next_t = t + (self._state and math.rand(0, 0.2) or math.rand(5, 9))
		end

		if self._state then
			local input = Hooks:GetReturn()
			input.btn_primary_attack_press = true
			input.btn_primary_attack_state = true
		end
	end)
end

function ChaosModifierItchyTriggerFinger:stop()
	Hooks:RemovePostHook(self.class_name)
end

return ChaosModifierItchyTriggerFinger
