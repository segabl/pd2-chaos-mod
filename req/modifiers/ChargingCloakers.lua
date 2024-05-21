---@class ChaosModifierChargingCloakers : ChaosModifier
ChaosModifierChargingCloakers = class(ChaosModifier)
ChaosModifierChargingCloakers.class_name = "ChaosModifierChargingCloakers"
ChaosModifierChargingCloakers.duration = 30

function ChaosModifierChargingCloakers:charge(target_unit)
	local movement = target_unit:movement()
	local target_area = managers.groupai:state():get_area_from_nav_seg_id(movement:nav_tracker():nav_segment())
	if not target_area then
		return
	end

	local rot = Rotation()
	local vec = Vector3()
	local offset =  Vector3(0, 0, 200)

	local to_pos = movement:m_head_pos()

	local areas = {}
	local check_areas = { target_area }
	local checked_areas = { target_area = true }
	repeat
		local area = table.remove(check_areas, 1)
		table.insert(areas, area)
		for _, n in pairs(area.neighbours) do
			if not checked_areas[n] and mvector3.distance_sq(to_pos, n.pos) < 4000000 then
				checked_areas[n] = true
				table.insert(check_areas, n)
			end
		end
	until #check_areas == 0

	local pos, accept_pos
	local look_dir = movement:detect_look_dir()
	local slotmask = managers.slot:get_mask("world_geometry")
	repeat
		local area = table.remove(areas, math.random(#areas))
		local nav_seg = table.random(table.map_keys(area.nav_segs)) or area.pos_nav_seg
		local tries = 20
		repeat
			tries = tries - 1
			pos = managers.navigation:find_random_position_in_segment(nav_seg)
			local dis = mvector3.direction(vec, to_pos, pos)
			accept_pos = dis > 300 and dis < 1500 and (mvector3.dot(vec, look_dir) < 0.5 or World:raycast("ray", pos + offset, to_pos, "slot_mask", slotmask, "report"))
		until accept_pos or tries == 0

		if accept_pos then
			break
		end
	until #areas == 0

	managers.navigation:search_pos_to_pos({
		pos_from = pos,
		pos_to = to_pos,
		prio = 1000,
		id = "path" .. tostring(target_unit:key()),
		result_clbk = function(path)
			if not path then
				return
			end

			local unit_name = tweak_data.group_ai.unit_categories.spooc.unit_types[tweak_data.levels:get_ai_group_type()][1]
			local unit = World:spawn_unit(unit_name, pos, rot)
			unit:movement():set_team(managers.groupai:state():team_data("law1"))
			local brain = unit:brain()
			brain:set_logic("attack")
			brain._current_logic.damage_clbk(brain._logic_data, { attacker_unit = target_unit })
			local focus_enemy = brain._logic_data.detected_attention_objects[target_unit:key()]
			if not focus_enemy then
				return
			end

			CopLogicBase._set_attention(brain._logic_data, focus_enemy)
			brain._logic_data.internal_data.attention_unit = focus_enemy.u_key

			local action = unit:brain():action_request({
				body_part = 1,
				type = "spooc",
				nav_path = path
			})

			if action then
				brain._logic_data.internal_data.spooc_attack = {
					start_t = brain._logic_data.t,
					target_u_data = focus_enemy,
					action = action
				}
			end
		end
	})
end

function ChaosModifierChargingCloakers:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + math.rand(5, 10)

	local player_criminals = {}
	for _, v in pairs(managers.groupai:state():all_char_criminals()) do
		if not v.status and alive(v.unit) then
			table.insert(player_criminals, v.unit)
		end
	end

	local player_unit = #player_criminals > 1 and table.random(player_criminals)
	if player_unit then
		self:charge(player_unit)
	end
end

return ChaosModifierChargingCloakers
