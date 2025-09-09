ChaosModifierInvincibleMedics = ChaosModifier.class("ChaosModifierInvincibleMedics")
ChaosModifierInvincibleMedics.run_as_client = false
ChaosModifierInvincibleMedics.loud_only = true
ChaosModifierInvincibleMedics.duration = 120

function ChaosModifierInvincibleMedics:can_trigger()
	for _, u_data in pairs(managers.enemy:all_enemies()) do
		if u_data.unit:base():has_tag("medic") then
			return true
		end
	end
end

function ChaosModifierInvincibleMedics:check_medic_state(unit, state)
	if unit:base():has_tag("medic") then
		unit:character_damage():set_invulnerable(state)
		unit:network():send("set_unit_invulnerable", state, unit:character_damage()._immortal)
		unit:movement():set_stance(state and "ntl" or "hos", true)
	end
end

function ChaosModifierInvincibleMedics:check_medic_weapon(unit)
	if unit:base():has_tag("medic") and not unit:base():has_tag("tank") then
		unit:inventory():_place_selection(unit:inventory():equipped_selection(), true)
	end
end

function ChaosModifierInvincibleMedics:start()
	self:post_hook(CopInventory, "_align_place", function(inventory)
		if inventory._unit:base().has_tag and inventory._unit:base():has_tag("medic") and not inventory._unit:base():has_tag("tank") then
			return inventory._align_places.back
		end
	end)

	for _, u_data in pairs(managers.enemy:all_enemies()) do
		self:check_medic_weapon(u_data.unit)
	end

	if not Network:is_server() then
		return
	end

	local allowed_poses = { stand = true }
	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		if enemy.tags and table.contains(enemy.tags, "medic") then
			self:override(enemy, "allowed_poses", allowed_poses)
		end
	end

	self:post_hook(CopBase, "post_init", function(base)
		self:check_medic_state(base._unit, true)
	end)

	for _, u_data in pairs(managers.enemy:all_enemies()) do
		self:check_medic_state(u_data.unit, true)
	end

	local react_func = function(data, attention_data)
		if attention_data.settings.reaction >= AIAttentionObject.REACT_AIM and data.unit:base():has_tag("medic") then
			return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_IDLE)
		end
	end

	self:post_hook(CopLogicArrest, "_chk_reaction_to_attention_object", react_func)
	self:post_hook(CopLogicFlee, "_chk_reaction_to_attention_object", react_func)
	self:post_hook(CopLogicIdle, "_chk_reaction_to_attention_object", react_func)
	self:post_hook(CopLogicSniper, "_chk_reaction_to_attention_object", react_func)

	self:override(CopMovement, "set_stance_by_code", function(movement, new_stance_code, ...)
		return self:get_override(CopMovement, "set_stance_by_code")(movement, movement._ext_base:has_tag("medic") and 1 or new_stance_code, ...)
	end)

	self:pre_hook(CopMovement, "action_request", function(movement, action_desc)
		if not movement._ext_base:has_tag("medic") then
			return
		end

		if action_desc.type == "walk" then
			action_desc.pose = "stand"
			action_desc.end_pose = "stand"
		elseif action_desc.type == "crouch" then
			action_desc.type = "stand"
		end
	end)

	self:pre_hook(GroupAIStateBesiege, "_upd_groups", function(gstate)
		local lonely_medics = {}
		local potential_groups = {}

		for _, e_data in pairs(managers.enemy:all_enemies()) do
			if alive(e_data.unit) and e_data.unit:base():has_tag("medic") then
				local logic_data = e_data.unit:brain()._logic_data
				if not logic_data.group then
					if logic_data.team and logic_data.team.foes.criminal1 then
						table.insert(lonely_medics, e_data.unit)
					end
				else
					local valid_group = true
					for _, u_data in pairs(logic_data.group.units) do
						if alive(u_data.unit) and not u_data.unit:base():has_tag("medic") then
							valid_group = false
							break
						end
					end
					if valid_group then
						gstate:unit_leave_group(e_data.unit, false)
						e_data.unit:brain():set_objective(nil)
						table.insert(lonely_medics, e_data.unit)
					end
				end
			end
		end

		for _, group in pairs(gstate._groups) do
			if group.has_spawned then
				local valid_group = true
				for _, u_data in pairs(group.units) do
					if alive(u_data.unit) and u_data.unit:base():has_tag("medic") then
						valid_group = false
						break
					end
				end
				if valid_group then
					table.insert(potential_groups, group)
				end
			end
		end

		while #lonely_medics > 0 and #potential_groups > 0 do
			local medic = table.remove(lonely_medics)
			local best_group_index
			local best_group_dis_sq = math.huge
			for i, group in pairs(potential_groups) do
				local _, u_data = next(group.units)
				local dis_sq = mvector3.distance_sq(medic:position(), u_data.m_pos)
				if dis_sq < best_group_dis_sq then
					best_group_dis_sq = dis_sq
					best_group_index = i
				end
			end
			local group = table.remove(potential_groups, best_group_index)
			gstate:assign_enemy_to_existing_group(medic, group)
			local logic_data = medic:brain()._logic_data
			logic_data.rank = logic_data.rank or 0
			logic_data.tactics = logic_data.tactics or {}
			logic_data.tactics.shield_cover = true
			logic_data.tactics.unit_cover = true
		end
	end)
end

function ChaosModifierInvincibleMedics:stop()
	for _, u_data in pairs(managers.enemy:all_enemies()) do
		self:check_medic_weapon(u_data.unit)
	end

	if not Network:is_server() then
		return
	end

	for _, u_data in pairs(managers.enemy:all_enemies()) do
		self:check_medic_state(u_data.unit, false)
	end
end

return ChaosModifierInvincibleMedics
