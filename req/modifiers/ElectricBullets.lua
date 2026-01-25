ChaosModifierElectricBullets = ChaosModifier.class("ChaosModifierElectricBullets")
ChaosModifierElectricBullets.tags = { "BulletChange" }
ChaosModifierElectricBullets.conflict_tags = { "BulletChange" }
ChaosModifierElectricBullets.stealth_safe = false
ChaosModifierElectricBullets.duration = 30

function ChaosModifierElectricBullets:start()
	local ref_dmg = math.max(tweak_data.character.heavy_swat.weapon.is_rifle.FALLOFF[1].dmg_mul, tweak_data.character.swat.weapon.is_rifle.FALLOFF[1].dmg_mul) * tweak_data.weapon.m4_npc.DAMAGE

	local ElectricBulletBase = class(InstantBulletBase)
	function ElectricBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, ...)
		if not col_ray.unit then
			return
		end

		if col_ray.unit:character_damage().on_non_lethal_electrocution then
			if not PlayerDamage._chk_dmg_too_soon(col_ray.unit:character_damage(), damage) and math.random() < damage / ref_dmg then
				col_ray.unit:character_damage():on_non_lethal_electrocution(math.min((damage / ref_dmg) * 0.005, 0.01))
			end
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
