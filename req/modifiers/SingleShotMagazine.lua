ChaosModifierSingleShotMagazine = ChaosModifier.class("ChaosModifierSingleShotMagazine")
ChaosModifierSingleShotMagazine.duration = 20

function ChaosModifierSingleShotMagazine:start()
	self:override(NewRaycastWeaponBase, "set_ammo_remaining_in_clip", function(weaponbase, ammo_remaining_in_clip, ...)
		if not weaponbase:is_npc() and ammo_remaining_in_clip < (weaponbase:get_ammo_remaining_in_clip() or 0) then
			ammo_remaining_in_clip = 0
		end
		return self:get_override(NewRaycastWeaponBase, "set_ammo_remaining_in_clip")(weaponbase, ammo_remaining_in_clip, ...)
	end)

	self:override(NewRaycastWeaponBase, "fire", function(weaponbase, from_pos, direction, dmg_mul, ...)
		return self:get_override(NewRaycastWeaponBase, "fire")(weaponbase, from_pos, direction, dmg_mul * weaponbase:get_ammo_remaining_in_clip(), ...)
	end)

	self:post_hook(NewRaycastWeaponBase, "reload_speed_multiplier", function(weaponbase)
		return Hooks:GetReturn() * (1 + (weaponbase:get_ammo_max_per_clip() - 1) * 0.05)
	end)
end

return ChaosModifierSingleShotMagazine
