ChaosModifierMoveHud = ChaosModifier.class("ChaosModifierMoveHud")
ChaosModifierMoveHud.duration = 60

function ChaosModifierMoveHud:start()
	self._modified_elements = {}

	self:override(Panel, "move", function(o, x, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = element_data.start_pos[1] + x
			element_data.start_pos[2] = element_data.start_pos[2] + y
		else
			return self:get_override(Panel, "move")(o, x, y, ...)
		end
	end)

	self:override(Panel, "set_position", function(o, x, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x
			element_data.start_pos[2] = y
		else
			return self:get_override(Panel, "set_position")(o, x, y, ...)
		end
	end)

	self:override(Panel, "set_center", function(o, x, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x - o:w() * 0.5
			element_data.start_pos[2] = y - o:h() * 0.5
		else
			return self:get_override(Panel, "set_center")(o, x, y, ...)
		end
	end)

	self:override(Panel, "set_x", function(o, x, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x
		else
			return self:get_override(Panel, "set_x")(o, x, ...)
		end
	end)

	self:override(Panel, "set_left", Panel.set_x)

	self:override(Panel, "set_center_x", function(o, x, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x - o:w() * 0.5
		else
			return self:get_override(Panel, "set_center_x")(o, x, ...)
		end
	end)

	self:override(Panel, "set_right", function(o, x, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x - o:w()
		else
			return self:get_override(Panel, "set_right")(o, x, ...)
		end
	end)

	self:override(Panel, "set_y", function(o, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[2] = y
		else
			return self:get_override(Panel, "set_y")(o, y, ...)
		end
	end)

	self:override(Panel, "set_top", Panel.set_y)

	self:override(Panel, "set_center_y", function(o, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[2] = y - o:h() * 0.5
		else
			return self:get_override(Panel, "set_center_y")(o, y, ...)
		end
	end)

	self:override(Panel, "set_bottom", function(o, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[2] = y - o:h()
		else
			return self:get_override(Panel, "set_bottom")(o, y, ...)
		end
	end)

	self:override(Panel, "set_righttop", function(o, x, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x - o:w()
			element_data.start_pos[2] = y
		else
			return self:get_override(Panel, "set_righttop")(o, x, y, ...)
		end
	end)

	self:override(Panel, "set_rightbottom", function(o, x, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x - o:w()
			element_data.start_pos[2] = y - o:h()
		else
			return self:get_override(Panel, "set_rightbottom")(o, x, y, ...)
		end
	end)

	self:override(Panel, "set_lefttop", Panel.set_position)

	self:override(Panel, "set_leftbottom", function(o, x, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x
			element_data.start_pos[2] = y - o:h()
		else
			return self:get_override(Panel, "set_leftbottom")(o, x, y, ...)
		end
	end)
end

function ChaosModifierMoveHud:update(t, dt)
	local function iterate_element(element)
		if element.type_name ~= "Panel" then
			return
		end

		if element:w() >= element:root():w() and element:h() >= element:root():h() then
			for _, child in pairs(element:children()) do
				iterate_element(child)
			end
			return
		end

		local element_data = self._modified_elements[element:key()]
		if not element_data then
			element_data = {
				element = element,
				start_pos = { element:position() },
				velocity = math.UP:random_orthogonal()
			}

			mvector3.multiply(element_data.velocity, math.random(64, 256))

			if element:w() >= element:parent():w() then
				mvector3.set_x(element_data.velocity, 0)
			end

			if element:h() >= element:parent():h() then
				mvector3.set_y(element_data.velocity, 0)
			end

			self._modified_elements[element:key()] = element_data
		end

		self:get_override(Panel, "move")(element, element_data.velocity.x * dt, element_data.velocity.y * dt)

		if element:top() <= 0 and element_data.velocity.y < 0 or element:bottom() >= element:parent():h() and element_data.velocity.y > 0 then
			mvector3.set_y(element_data.velocity, -element_data.velocity.y)
		end

		if element:left() <= 0 and element_data.velocity.x < 0 or element:right() >= element:parent():w() and element_data.velocity.x > 0 then
			mvector3.set_x(element_data.velocity, -element_data.velocity.x)
		end
	end

	for _, ws in pairs(Overlay:gui():workspaces()) do
		if ws ~= managers.mouse_pointer._ws then
			iterate_element(ws:panel())
		end
	end
end

function ChaosModifierMoveHud:stop()
	for _, element_data in pairs(self._modified_elements) do
		if alive(element_data.element) then
			element_data.element:set_position(unpack(element_data.start_pos))
		end
	end
end

return ChaosModifierMoveHud
