ChaosModifierRefreshModifers = ChaosModifier.class("ChaosModifierRefreshModifers")

function ChaosModifierRefreshModifers:can_trigger()
	return table.size(ChaosMod.active_modifiers) > 0
end

function ChaosModifierRefreshModifers:start()
	local t = ChaosMod:time()
	for _, modifier in pairs(ChaosMod.active_modifiers) do
		if modifier.duration > 0 and not modifier.fixed_duration then
			modifier._activation_t = t
		end
	end
end

return ChaosModifierRefreshModifers
