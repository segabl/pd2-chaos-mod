ChaosModifierElectricBullets = ChaosModifier.class("ChaosModifierElectricBullets")
ChaosModifierElectricBullets.register_name = "ChaosModifierBulletChange"
ChaosModifierElectricBullets.run_in_stealth = false
ChaosModifierElectricBullets.duration = 30

function ChaosModifierElectricBullets:start()
	local ElectricBulletBase = class(InstantBulletBase)
	function ElectricBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, ...)
		if not col_ray.unit then
			return
		end

		if col_ray.unit:character_damage().on_non_lethal_electrocution then
			col_ray.unit:character_damage():on_non_lethal_electrocution(0.005)
		elseif col_ray.unit:character_damage().damage_tase then
			col_ray.unit:character_damage():damage_tase({
				damage = 0,
				weapon_unit = weapon_unit,
				attacker_unit = user_unit,
				col_ray = col_ray,
				armor_piercing = armor_piercing,
				attack_dir = col_ray.ray,
				variant = "timed"
			})
		end

		return self.super.give_impact_damage(self, col_ray, weapon_unit, user_unit, damage, armor_piercing, ...)
	end

	self:post_hook(RaycastWeaponBase, "bullet_class", function()
		return ElectricBulletBase
	end)

	self:post_hook(CopActionHurt, "init", function(action)
		if Hooks:GetReturn() and action._action_desc.hurt_type == "taser_tased" and action._action_desc.variant == "timed" then
			action._tased_time = TimerManager:game():time() + 0.3
			action.update = action._upd_tased
		end
	end)
end

return ChaosModifierElectricBullets
