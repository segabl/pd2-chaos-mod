ChaosModifierDrawEnemyBodies = ChaosModifier.class("ChaosModifierDrawEnemyBodies")
ChaosModifierDrawEnemyBodies.duration = 45

function ChaosModifierDrawEnemyBodies:start()
	self._update_rate = 0.05
	self._slotmask = managers.slot:get_mask("persons", "corpses") - managers.slot:get_mask("players_only_local")
	self._brush = Draw:brush(self._update_rate + 0.001)
	self._allowed_names = {
		[Idstring("rag_Head"):key()] = true,
		[Idstring("rag_Spine"):key()] = true,
		[Idstring("rag_Spine2"):key()] = true,
		[Idstring("rag_RightUpLeg"):key()] = true,
		[Idstring("rag_LeftUpLeg"):key()] = true,
		[Idstring("rag_RightArm"):key()] = true,
		[Idstring("rag_LeftArm"):key()] = true,
		[Idstring("rag_RightForeArm"):key()] = true,
		[Idstring("rag_LeftForeArm"):key()] = true,
		[Idstring("rag_RightLeg"):key()] = true,
		[Idstring("rag_LeftLeg"):key()] = true
	}
	self._colors = {
		law1 = Color(1, 0, 0),
		criminal1 = Color(0, 1, 1),
		neutral1 = Color(0.75, 0.75, 0.75)
	}
	self._colors.converted_enemy = self._colors.criminal1
	self._colors.hacked_turret = self._colors.criminal1
	self._colors.mobster1 = self._colors.law1
end

function ChaosModifierDrawEnemyBodies:draw_unit_bodies(unit, allowed_names)
	local has_drawn = false
	for i = 0, unit:num_bodies() - 1 do
		local body = unit:body(i)
		if not allowed_names or allowed_names[body:name():key()] then
			self._brush:body(body)
			has_drawn = true
		end
	end
	return has_drawn
end

function ChaosModifierDrawEnemyBodies:update(t, dt)
	local cam = managers.viewport:get_current_camera()
	if not cam then
		return
	end

	if self._next_t  and self._next_t > t then
		return
	end

	self._next_t = t + self._update_rate

	local units = World:find_units_quick("all", self._slotmask)
	local distances = {}
	table.sort(units, function(a, b)
		local a_key = a:key()
		local b_key = b:key()
		distances[a_key] = distances[a_key] or mvector3.distance(a:position(), cam:position())
		distances[b_key] = distances[b_key] or mvector3.distance(b:position(), cam:position())
		return distances[a_key] > distances[b_key]
	end)

	for _, unit in pairs(units) do
		local color = self._colors[unit:movement() and unit:movement().team and unit:movement():team().id] or self._colors.neutral1
		local mul = (unit:base().has_tag and unit:base():has_tag("special") and 0.5 or 1)
		mul = mul * math.map_range_clamped(distances[unit:key()] or mvector3.distance(unit:position(), cam:position()), 0, 5000, 1, 0)
		self._brush:set_color(Color(color.r * mul, color.g * mul, color.b * mul))
		if self:draw_unit_bodies(unit, self._allowed_names) then
			unit:set_visible(false)
			for _, child in pairs(unit:children()) do
				child:set_visible(false)
				self:draw_unit_bodies(child)
			end
		end
	end
end

function ChaosModifierDrawEnemyBodies:stop()
	for _, unit in pairs(World:find_units_quick("all", self._slotmask)) do
		unit:set_visible(true)
		for _, child in pairs(unit:children()) do
			child:set_visible(true)
		end
	end
end

return ChaosModifierDrawEnemyBodies
