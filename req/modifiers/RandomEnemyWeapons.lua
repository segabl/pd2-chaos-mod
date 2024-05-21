ChaosModifierRandomEnemyWeapons = ChaosModifier.class("ChaosModifierRandomEnemyWeapons")
ChaosModifierRandomEnemyWeapons.duration = 90

function ChaosModifierRandomEnemyWeapons:start()
	self:pre_hook(CopBase, "post_init", function(copbase)
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

return ChaosModifierRandomEnemyWeapons
