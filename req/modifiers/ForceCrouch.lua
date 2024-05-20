---@class ChaosModifierForceCrouch : ChaosModifier
ChaosModifierForceCrouch = class(ChaosModifier)
ChaosModifierForceCrouch.class_name = "ChaosModifierForceCrouch"
ChaosModifierForceCrouch.name = "True Slav"
ChaosModifierForceCrouch.run_as_client = true
ChaosModifierForceCrouch.duration = 20

function ChaosModifierForceCrouch:start()
	Hooks:PostHook(PlayerStandard, "_get_input", self.class_name, function(playerstate)
		local input = Hooks:GetReturn()
		input.btn_duck_press = playerstate._setting_hold_to_duck or not playerstate._state_data.ducking
		input.btn_duck_release = false
		return input
	end)
end

function ChaosModifierForceCrouch:stop()
	Hooks:RemovePostHook(self.class_name)
end

return ChaosModifierForceCrouch
