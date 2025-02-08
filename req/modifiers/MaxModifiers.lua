ChaosModifierMaxModifiers = ChaosModifier.class("ChaosModifierMaxModifiers")
ChaosModifierMaxModifiers.run_as_client = false

function ChaosModifierMaxModifiers:can_trigger()
	return table.size(ChaosMod.active_modifiers) <= math.floor(ChaosMod.settings.max_active / 3)
end

function ChaosModifierMaxModifiers:start()
	for _ = table.size(ChaosMod.active_modifiers), ChaosMod.settings.max_active do
		ChaosMod:activate_modifier()
	end
end

return ChaosModifierMaxModifiers
