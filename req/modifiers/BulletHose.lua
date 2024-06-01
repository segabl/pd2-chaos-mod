ChaosModifierBulletHose = ChaosModifier.class("ChaosModifierBulletHose")
ChaosModifierBulletHose.run_as_client = true
ChaosModifierBulletHose.duration = 30

function ChaosModifierBulletHose:start()
	for i, spread in pairs(tweak_data.weapon.stats.spread) do
		self:override(tweak_data.weapon.stats.spread, i, 2 + spread * 4)
	end

	self:post_hook(NewRaycastWeaponBase, "weapon_fire_rate", function(weaponbase)
		if not weaponbase._projectile_type then
			local rate = Hooks:GetReturn()
			return rate * math.map_range_clamped(rate, 0, 2, 1, 0.25)
		end
	end)
end

function ChaosModifierBulletHose:update(t, dt)
	if not managers.player:has_active_temporary_property("bullet_storm") then
		managers.player:add_to_temporary_property("bullet_storm", self._activation_t + self.duration - t, 1)
	end
end

function ChaosModifierBulletHose:stop()
	managers.player:remove_temporary_property("bullet_storm")
end

return ChaosModifierBulletHose
