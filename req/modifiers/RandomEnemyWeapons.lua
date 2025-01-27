ChaosModifierRandomEnemyWeapons = ChaosModifier.class("ChaosModifierRandomEnemyWeapons")
ChaosModifierRandomEnemyWeapons.register_name = "ChaosModifierEnemyWeapons"
ChaosModifierRandomEnemyWeapons.run_as_client = false
ChaosModifierRandomEnemyWeapons.loud_only = true
ChaosModifierRandomEnemyWeapons.color = "enemy_change"
ChaosModifierRandomEnemyWeapons.duration = 90

function ChaosModifierRandomEnemyWeapons:start()
	self.available_weapons = {}

	local unit_ids = Idstring("unit")
	for i, unit_name in pairs(tweak_data.character.weap_unit_names) do
		if PackageManager:has(unit_ids, unit_name) then
			table.insert(self.available_weapons, tweak_data.character.weap_ids[i])
		end
	end

	self:pre_hook(CopBase, "post_init", function(copbase)
		copbase._default_weapon_id = table.random(self.available_weapons) or copbase._default_weapon_id
	end)
end

return ChaosModifierRandomEnemyWeapons
