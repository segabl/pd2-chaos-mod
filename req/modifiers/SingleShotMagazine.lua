ChaosModifierSingleShotMagazine = ChaosModifier.class("ChaosModifierSingleShotMagazine")
ChaosModifierSingleShotMagazine.duration = 20

function ChaosModifierSingleShotMagazine:start()
	local set_ammo_remaining_in_clip_original = NewRaycastWeaponBase.set_ammo_remaining_in_clip
	self:override(NewRaycastWeaponBase, "set_ammo_remaining_in_clip", function(weaponbase, ammo_remaining_in_clip, ...)
		if not weaponbase:is_npc() and ammo_remaining_in_clip < (weaponbase:get_ammo_remaining_in_clip() or 0) then
			ammo_remaining_in_clip = 0
		end
		return set_ammo_remaining_in_clip_original(weaponbase, ammo_remaining_in_clip, ...)
	end)

	local fire_original = NewRaycastWeaponBase.fire
	self:override(NewRaycastWeaponBase, "fire", function(weaponbase, from_pos, direction, dmg_mul, ...)
		return fire_original(weaponbase, from_pos, direction, dmg_mul * weaponbase:get_ammo_remaining_in_clip(), ...)
	end)

	self:post_hook(NewRaycastWeaponBase, "reload_speed_multiplier", function(weaponbase)
		return Hooks:GetReturn() * (1 + weaponbase:get_ammo_max_per_clip() * 0.025)
	end)
end

return ChaosModifierSingleShotMagazine
