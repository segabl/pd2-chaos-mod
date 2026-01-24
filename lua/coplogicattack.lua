function CopLogicAttack._find_pos_close_to_tracker(data, my_data, tracker)
	local field_pos = tracker:field_position()
	local pos = Vector3(0, 0, 0)
	local dis = mvector3.direction(pos, field_pos, data.m_pos)
	if dis < 125 then
		return
	end
	mvector3.multiply(pos, 75)
	mvector3.add(pos, field_pos)
	return pos
end
