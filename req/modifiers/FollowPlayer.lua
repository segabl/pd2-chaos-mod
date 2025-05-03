ChaosModifierFollowPlayer = ChaosModifier.class("ChaosModifierFollowPlayer")
ChaosModifierFollowPlayer.stealth_safe = false
ChaosModifierFollowPlayer.color = "player_specific"
ChaosModifierFollowPlayer.duration = 60

function ChaosModifierFollowPlayer:can_trigger()
	return table.size(managers.groupai:state():all_char_criminals()) > 1
end

function ChaosModifierFollowPlayer:start()
	local units = {}
	local criminals = managers.groupai:state():all_player_criminals()
	if table.size(criminals) < 2 then
		criminals = managers.groupai:state():all_AI_criminals()
	end

	for _, data in pairs(criminals) do
		if alive(data.unit) then
			table.insert(units, data.unit)
		end
	end

	table.sort(units, function(a, b)
		return a:id() > b:id()
	end)

	math.randomseed(self._seed)
	self._unit = table.random(units)
	if not self._unit then
		return
	end

	if Network:is_server() and managers.groupai:state():is_unit_team_AI(self._unit) then
		self:pre_hook(TeamAIBrain, "set_objective", function(brain, objective)
			if brain._unit ~= self._unit or not objective or objective.type == "act" or objective.type == "revive" then
				return
			end

			local selector = WeightedSelector:new()
			for _, area in pairs(managers.groupai:state()._area_data) do
				selector:add(area, area.spawn_groups and 1 or next(area.criminal.units) and 2000 or 1000)
			end

			objective.type = "free"
			objective.area = selector:select()
			objective.nav_seg = objective.area.pos_nav_seg
			objective.in_place = nil
			objective.pos = nil
			objective.path_data = nil
			objective.follow_unit = nil
		end)

		self._unit:brain():set_objective(nil)
	end

	self:show_text(managers.localization:to_upper_text("ChaosModifierFollowPlayerPicked", { PLAYER = self._unit:base():nick_name() }), 3)

	if self._unit == managers.player:local_player() then
		self._hud_modifier._progress:set_color(HUDChaosModifier.colors.completed)
		self._is_local_player = true
		return
	end

	self._move_dir = Vector3()
	self._last_pos = Vector3()
	self._draw_dir = Vector3()
	self._draw_from = Vector3()
	self._draw_to = Vector3()
	self._brush = Draw:brush()

	self:pre_hook(PlayerStandard, "_update_movement", function(playerstate)
		if not self._path then
			return
		end

		playerstate._move_dir = mvector3.copy(self._move_dir)
		playerstate._normal_move_dir = mvector3.copy(self._move_dir)
	end)
end

function ChaosModifierFollowPlayer:draw_path(t, dt)
	if not self._path then
		return
	end

	local dis = {}
	local path_index = self._path_index
	local path_progress, start = 0, 0
	local prev_pos = managers.player:local_player():movement():m_pos()
	local time_prog = (t * 500) % 200 - 100
	while path_progress < 1500 and path_index <= #self._path + 1 do
		local pos = self._path[path_index] or self._unit:movement():m_pos()
		dis[path_index] = dis[path_index] or mvector3.direction(self._draw_dir, prev_pos, pos)

		local draw_pos = path_progress - start + time_prog

		mvector3.set(self._draw_from, prev_pos)
		mvector3.add_scaled(self._draw_from, self._draw_dir, math.clamp(draw_pos, 0, dis[path_index]))
		mvector3.add_scaled(self._draw_from, math.UP, 20)
		mvector3.set(self._draw_to, prev_pos)
		mvector3.add_scaled(self._draw_to, self._draw_dir, math.clamp(draw_pos + 100, 0, dis[path_index]))
		mvector3.add_scaled(self._draw_to, math.UP, 20)

		self._brush:set_color(Color.white:with_alpha(math.map_range_clamped(path_progress, 500, 1500, 1, 0)))
		self._brush:cylinder(self._draw_from, self._draw_to, 5, 4)

		if path_progress > start + dis[path_index] - 100 then
			prev_pos = pos
			start = start + dis[path_index]
			path_index = path_index + 1
		else
			path_progress = path_progress + 200
		end
	end
end

function ChaosModifierFollowPlayer:update(t, dt)
	local player_unit = managers.player:local_player()
	if self._is_local_player or not alive(player_unit) or not player_unit:mover() or not alive(self._unit) then
		return
	end

	self:draw_path(t, dt)

	if self._waiting_for_path then
		return
	end

	local from_pos = player_unit:movement():m_pos()
	local to_pos = self._unit:movement():m_pos()
	if mvector3.distance_sq(from_pos, to_pos) < (self._path and 300 or 700) ^ 2 and math.abs(to_pos.z - from_pos.z) < 150 then
		self._path = nil
		return
	end

	if self._path then
		if mvector3.distance_sq(self._last_pos, from_pos) < 25 then
			self._stuck_t = (self._stuck_t or 0) + dt
		else
			self._stuck_t = 0
			mvector3.set(self._last_pos, from_pos)
		end

		mvector3.set(self._move_dir, self._path[self._path_index])
		mvector3.subtract(self._move_dir, from_pos)
		mvector3.set_z(self._move_dir, 0)
		local dis = mvector3.normalize(self._move_dir)
		if dis < 50 and math.abs(self._path[self._path_index].z - from_pos.z) < 50 then
			self._path_index = self._path_index + 1
			if self._path_index > #self._path then
				self._path = nil
			end
		elseif self._stuck_t > 0.5 or mvector3.distance_sq(self._path[#self._path], to_pos) > 600 ^ 2 then
			self._path = nil
			self._stuck_t = 0
		end
	elseif not World:raycast("ray", player_unit:movement():m_com(), self._unit:movement():m_com(), "slot_mask", managers.slot:get_mask("world_geometry"), "sphere_cast_radius", 50, "report") then
		self._path = { mvector3.copy(self._unit:movement():m_pos()) }
		self._path_index = 1
	else
		self._waiting_for_path = true
		managers.navigation:search_pos_to_pos({
			tracker_from = player_unit:movement():nav_tracker(),
			pos_to = self._unit:movement():nav_tracker():field_position(),
			result_clbk = function(path)
				self._waiting_for_path = false
				self._path = path
				self._path_index = 1
			end,
			id = self.class_name,
			access_pos = managers.navigation:convert_access_flag("civ_male")
		})
	end
end

function ChaosModifierFollowPlayer:expired(t, dt)
	return not alive(self._unit) or self.super.expired(self, t, dt)
end

function ChaosModifierFollowPlayer:stop()
	if Network:is_server() and alive(self._unit) and managers.groupai:state():is_unit_team_AI(self._unit) then
		self._unit:brain():set_objective(nil)
	end
end

return ChaosModifierFollowPlayer
