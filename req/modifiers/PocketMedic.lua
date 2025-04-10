ChaosModifierPocketMedic = ChaosModifier.class("ChaosModifierPocketMedic", ChaosModifierPlayerShields)
ChaosModifierPocketMedic.loud_only = true
ChaosModifierPocketMedic.duration = -1

function ChaosModifierPocketMedic:start()
	self:override(PlayerBase, "char_tweak", function() return {} end)

	self:override(PlayerDamage, "do_medic_heal", function(playerdamage)
		playerdamage:revive(true)
		managers.hint:show_hint("you_were_helpedup", nil, false, {
			TEAMMATE = playerdamage._unit:base():nick_name(),
			HELPER = managers.localization:text("ChaosModifierPocketMedicHelperName")
		})
	end)

	self:post_hook(PlayerDamage, "update", function(playerdamage, unit, t)
		if not playerdamage:need_revive() then
			playerdamage._chaos_medic_revive_check_t = nil
			if not playerdamage._chaos_medic_heal_t or t >= playerdamage._chaos_medic_heal_t then
				playerdamage._chaos_medic_heal_t = t + 1
				if next(managers.enemy:find_nearby_affiliated_medics(unit)) then
					playerdamage:restore_health(0.01, false, true)
				end
			end
			return
		elseif not playerdamage._chaos_medic_revive_check_t then
			playerdamage._chaos_medic_revive_check_t = t + 0.5
			return
		elseif playerdamage._chaos_medic_revive_check_t > t then
			return
		end

		playerdamage._chaos_medic_revive_check_t = t + 0.5
		local medic = managers.enemy:get_nearby_medic(unit)
		if medic then
			medic:character_damage():heal_unit(unit)
		end
	end)

	if not Network:is_server() then
		return
	end

	self._medic_unit_names = {}
	for _, v in pairs(tweak_data.group_ai.unit_categories) do
		if v.special_type == "medic" then
			table.list_append(self._medic_unit_names, v.unit_types[tweak_data.levels:get_ai_group_type()])
		end
	end

	if #self._medic_unit_names == 0 then
		return
	end

	ChaosModifierPocketMedic.super.start(self)
end

function ChaosModifierPocketMedic:stop()
	if Network:is_server() then
		ChaosModifierPocketMedic.super.stop(self)
	end
end

function ChaosModifierPocketMedic:get_follow_objective(player_unit)
	return {
		type = "follow",
		scan = true,
		follow_unit = player_unit,
		distance = 300
	}
end

function ChaosModifierPocketMedic:spawn_unit(player_unit)
	local unit = World:spawn_unit(table.random(self._medic_unit_names), player_unit:movement():m_pos(), Rotation())

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

	unit:character_damage()._damage_reduction_multiplier = 0.35
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

return ChaosModifierPocketMedic
