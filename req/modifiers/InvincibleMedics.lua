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

	local set_stance_by_code = CopMovement.set_stance_by_code
	self:override(CopMovement, "set_stance_by_code", function(movement, new_stance_code, ...)
		return set_stance_by_code(movement, movement._ext_base:has_tag("medic") and 1 or new_stance_code, ...)
	end)

	self:post_hook(GroupAIStateBesiege, "_upd_groups", function(gstate)
		local lonely_medics = {}
		local potential_groups = {}
		for _, group in pairs(gstate._groups) do
			if group.has_spawned then
				local only_medics = true
				local has_medics = false
				for _, u_data in pairs(group.units) do
					if u_data.unit:base():has_tag("medic") then
						has_medics = true
					else
						only_medics = false
					end
				end
				if only_medics then
					for _, u_data in pairs(group.units) do
						table.insert(lonely_medics, u_data.unit)
					end
				elseif not has_medics then
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
			gstate:unit_leave_group(medic, false)
			gstate:assign_enemy_to_existing_group(medic, group)
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
