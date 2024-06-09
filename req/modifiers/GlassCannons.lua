ChaosModifierGlassCannons = ChaosModifier.class("ChaosModifierGlassCannons")
ChaosModifierGlassCannons.register_name = "ChaosModifierUnitCategories"
ChaosModifierGlassCannons.run_as_client = false
ChaosModifierGlassCannons.color = "enemy_change"
ChaosModifierGlassCannons.duration = 60
ChaosModifierGlassCannons.unit_categories = { "CS_cop_stealth_MP5" }

function ChaosModifierGlassCannons:can_trigger()
	for _, unit_category in pairs(self.unit_categories) do
		if not tweak_data.group_ai.unit_categories[unit_category] then
			return false
		end
	end
	return true
end

function ChaosModifierGlassCannons:start()
	local unit_types = setmetatable({}, {
		__index = function(t, k)
			return rawget(tweak_data.group_ai.unit_categories[table.random(self.unit_categories)].unit_types, k)
		end
	})

	local skip = table.list_to_set(self.unit_categories)
	for category_name, category in pairs(tweak_data.group_ai.unit_categories) do
		if not category.special_type and not skip[category_name] then
			self:override(category, "unit_types", unit_types)
		end
	end
end

return ChaosModifierGlassCannons
