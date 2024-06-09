ChaosModifierInterruptInteractions = ChaosModifier.class("ChaosModifierInterruptInteractions")
ChaosModifierInterruptInteractions.duration = 30

function ChaosModifierInterruptInteractions:start()
	self:post_hook(PlayerStandard, "_get_input", function(playerstate, t)
		if not self._next_t or self._next_t < t then
			self._next_t = t + math.rand(1, 8)
			local input = Hooks:GetReturn()
			input.btn_interact_press = false
			input.btn_interact_release = false
			input.btn_interact_state = false
			input.btn_use_item_press = false
			input.btn_use_item_release = false
			input.btn_use_item_state = false
			playerstate:_interupt_action_interact(t, input)
			playerstate:_interupt_action_use_item(t, input)
		end
	end)
end

return ChaosModifierInterruptInteractions
