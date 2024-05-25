ChaosModifierEmptyReloadOnly = ChaosModifier.class("ChaosModifierEmptyReloadOnly")
ChaosModifierEmptyReloadOnly.run_as_client = true
ChaosModifierEmptyReloadOnly.duration = 30

function ChaosModifierEmptyReloadOnly:start()
	self:post_hook(PlayerStandard, "_get_input", function(playerstate)
		local input = Hooks:GetReturn()
		if input.btn_reload_press and playerstate._equipped_unit and not playerstate._equipped_unit:base():clip_empty() then
			input.btn_reload_press = false
		end
	end)
end

return ChaosModifierEmptyReloadOnly
