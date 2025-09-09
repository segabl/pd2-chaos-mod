ChaosModifierShoutToKill = ChaosModifier.class("ChaosModifierShoutToKill")
ChaosModifierShoutToKill.conflict_tags = { "NoGunsUsable" }
ChaosModifierShoutToKill.duration = 45

function ChaosModifierShoutToKill:start()
	local function kill_func(unit, aggressor_unit, ...)
		if aggressor_unit ~= managers.player:local_player() then
			return
		end

		local hit_pos = unit:movement():m_com()
		local dir = Vector3()
		local distance = mvector3.direction(dir, aggressor_unit:movement():m_com(), hit_pos)
		local blocked = World:raycast("ray", aggressor_unit:movement():m_com(), hit_pos, "slot_mask", managers.slot:get_mask("enemy_shield_check"))
		DelayedCalls:Add(tostring(unit:key()) .. "force", 0.15, function()
			if not alive(unit) or not alive(aggressor_unit) then
				return
			end

			unit:character_damage():damage_melee({
				damage_effect = 1,
				damage = blocked and alive(blocked.unit) and alive(blocked.unit:parent()) and 0 or tweak_data.character.spooc.HEALTH_INIT * 1.5,
				variant = "counter_spooc",
				attacker_unit = aggressor_unit,
				col_ray = {
					body = unit:movement()._obj_spine,
					position = hit_pos
				},
				attack_dir = dir,
				name_id = managers.blackmarket:equipped_melee_weapon()
			})

			if unit:character_damage():dead() then
				managers.game_play_central:_do_shotgun_push(unit, hit_pos, dir, distance * 0.01, aggressor_unit)
				managers.network:session():send_to_peers_synched("sync_shotgun_push", unit, hit_pos, dir, distance * 0.01, aggressor_unit)
			end

			World:effect_manager():spawn({
				effect = Idstring("effects/particles/explosions/explosion_smoke_grenade"),
				position = hit_pos,
				normal = math.UP
			})
		end)
		aggressor_unit:camera():play_shaker("player_exit_zipline", 2)
	end

	self:override(CopBrain, "on_intimidated", function(copbrain, amount, aggressor_unit, ...)
		if copbrain._unit:movement():team().foes.criminal1 then
			return kill_func(copbrain._unit, aggressor_unit)
		end
		return self:get_override(CopBrain, "on_intimidated")(copbrain, amount, aggressor_unit, ...)
	end)

	self:override(HuskCopBrain, "on_intimidated", function(copbrain, amount, aggressor_unit, ...)
		if copbrain._unit:movement():team().foes.criminal1 then
			return kill_func(copbrain._unit, aggressor_unit)
		end
		return self:get_override(HuskCopBrain, "on_intimidated")(copbrain, amount, aggressor_unit, ...)
	end)

	self:override(PlayerSound, "say", function(playersound, sound_name, ...)
		if type(sound_name) == "string" and sound_name:match("^l0[1-3]x") then
			playersound:play("concussion_explosion")
		else
			return self:get_override(PlayerSound, "say")(playersound, sound_name, ...)
		end
	end)

	self:post_hook(PlayerStandard, "_get_input", function()
		local input = Hooks:GetReturn()
		if not managers.interaction:active_unit() and input.btn_primary_attack_press then
			input.btn_interact_press = true
			input.btn_interact_release = true
		end
		input.btn_primary_attack_press = false
		input.btn_primary_attack_state = false
		input.btn_primary_attack_release = false
	end)

	self:override(PlayerStandard, "_add_unit_to_char_table", function(playerstate, char_table, unit, unit_type, interaction_dist, interaction_through_walls, tight_area, priority, my_head_pos, cam_fwd, ray_ignore_units, _, ...)
		return self:get_override(PlayerStandard, "_add_unit_to_char_table")(playerstate, char_table, unit, unit_type, interaction_dist, interaction_through_walls, tight_area, priority, my_head_pos, cam_fwd, ray_ignore_units, "ai_vision", ...)
	end)

	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		self:override(enemy, "priority_shout", nil)
		if not enemy.surrender then
			self:override(enemy, "surrender", tweak_data.character.presets.surrender.special)
		end
	end
end

return ChaosModifierShoutToKill
