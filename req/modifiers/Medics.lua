ChaosModifierMedics = ChaosModifier.class("ChaosModifierMedics", ChaosModifierGlassCannons)
ChaosModifierMedics.unit_categories = { "medic_M4", "medic_R870" }

function ChaosModifierMedics:start(...)
	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		if enemy and enemy.tags and table.contains(enemy.tags, "medic") then
			self:override(enemy, "can_be_healed", true)
		end
	end

	return ChaosModifierMedics.super.start(self, ...)
end

return ChaosModifierMedics
