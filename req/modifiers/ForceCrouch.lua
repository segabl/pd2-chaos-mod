ChaosModifierForceCrouch = ChaosModifier.class("ChaosModifierForceCrouch")
ChaosModifierForceCrouch.run_as_client = true
ChaosModifierForceCrouch.duration = 20

function ChaosModifierForceCrouch:start()
	self:post_hook(PlayerStandard, "_get_input", function(playerstate)
		local input = Hooks:GetReturn()
		input.btn_duck_press = playerstate._setting_hold_to_duck or not playerstate._state_data.ducking
		input.btn_duck_release = false
		return input
	end)
end

return ChaosModifierForceCrouch
