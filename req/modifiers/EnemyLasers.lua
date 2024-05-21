---@class ChaosModifierEnemyLasers : ChaosModifier
ChaosModifierEnemyLasers = class(ChaosModifier)
ChaosModifierEnemyLasers.class_name = "ChaosModifierEnemyLasers"
ChaosModifierEnemyLasers.duration = 60
ChaosModifierEnemyLasers.run_as_client = true

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

	Hooks:PreHook(NPCRaycastWeaponBase, "destroy", self.class_name, function(weaponbase)
		weaponbase:set_laser_enabled(false)
	end)

	Hooks:PostHook(PlayerInventory, "_place_selection", self.class_name, function(inventory, selection_index, is_equip)
		self:set_laser_enabled(inventory._unit, is_equip)
	end)

	Hooks:PreHook(CopInventory, "drop_weapon", self.class_name, function(inventory)
		self:set_laser_enabled(inventory._unit, false)
	end)
end

function ChaosModifierEnemyLasers:stop()
	for _, data in pairs(managers.enemy:all_enemies()) do
		self:set_laser_enabled(data.unit, false)
	end

	Hooks:RemovePreHook(self.class_name)
	Hooks:RemovePostHook(self.class_name)
end

return ChaosModifierEnemyLasers
