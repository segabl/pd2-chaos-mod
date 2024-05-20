---@class ChaosModifierGlassCannons : ChaosModifier
ChaosModifierGlassCannons = class(ChaosModifier)
ChaosModifierGlassCannons.class_name = "ChaosModifierGlassCannons"
ChaosModifierGlassCannons.register_name = "ChaosModifierUnitCategories"
ChaosModifierGlassCannons.name = "Glass Cannons"
ChaosModifierGlassCannons.duration = 60
ChaosModifierGlassCannons.unit_category = "CS_cop_stealth_MP5"

function ChaosModifierGlassCannons:can_trigger()
	return tweak_data.group_ai.unit_categories[self.unit_category] and true
end

function ChaosModifierGlassCannons:start()
	for _, category in pairs(tweak_data.group_ai.unit_categories) do
		if not category.special_type then
			category.original_unit_types = category.original_unit_types or category.unit_types
			category.unit_types = deep_clone(tweak_data.group_ai.unit_categories[self.unit_category].unit_types)
		end
	end
end

function ChaosModifierGlassCannons:stop()
	for _, category in pairs(tweak_data.group_ai.unit_categories) do
		if category.original_unit_types then
			category.unit_types = category.original_unit_types
			category.original_unit_types = nil
		end
	end
end

return ChaosModifierGlassCannons
