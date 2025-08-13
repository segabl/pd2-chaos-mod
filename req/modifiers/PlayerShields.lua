ChaosModifierPlayerShields = ChaosModifier.class("ChaosModifierPlayerShields")
ChaosModifierPlayerShields.loud_only = true
ChaosModifierPlayerShields.run_as_client = false
ChaosModifierPlayerShields.duration = -1

function ChaosModifierPlayerShields:can_trigger()
	return table.size(managers.groupai:state():all_player_criminals()) > 0
end

function ChaosModifierPlayerShields:start()
	self._units = {}

	self:post_hook(GroupAIStateBase, "_determine_objective_for_criminal_AI", function(gstate, unit)
		local data = self._units[unit:key()]
		if data and alive(data.player_unit) and data.player_unit:movement():nav_tracker() then
			return self:get_follow_objective(data.player_unit)
		end
	end)

	self:post_hook(GroupAIStateBase, "on_criminal_jobless", function(gstate, unit)
		local data = self._units[unit:key()]
		if not data then
			return
		end

		local criminal_record = alive(data.player_unit) and gstate:criminal_record(data.player_unit:key())
		if not criminal_record then
			unit:character_damage():set_invulnerable(false)
			unit:character_damage():damage_mission({})
		end
	end)

	local _upd_enemy_detection = ShieldLogicAttack._upd_enemy_detection
	self:override(ShieldLogicAttack, "_upd_enemy_detection", function(data, ...)
		if not self._units[data.key] or not data.objective or not alive(data.objective.follow_unit) then
			return _upd_enemy_detection(data, ...)
		end

		CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)

		local my_data = data.internal_data
		local new_attention, _, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)
		CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
		CopLogicAttack._chk_exit_attack_logic(data, data.attention_obj and data.attention_obj.reaction)

		if my_data ~= data.internal_data then
			return
		end

		ShieldLogicAttack._upd_aim(data, my_data)

		if not new_attention then
			return
		end

		local target_pos = Vector3()
		local follow_pos = data.objective.follow_unit:movement():nav_tracker():field_position()

		mvector3.direction(target_pos, follow_pos, new_attention.m_pos)
		mvector3.multiply(target_pos, 300)
		mvector3.add(target_pos, follow_pos)

		local params = {
			trace = true,
			pos_from = follow_pos,
			pos_to = target_pos,
			allow_entry = true
		}
		local blocked = managers.navigation:raycast(params)
		local optimal_pos = params.trace[1]

		local current_pos = my_data.going_to_optimal_pos or data.m_pos
		local dis = mvector3.distance(optimal_pos, current_pos)
		local dis_mul = math.max(1, math.abs(current_pos.z - optimal_pos.z) / 100)
		if dis < 50 or mvector3.distance(optimal_pos, follow_pos) < 100 then
			return
		elseif dis * dis_mul > 1000 or dis > 300 and mvector3.distance(data.m_pos, follow_pos) < dis then
			ShieldLogicAttack._cancel_optimal_attempt(data, my_data)
		elseif my_data.walking_to_optimal_pos then
			return
		end

		my_data.going_to_optimal_pos = optimal_pos
		if blocked or math.abs(optimal_pos.z - data.m_pos.z) > 100 then
			my_data.pathing_to_optimal_pos = true
			my_data.optimal_path_search_id = tostring(data.key) .. "optimal"
			data.brain:search_for_path(my_data.optimal_path_search_id, optimal_pos)
		else
			my_data.optimal_path = {
				mvector3.copy(data.m_pos),
				optimal_pos
			}
		end
	end)

	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if alive(data.unit) then
			self:spawn_unit(data.unit)
		end
	end
end

function ChaosModifierPlayerShields:stop()
	for _, data in pairs(self._units) do
		if alive(data.unit) and not data.unit:character_damage():dead() then
			data.unit:character_damage():set_invulnerable(false)
			data.unit:character_damage():damage_mission({})
		end
	end
end

function ChaosModifierPlayerShields:get_follow_objective(player_unit)
	return {
		type = "follow",
		scan = true,
		follow_unit = player_unit,
		distance = 500
	}
end

function ChaosModifierPlayerShields:set_player_team(unit)
	local brain = unit:brain()

	local settings = tweak_data.attention.settings.team_enemy_cbt
	local attention_preset = PlayerMovement._create_attention_setting_from_descriptor(brain, settings, "team_enemy_cbt")

	brain._attention_handler:override_attention("enemy_team_cbt", attention_preset)

	brain._logic_data.attention_obj = nil

	CopLogicBase._destroy_all_detected_attention_object_data(brain._logic_data)

	brain._SO_access = managers.navigation:convert_access_flag(tweak_data.character.russian.access)
	brain._logic_data.SO_access = brain._SO_access
	brain._logic_data.SO_access_str = tweak_data.character.russian.access
	brain._slotmask_enemies = managers.slot:get_mask("enemies")
	brain._logic_data.enemy_slotmask = brain._slotmask_enemies

	brain:set_objective(nil)
	brain:set_logic("idle", nil)

	brain._logic_data.objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_complete")
	brain._logic_data.objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_failed")

	brain._unit:base():set_slot(brain._unit, 16)
	brain._unit:movement():set_stance("hos")

	managers.groupai:state()._police[unit:key()].so_access = brain._SO_access

	unit:movement():set_team(managers.groupai:state():team_data("criminal1"))
end

function ChaosModifierPlayerShields:spawn_unit(player_unit)
	local player_pos = player_unit:movement():m_pos()
	local player_fwd_flat = player_unit:movement():detect_look_dir():with_z(0):normalized()

	local params = {
		trace = true,
		pos_from = player_pos + player_fwd_flat * 50,
		pos_to = player_pos + player_fwd_flat * 250
	}
	managers.navigation:raycast(params)

	local unit_name = tweak_data.group_ai.unit_categories.FBI_shield.unit_types[tweak_data.levels:get_ai_group_type()][1]
	local unit = World:spawn_unit(unit_name, params.trace[1], Rotation(player_fwd_flat, math.UP))

	self:set_player_team(unit)

	unit:contour():add("generic_interactable_selected", true)

	local u_key = unit:key()
	local listener_key = self.class_name .. tostring(u_key)

	unit:character_damage():set_invulnerable(true)
	unit:network():send("set_unit_invulnerable", true, false)

	DelayedCalls:Add(tostring(u_key) .. "invulnerable", 20, function()
		if alive(unit) then
			unit:character_damage():set_invulnerable(false)
			unit:network():send("set_unit_invulnerable", false, false)
		end
	end)

	unit:character_damage()._damage_reduction_multiplier = 0.5
	unit:character_damage():add_listener(listener_key, { "death" }, function()
		unit:contour():remove("generic_interactable_selected", true)
		self._units[u_key] = nil
	end)

	unit:base():add_destroy_listener(listener_key, function()
		self._units[u_key] = nil
	end)

	self._units[u_key] = {
		unit = unit,
		player_unit = player_unit
	}

	managers.groupai:state():on_criminal_jobless(unit)
end

function ChaosModifierPlayerShields:expired(t, dt)
	if ChaosModifierPlayerShields.super.expired(self, t, dt) then
		return true
	elseif Network:is_server() then
		for _, data in pairs(self._units) do
			if alive(data.unit) and not data.unit:character_damage():dead() then
				return false
			end
		end
		return true
	end
end

return ChaosModifierPlayerShields
