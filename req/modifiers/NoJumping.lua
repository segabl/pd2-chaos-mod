ChaosModifierNoJumping = ChaosModifier.class("ChaosModifierNoJumping")
ChaosModifierNoJumping.run_as_client = true
ChaosModifierNoJumping.duration = 40

function ChaosModifierNoJumping:start()
	self:post_hook(PlayerStandard, "_get_input", function()
		local input = Hooks:GetReturn()
		input.btn_jump_press = false
	end)
end

return ChaosModifierNoJumping
