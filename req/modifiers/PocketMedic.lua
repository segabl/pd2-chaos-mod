ChaosModifierPocketMedic = ChaosModifier.class("ChaosModifierPocketMedic", ChaosModifierPlayerShields)
ChaosModifierPocketMedic.loud_only = true
ChaosModifierPocketMedic.run_as_client = false
ChaosModifierPocketMedic.duration = -1

function ChaosModifierPocketMedic:start()
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

return ChaosModifierPocketMedic
