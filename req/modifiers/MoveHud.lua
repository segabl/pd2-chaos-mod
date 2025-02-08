ChaosModifierMoveHud = ChaosModifier.class("ChaosModifierMoveHud")
ChaosModifierMoveHud.duration = 60

function ChaosModifierMoveHud:start()
	self._modified_elements = {}

	self._panel_move = Panel.move
	self:override(Panel, "move", function(o, x, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = element_data.start_pos[1] + x
			element_data.start_pos[2] = element_data.start_pos[2] + y
		else
			return self._panel_move(o, x, y, ...)
		end
	end)

	local set_position = Panel.set_position
	self:override(Panel, "set_position", function(o, x, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x
			element_data.start_pos[2] = y
		else
			return set_position(o, x, y, ...)
		end
	end)

	local set_center = Panel.set_center
	self:override(Panel, "set_center", function(o, x, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x - o:w() * 0.5
			element_data.start_pos[2] = y - o:h() * 0.5
		else
			return set_center(o, x, y, ...)
		end
	end)

	local set_x = Panel.set_x
	self:override(Panel, "set_x", function(o, x, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x
		else
			return set_x(o, x, ...)
		end
	end)

	self:override(Panel, "set_left", Panel.set_x)

	local set_center_x = Panel.set_center_x
	self:override(Panel, "set_center_x", function(o, x, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x - o:w() * 0.5
			log("set_center_x")
		else
			return set_center_x(o, x, ...)
		end
	end)

	local set_right = Panel.set_right
	self:override(Panel, "set_right", function(o, x, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[1] = x - o:w()
		else
			return set_right(o, x, ...)
		end
	end)

	local set_y = Panel.set_y
	self:override(Panel, "set_y", function(o, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[2] = y
		else
			return set_y(o, y, ...)
		end
	end)

	self:override(Panel, "set_top", Panel.set_y)

	local set_center_y = Panel.set_center_y
	self:override(Panel, "set_center_y", function(o, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[2] = y - o:h() * 0.5
		else
			return set_center_y(o, y, ...)
		end
	end)

	local set_bottom = Panel.set_bottom
	self:override(Panel, "set_bottom", function(o, y, ...)
		local element_data = self._modified_elements[o:key()]
		if element_data then
			element_data.start_pos[2] = y - o:h()
		else
			return set_bottom(o, y, ...)
		end
	end)
end

function ChaosModifierMoveHud:update(t, dt)
	for _, hud in pairs({ PlayerBase.PLAYER_INFO_HUD_PD2, PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2 }) do
		local panel = managers.hud:panel(hud)
		for _, element in pairs(panel:children()) do
			local element_data = self._modified_elements[element:key()]
			if not element_data then
				element_data = {
					element = element,
					start_pos = { element:position() },
					velocity = math.UP:random_orthogonal()
				}
				mvector3.multiply(element_data.velocity, math.random(64, 256))
				if element:w() >= panel:w() then
					mvector3.set_x(element_data.velocity, 0)
				end
				if element:h() >= panel:h() then
					mvector3.set_y(element_data.velocity, 0)
				end
				self._modified_elements[element:key()] = element_data
			end
			self._panel_move(element, element_data.velocity.x * dt, element_data.velocity.y * dt)
			if element:top() <= 0 and element_data.velocity.y < 0 or element:bottom() >= panel:h() and element_data.velocity.y > 0 then
				mvector3.set_y(element_data.velocity, -element_data.velocity.y)
			end
			if element:left() <= 0 and element_data.velocity.x < 0 or element:right() >= panel:w() and element_data.velocity.x > 0 then
				mvector3.set_x(element_data.velocity, -element_data.velocity.x)
			end
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
