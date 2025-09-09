ChaosModifierFocusPlayer = ChaosModifier.class("ChaosModifierFocusPlayer")
ChaosModifierFocusPlayer.loud_only = true
ChaosModifierFocusPlayer.color = "player_specific"
ChaosModifierFocusPlayer.duration = 60

function ChaosModifierFocusPlayer:can_trigger()
	return table.size(managers.groupai:state():all_char_criminals()) + table.size(managers.groupai:state():all_converted_enemies()) > 1
end

function ChaosModifierFocusPlayer:pick_player()
	local units = {}
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if alive(data.unit) then
			table.insert(units, data.unit)
		end
	end

	table.sort(units, function(a, b)
		return a:network():peer():id() > b:network():peer():id()
	end)

	math.randomseed(self._seed)
	local unit = table.random(units)
	if not unit then
		return
	end

	self:show_text(managers.localization:to_upper_text("ChaosModifierFocusPlayerPicked", { PLAYER = unit:base():nick_name() }), 3)

	if unit ~= managers.player:local_player() then
		self._hud_modifier._progress:set_color(HUDChaosModifier.colors.completed)
	end

	if Network:is_client() then
		return
	end

	local u_key = unit:key()
	self:post_hook(CopLogicIdle, "_get_priority_attention", function(data, attention_objects)
		if not alive(unit) or not unit:in_slot(data.enemy_slotmask) then
			return
		end

		local attention_data = attention_objects[u_key]
		if not attention_data then
			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)[u_key]
			local settings = attention_info and attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)
			if settings then
				attention_objects[u_key] = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, settings)
			end
		elseif attention_data.verified or attention_data.nearly_visible or attention_data.verified_t and data.t - attention_data.verified_t < 1 then
			return attention_data, 0, AIAttentionObject.REACT_MAX
		end
	end)

	self:override(SentryGunBrain, "_select_focus_attention", function(brain, ...)
		local attention_data = brain._detected_attention_objects[unit:key()]
		if not attention_data or not attention_data.verified or attention_data.settings.relation ~= "foe" or brain._attention_obj == attention_data then
			return self:get_override(SentryGunBrain, "_select_focus_attention")(brain, ...)
		end

		brain._attention_obj = attention_data
		brain._ext_movement:set_attention({
			unit = attention_data.unit,
			u_key = attention_data.u_key,
			handler = attention_data.handler,
			reaction = attention_data.reaction
		})
	end)

	self:pre_hook(GroupAIStateBesiege, "_upd_assault_task", function(gstate)
		local record = gstate:criminal_record(u_key)
		if record and gstate._task_data.assault.target_areas then
			gstate._task_data.assault.target_areas[1] = record.area
		end
	end)
end

function ChaosModifierFocusPlayer:start()
	self:show_text(managers.localization:to_upper_text("ChaosModifierFocusPlayer"), 2, true)
	self:queue("pick_player", 2)
end

return ChaosModifierFocusPlayer
