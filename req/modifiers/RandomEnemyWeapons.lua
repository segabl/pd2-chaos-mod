---@class ChaosModifierRandomEnemyWeapons : ChaosModifier
ChaosModifierRandomEnemyWeapons = class(ChaosModifier)
ChaosModifierRandomEnemyWeapons.class_name = "ChaosModifierRandomEnemyWeapons"
ChaosModifierRandomEnemyWeapons.name = "Diverse Armament"
ChaosModifierRandomEnemyWeapons.duration = 90

function ChaosModifierRandomEnemyWeapons:start()
	Hooks:PreHook(CopBase, "post_init", self.class_name, function(copbase)
		if not self.available_weapons then
			self.available_weapons = {}
			for i, unit_name in pairs(tweak_data.character.weap_unit_names) do
				if PackageManager:has(Idstring("unit"), unit_name) then
					table.insert(self.available_weapons, tweak_data.character.weap_ids[i])
				end
			end
		end
		copbase._default_weapon_id = table.random(self.available_weapons) or copbase._default_weapon_id
	end)
end

function ChaosModifierRandomEnemyWeapons:stop()
	Hooks:RemovePreHook(self.class_name)
end

return ChaosModifierRandomEnemyWeapons
