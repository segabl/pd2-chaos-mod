ChaosModifierBurstFire = ChaosModifier.class("ChaosModifierBurstFire")
ChaosModifierBurstFire.tags = { "FireMode" }
ChaosModifierBurstFire.conflict_tags = { "FireMode", "NoGuns" }
ChaosModifierBurstFire.duration = 60

function ChaosModifierBurstFire:start()
	self._valid_modes = {
		[Idstring("single"):key()] = true,
		[Idstring("auto"):key()] = true
	}

	self:post_hook(NewRaycastWeaponBase, "start_shooting", function(weaponbase)
		if weaponbase._fire_mode and self._valid_modes[weaponbase._fire_mode:key()] then
			weaponbase._shooting_count = math.clamp(math.ceil(weaponbase:weapon_tweak_data().CLIP_AMMO_MAX / 10), 3, 10)
		end
	end)

	self:post_hook(NewRaycastWeaponBase, "stop_shooting", function(weaponbase)
		if not weaponbase._fire_mode or not self._valid_modes[weaponbase._fire_mode:key()] then
			return
		end

		weaponbase._next_fire_allowed = math.max(weaponbase._next_fire_allowed, weaponbase._unit:timer():time() + 0.35)
		weaponbase._shooting_count = 0
	end)

	self:post_hook(NewRaycastWeaponBase, "fire", function(weaponbase)
		if not weaponbase._fire_mode or not self._valid_modes[weaponbase._fire_mode:key()] then
			return
		end

		if weaponbase._bullets_fired and weaponbase._bullets_fired > 1 and not weaponbase:weapon_tweak_data().sounds.fire_single then
			weaponbase:_fire_sound()
		end
	end)

	self:post_hook(NewRaycastWeaponBase, "recoil", function(weaponbase)
		if weaponbase._fire_mode and self._valid_modes[weaponbase._fire_mode:key()] then
			return Hooks:GetReturn() * 0.5
		end
	end)

	self:override(NewRaycastWeaponBase, "trigger_held", function(weaponbase, ...)
		if not weaponbase._fire_mode or not self._valid_modes[weaponbase._fire_mode:key()] then
			return self:get_override(NewRaycastWeaponBase, "trigger_held")(weaponbase, ...)
		end

		if not weaponbase._shooting_count or weaponbase._shooting_count == 0 then
			return false
		end

		local fired = self:get_override(NewRaycastWeaponBase, "trigger_held")(weaponbase, ...)

		if weaponbase:ammo_base():get_ammo_remaining_in_clip() == 0 then
			weaponbase._shooting_count = 0
		elseif fired then
			local rate = weaponbase:weapon_fire_rate() / (weaponbase:fire_rate_multiplier() + weaponbase:weapon_fire_rate() * 2)
			weaponbase._next_fire_allowed = weaponbase._unit:timer():time() + rate
			weaponbase._shooting_count = weaponbase._shooting_count - 1
		end

		return fired
	end)

	self:override(PlayerStandard._primary_action_get_value.chk_start_fire, "single", PlayerStandard._primary_action_get_value.chk_start_fire.burst)
	self:override(PlayerStandard._primary_action_get_value.chk_start_fire, "auto", PlayerStandard._primary_action_get_value.chk_start_fire.burst)
	self:override(PlayerStandard._primary_action_get_value.fired, "single", PlayerStandard._primary_action_get_value.fired.burst)
	self:override(PlayerStandard._primary_action_get_value.fired, "auto", PlayerStandard._primary_action_get_value.fired.burst)
	self:override(PlayerStandard._primary_action_get_value.not_fired, "single", PlayerStandard._primary_action_get_value.not_fired.burst)
	self:override(PlayerStandard._primary_action_get_value.not_fired, "auto", PlayerStandard._primary_action_get_value.not_fired.burst)

	self:override(ProjectileBase, "check_time_cheat", function() return true end)
end

function ChaosModifierBurstFire:stop()
	local player = managers.player:local_player()
	if not alive(player) then
		return
	end

	local weapon = player:inventory():equipped_unit()
	if alive(weapon) and weapon:base()._fire_mode and self._valid_modes[weapon:base()._fire_mode:key()] then
		weapon:base()._shooting_count = 0
	end
end

return ChaosModifierBurstFire
