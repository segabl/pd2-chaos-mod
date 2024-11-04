ChaosModifierRandomEnemies = ChaosModifier.class("ChaosModifierRandomEnemies")
ChaosModifierRandomEnemies.register_name = "ChaosModifierUnitCategories"
ChaosModifierRandomEnemies.run_as_client = false
ChaosModifierRandomEnemies.run_in_stealth = false
ChaosModifierRandomEnemies.color = "enemy_change"
ChaosModifierRandomEnemies.duration = 60

function ChaosModifierRandomEnemies:start()
	self.available_enemies = {}

	local unit_ids = Idstring("unit")
	local exclude = {
		ene_bulldozer_4 = true,
		ene_vip_1 = true,
		ene_zeal_bulldozer_halloween = true
	}
	for _, category_data in pairs(tweak_data.character:character_map()) do
		for _, entry in pairs(category_data.list) do
			if not exclude[entry] and entry:match("^ene_") then
				local unit_name = Idstring(category_data.path .. entry .. "/" .. entry)
				if PackageManager:has(unit_ids, unit_name) then
					table.insert(self.available_enemies, unit_name)
					if not entry:match("dozer") then
						table.insert(self.available_enemies, unit_name)
						table.insert(self.available_enemies, unit_name)
						table.insert(self.available_enemies, unit_name)
					end
				end
			end
		end
	end

	local unit_types = setmetatable({}, {
		__index = function()
			return self.available_enemies
		end
	})

	for _, category_data in pairs(tweak_data.group_ai.unit_categories) do
		self:override(category_data, "unit_types", unit_types)
	end
end

return ChaosModifierRandomEnemies
