ChaosModifierAmmoCharge = ChaosModifier.class("ChaosModifierAmmoCharge")
ChaosModifierAmmoCharge.tags = { "ReloadRestriction" }
ChaosModifierAmmoCharge.conflict_tags = { "ReloadRestriction", "InfiniteAmmo" }
ChaosModifierAmmoCharge.loud_only = true
ChaosModifierAmmoCharge.duration = 60

function ChaosModifierAmmoCharge:start()
	self._next_ammo_gain = {}

	self:override(PlayerStandard, "_check_action_reload", function() end)
	self:override(PlayerStandard, "_start_action_reload_enter", function() end)
	self:override(PlayerStandard, "_start_action_reload", function() end)

	managers.player:register_message(Message.OnWeaponFired, self.class_name, callback(self, self, "on_weapon_fired"))
end

function ChaosModifierAmmoCharge:on_weapon_fired(weapon_unit)
	if not alive(weapon_unit) or weapon_unit ~= managers.player:equipped_weapon_unit() then
		return
	end

	local weapon_base = weapon_unit:base()
	local selection_index = weapon_base:selection_index()
	local next_ammo_gain = managers.player:player_timer():time() + weapon_base:weapon_fire_rate() + 1.001
	self._next_ammo_gain[selection_index] = math.max(next_ammo_gain, self._next_ammo_gain[selection_index] or 0)
end

function ChaosModifierAmmoCharge:update(t, dt)
	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local time = managers.player:player_timer():time()
	for selection_index, data in pairs(player_unit:inventory():available_selections() or {}) do
		if alive(data.unit) and time >= (self._next_ammo_gain[selection_index] or 0) then
			local weapon_base = data.unit:base()
			local clip_max, clip_current, total_current, total_max = weapon_base:ammo_info()
			if clip_max > clip_current and total_current > clip_current then
				weapon_base:ammo_base():set_ammo_remaining_in_clip(clip_current + 1)
				managers.hud:set_ammo_amount(selection_index, clip_max, clip_current + 1, total_current, total_max)
			end
			self._next_ammo_gain[selection_index] = time + managers.blackmarket:get_reload_time(weapon_base._name_id) / weapon_base:reload_speed_multiplier() * weapon_base:weapon_fire_rate()
		end
	end
end

function ChaosModifierAmmoCharge:stop()
	managers.player:unregister_message(Message.OnWeaponFired, self.class_name)
end

return ChaosModifierAmmoCharge
