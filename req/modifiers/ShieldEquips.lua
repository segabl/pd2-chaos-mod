ChaosModifierShieldEquips = ChaosModifier.class("ChaosModifierShieldEquips")
ChaosModifierShieldEquips.register_name = "ChaosModifierAttackRestriction"
ChaosModifierShieldEquips.loud_only = true
ChaosModifierShieldEquips.duration = 90

function ChaosModifierShieldEquips:start()
	self._shield_units = {}
	self._shield_ids = Idstring("units/payday2/characters/ene_acc_shield_small/shield_small")

	for _, stance_type in pairs(tweak_data.player.stances) do
		for pose_name, pose in pairs(stance_type) do
			self:override(pose, "zoom_fov", false)
			if pose.shoulders and pose_name ~= "bipod" then
				local steelsight = pose_name == "steelsight"
				self:override(pose.shoulders, "translation", Vector3(20, steelsight and -20 or 0, steelsight and -20 or -10))
				self:override(pose.shoulders, "rotation", Rotation(0, 0, 0))
			end
		end
	end

	for _, part_data in pairs(tweak_data.weapon.factory.parts) do
		self:override(part_data, "stance_mod", nil)
	end

	self:post_hook(PlayerStandard, "_update_reload_timers", function(playerstate)
		if not playerstate._chaos_reload_unequip and (playerstate._state_data.reload_expire_t or playerstate._state_data.reload_enter_expire_t) then
			playerstate._chaos_reload_unequip = true
			playerstate._ext_camera:play_redirect(playerstate:get_animation("unequip"), 5)
		elseif playerstate._chaos_reload_unequip and not playerstate._state_data.reload_expire_t and not playerstate._state_data.reload_enter_expire_t then
			playerstate._chaos_reload_unequip = nil
			playerstate._ext_camera:play_redirect(playerstate:get_animation("equip"), 5)
		end
	end)

	self:override(PlayerStandard, "get_weapon_hold_str", function()
		return "breech"
	end)

	self:post_hook(PlayerInventory, "_align_place", function(inventory)
		if inventory._unit == managers.player:local_player() and Hooks:GetReturn() == inventory._align_places.left_hand then
			return inventory._align_places.right_hand
		end
	end)

	self:post_hook(PlayerStandard, "get_zoom_fov", function(playerstate)
		if playerstate._state_data.in_steelsight then
			return 90
		end
	end)

	self:override(PlayerStandard, "_play_distance_interact_redirect", function() end)

	self:post_hook(PlayerStandard, "_get_input", function(playerstate)
		local input = Hooks:GetReturn()
		input.btn_melee_press = false
		input.btn_melee_release = false
		input.btn_meleet_state = false
		if playerstate._state_data.in_steelsight then
			input.btn_primary_attack_press = false
			input.btn_primary_attack_state = false
			input.btn_primary_attack_release = false
		end
		if playerstate._chaos_reload_unequip then
			input.btn_throw_grenade_press = false
			input.btn_projectile_press = false
			input.btn_projectile_release = false
			input.btn_projectile_state = false
		end
	end)

	self:post_hook(PlayerStandard, "inventory_clbk_listener", function()
		self:update_ignore_unit()
	end)

	self:post_hook(NewRaycastWeaponBase, "recoil", function()
		return 2 + Hooks:GetReturn() * 2
	end)

	self:update_stance()
end

function ChaosModifierShieldEquips:update_stance()
	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local playerstate = player_unit:movement():current_state()
	playerstate:set_animation_weapon_hold()
	playerstate:_stance_entered()
	player_unit:camera():play_redirect(playerstate:get_animation("equip"), 5)
	if player_unit:inventory():equipped_selection() then
		player_unit:inventory():_place_selection(player_unit:inventory():equipped_selection(), true)
	end
end

function ChaosModifierShieldEquips:update_ignore_unit()
	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local weapon_unit = player_unit:inventory():equipped_unit()
	if not alive(weapon_unit) then
		return
	end

	local shield_unit = self._shield_units[player_unit:key()]
	if alive(shield_unit) then
		weapon_unit:base():add_ignore_unit(shield_unit)
	elseif shield_unit then
		weapon_unit:base():remove_ignore_unit(shield_unit)
	end
end

function ChaosModifierShieldEquips:update(t, dt)
	local player_unit = managers.player:local_player()
	for u_key, data in pairs(managers.groupai:state():all_char_criminals()) do
		local is_local_player = data.unit == player_unit

		if not alive(data.unit) then
		elseif not alive(self._shield_units[u_key]) then
			local link_unit = is_local_player and data.unit:camera():camera_unit() or data.unit
			local link_obj = is_local_player and link_unit:orientation_object() or link_unit:orientation_object()

			self._shield_units[u_key] = World:spawn_unit(self._shield_ids, link_obj:position(), link_obj:rotation())

			self._shield_units[u_key]:set_slot(35)
			self._shield_units[u_key]:damage():run_sequence_simple("enable_body")
			self._shield_units[u_key]:body("dropped_body"):set_keyframed()

			link_unit:link(link_obj:name(), self._shield_units[u_key], self._shield_units[u_key]:orientation_object():name())

			if is_local_player then
				self:update_ignore_unit()
			else
				self._shield_units[u_key]:set_local_position(Vector3(-5, 50, 125))
				self._shield_units[u_key]:set_local_rotation(Rotation(30, 0, 0))
			end

			data.unit:base():add_destroy_listener(tostring(u_key) .. "destroy_shield", function()
				if alive(self._shield_units[u_key]) then
					World:delete_unit(self._shield_units[u_key])
					self._shield_units[u_key] = nil
				end
			end)
		elseif is_local_player then
			local target_pos, target_rot
			local current_state = player_unit:movement():current_state()
			if current_state:_is_throwing_projectile() then
				target_pos = Vector3(-100, 0, 0)
				target_rot = Rotation(90, 0, 0)
			elseif current_state:in_steelsight() then
				target_pos = Vector3(-4, 30, 0)
				target_rot = Rotation(0, 0, 0)
			else
				target_pos = Vector3(-35, 20, 0)
				target_rot = Rotation(60, 5, 0)
			end

			local pos = self._shield_units[u_key]:local_position()
			local rot = self._shield_units[u_key]:local_rotation()

			local dt = managers.player:player_timer():delta_time()
			mvector3.lerp(pos, pos, target_pos, dt * 10)
			mrotation.slerp(rot, rot, target_rot, dt * 10)

			self._shield_units[u_key]:set_local_position(pos)
			self._shield_units[u_key]:set_local_rotation(rot)
		end
	end
end

function ChaosModifierShieldEquips:stop()
	self:update_stance()

	for _, shield_unit in pairs(self._shield_units) do
		if alive(shield_unit) then
			World:delete_unit(shield_unit)
		end
	end

	self:update_ignore_unit()
end

return ChaosModifierShieldEquips
