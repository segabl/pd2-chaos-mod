ChaosModifierMaxModifiers = ChaosModifier.class("ChaosModifierMaxModifiers")
ChaosModifierMaxModifiers.run_as_client = false

function ChaosModifierMaxModifiers:can_trigger()
	return ChaosMod.settings.max_active > 1 and table.size(ChaosMod.active_modifiers) == 0
end

function ChaosModifierMaxModifiers:start()
	for _ = 1, ChaosMod.settings.max_active do
		ChaosMod:activate_modifier()
	end
end

return ChaosModifierMaxModifiers
