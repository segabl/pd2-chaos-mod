ChaosModifierEnemyLasers = ChaosModifier.class("ChaosModifierEnemyLasers")
ChaosModifierEnemyLasers.loud_only = true
ChaosModifierEnemyLasers.duration = 60

function ChaosModifierEnemyLasers:set_laser_enabled(unit, enabled)
	local weapon = alive(unit) and unit:inventory():equipped_unit()
	if not alive(weapon) or not weapon:base().set_laser_enabled or not unit:base().char_tweak then
		return
	end

	if unit:base():char_tweak().weapon[weapon:base():weapon_tweak_data().usage].use_laser and not enabled then
		return
	end

	weapon:base():set_laser_enabled(enabled)
	unit:base():prevent_main_bones_disabling(enabled)
end

function ChaosModifierEnemyLasers:start()
	self:pre_hook(NPCRaycastWeaponBase, "destroy", function(weaponbase)
		weaponbase:set_laser_enabled(false)
	end)

	self:pre_hook(CopInventory, "drop_weapon", function(inventory)
		self:set_laser_enabled(inventory._unit, false)
	end)

	self:post_hook(CopActionShoot, "init", function(action)
		self:set_laser_enabled(action._unit, Hooks:GetReturn())
	end)

	self:post_hook(CopActionShoot, "on_exit", function(action)
		self:set_laser_enabled(action._unit, false)
	end)
end

function ChaosModifierEnemyLasers:stop()
	for _, data in pairs(managers.enemy:all_enemies()) do
		self:set_laser_enabled(data.unit, false)
	end
end

return ChaosModifierEnemyLasers
