ChaosModifierLongerModifiers = ChaosModifier.class("ChaosModifierLongerModifiers")
ChaosModifierLongerModifiers.duration = 60

function ChaosModifierLongerModifiers:start()
	self:post_hook(ChaosModifier, "init", function(modifier)
		if not modifier.fixed_duration then
			modifier.duration = modifier.duration * 2
		end
	end)
end

return ChaosModifierLongerModifiers
