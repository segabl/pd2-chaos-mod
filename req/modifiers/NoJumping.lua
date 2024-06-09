ChaosModifierNoJumping = ChaosModifier.class("ChaosModifierNoJumping")
ChaosModifierNoJumping.duration = 40

function ChaosModifierNoJumping:start()
	self:post_hook(PlayerStandard, "_get_input", function()
		Hooks:GetReturn().btn_jump_press = false
	end)
end

return ChaosModifierNoJumping
