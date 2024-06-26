ChaosModifierConcussionBullets = ChaosModifier.class("ChaosModifierConcussionBullets")
ChaosModifierConcussionBullets.register_name = "ChaosModifierBulletChange"
ChaosModifierConcussionBullets.run_in_stealth = false
ChaosModifierConcussionBullets.duration = 30

function ChaosModifierConcussionBullets:start()
	local ConcussionBulletBase = class(InstantBulletBase)
	function ConcussionBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, ...)
		if not col_ray.unit then
			return
		end

		if math.random() < 0.25 then
			if col_ray.unit:character_damage().on_concussion then
				managers.environment_controller:set_concussion_grenade(col_ray.unit:movement():m_head_pos(), true, 0, 0, 0.1, true, true)
				col_ray.unit:character_damage():on_concussion(0.15, false, {
					min = 1,
					mul = 0.15,
					additional = 1
				})
			elseif col_ray.unit:character_damage().stun_hit then
				local base = col_ray.unit:base()
				if not base or not base.char_tweak or not base:char_tweak().immune_to_concussion then
					col_ray.unit:character_damage():stun_hit({
						variant = "stun",
						damage = 0,
						attacker_unit = user_unit,
						weapon_unit = weapon_unit,
						col_ray = col_ray
					})
				end
			end
		end

		return self.super.give_impact_damage(self, col_ray, weapon_unit, user_unit, damage, ...)
	end

	self:post_hook(RaycastWeaponBase, "bullet_class", function()
		return ConcussionBulletBase
	end)
end

return ChaosModifierConcussionBullets
