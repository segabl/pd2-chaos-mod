ChaosModifierGlassCannons = ChaosModifier.class("ChaosModifierGlassCannons")
ChaosModifierGlassCannons.register_name = "ChaosModifierUnitCategories"
ChaosModifierGlassCannons.duration = 60
ChaosModifierGlassCannons.unit_category = "CS_cop_stealth_MP5"

function ChaosModifierGlassCannons:can_trigger()
	return tweak_data.group_ai.unit_categories[self.unit_category] and true
end

function ChaosModifierGlassCannons:start()
	local unit_types = deep_clone(tweak_data.group_ai.unit_categories[self.unit_category].unit_types)
	for _, category in pairs(tweak_data.group_ai.unit_categories) do
		if not category.special_type then
			self:override(category, "unit_types", unit_types)
		end
	end
end

return ChaosModifierGlassCannons
