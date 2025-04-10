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

	unit:movement():set_team(managers.groupai:state():team_data("criminal1"))

	local brain = unit:brain()
	local attention = PlayerMovement._create_attention_setting_from_descriptor(brain, tweak_data.attention.settings.team_enemy_cbt, "team_enemy_cbt")
	brain._attention_handler:override_attention("enemy_team_cbt", attention)
	brain._slotmask_enemies = managers.slot:get_mask("enemies")
	brain._logic_data.enemy_slotmask = brain._slotmask_enemies
	brain._logic_data.objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_complete")
	brain._logic_data.objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_failed")

	unit:contour():add("generic_interactable_selected", true)

	local u_key = unit:key()
	local listener_key = self.class_name .. tostring(u_key)

	unit:character_damage():set_invulnerable(true)
	unit:network():send("set_unit_invulnerable", true, false)

	DelayedCalls:Add(tostring(u_key) .. "invulnerable", 15, function()
		if alive(unit) then
			unit:character_damage():set_invulnerable(false)
			unit:network():send("set_unit_invulnerable", false, false)
		end
	end)

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
