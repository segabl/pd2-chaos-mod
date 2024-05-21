---@class ChaosModifierNoJumping : ChaosModifier
ChaosModifierNoJumping = class(ChaosModifier)
ChaosModifierNoJumping.class_name = "ChaosModifierNoJumping"
ChaosModifierNoJumping.run_as_client = true
ChaosModifierNoJumping.duration = 40

function ChaosModifierNoJumping:start()
	Hooks:PostHook(PlayerStandard, "_get_input", self.class_name, function()
		local input = Hooks:GetReturn()
		input.btn_jump_press = false
		return input
	end)
end

function ChaosModifierNoJumping:stop()
	Hooks:RemovePostHook(self.class_name)
end

return ChaosModifierNoJumping
