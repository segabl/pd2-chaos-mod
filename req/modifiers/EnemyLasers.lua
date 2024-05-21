ChaosModifierEnemyLasers = ChaosModifier.class("ChaosModifierEnemyLasers")
ChaosModifierEnemyLasers.run_as_client = true
ChaosModifierEnemyLasers.duration = 60

function ChaosModifierEnemyLasers:set_laser_enabled(unit, enabled)
	local weapon = alive(unit) and unit:inventory():equipped_unit()
	if not alive(weapon) or not weapon:base().set_laser_enabled then
		return
	end

	if unit:base():char_tweak().weapon[weapon:base():weapon_tweak_data().usage].use_laser and not enabled then
		return
	end

	weapon:base():set_laser_enabled(enabled)
	unit:base():prevent_main_bones_disabling(enabled)
end

function ChaosModifierEnemyLasers:start()
	for _, data in pairs(managers.enemy:all_enemies()) do
		self:set_laser_enabled(data.unit, true)
	end

	self:pre_hook(NPCRaycastWeaponBase, "destroy", function(weaponbase)
		weaponbase:set_laser_enabled(false)
	end)

	self:post_hook(PlayerInventory, "_place_selection", function(inventory, selection_index, is_equip)
		self:set_laser_enabled(inventory._unit, is_equip)
	end)

	self:pre_hook(CopInventory, "drop_weapon", function(inventory)
		self:set_laser_enabled(inventory._unit, false)
	end)
end

function ChaosModifierEnemyLasers:stop()
	for _, data in pairs(managers.enemy:all_enemies()) do
		self:set_laser_enabled(data.unit, false)
	end
end

return ChaosModifierEnemyLasers
