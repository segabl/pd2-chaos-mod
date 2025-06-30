ChaosModifierGangstaGrip = ChaosModifier.class("ChaosModifierGangstaGrip")
ChaosModifierGangstaGrip.duration = 60

function ChaosModifierGangstaGrip:start()
	for _, stance_type in pairs(tweak_data.player.stances) do
		for pose_name, pose in pairs(stance_type) do
			if pose.shoulders and pose_name ~= "bipod" then
				self:override(pose.shoulders, "translation", Vector3(10, pose_name == "crouched" and 5 or 10, -25))
				self:override(pose.shoulders, "rotation", Rotation(0, 0, pose_name == "crouched" and -105 or -95))
			end
		end
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

	self:post_hook(PlayerStandard, "_get_input", function(playerstate)
		if not playerstate._chaos_reload_unequip then
			return
		end

		local input = Hooks:GetReturn()
		input.btn_throw_grenade_press = false
		input.btn_projectile_press = false
		input.btn_projectile_release = false
		input.btn_projectile_state = false
	end)

	self:post_hook(PlayerInventory, "_align_place", function(inventory)
		if inventory._unit == managers.player:local_player() and Hooks:GetReturn() == inventory._align_places.left_hand then
			return inventory._align_places.right_hand
		end
	end)

	self:post_hook(BlackMarketManager, "threat_multiplier", function()
		return Hooks:GetReturn() * 10
	end)

	self:post_hook(CopLogicBase, "_evaluate_reason_to_surrender", function()
		local hold_chance = Hooks:GetReturn()
		if hold_chance then
			return hold_chance * 0.5
		end
	end)

	self:update_stance()
end

function ChaosModifierGangstaGrip:update_stance()
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

function ChaosModifierGangstaGrip:stop()
	self:update_stance()
end

return ChaosModifierGangstaGrip
