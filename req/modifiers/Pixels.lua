ChaosModifierPixels = ChaosModifier.class("ChaosModifierPixels")
ChaosModifierPixels.tags = { "ScreenEffect", "NoLights" }
ChaosModifierPixels.conflict_tags = { "ScreenEffect", "ScreenRestriction" }
ChaosModifierPixels.duration = 30
ChaosModifierPixels.weight_mul = 0.75

function ChaosModifierPixels:start()
	self._panel = ChaosMod:panel():panel({
		layer = -100000000
	})

	local tile_size = 20
	local w, h = self._panel:size()
	for y = 0, math.ceil(h / tile_size) - 1 do
		for x = 0, math.ceil(w / tile_size) - 1 do
			self._panel:rect({
				x = x * tile_size,
				y = y * tile_size,
				w = tile_size,
				h = tile_size
			})
		end
	end

	self._slot_mask = World:make_slot_mask(1, 3, 5, 8, 11, 12, 14, 16, 17, 18, 21, 22, 25, 26, 33, 34, 35, 39)
	self._enemy_color = Color(1, 0.5, 0.5)
	self._player_team = tweak_data.levels:get_default_team_ID("player")

	self._draw_index = 1
	self._draw_amount = math.ceil(w / tile_size) * 10
	self._tiles = self._panel:children()
end

function ChaosModifierPixels:update(t, dt)
	local cam = managers.viewport:get_current_camera()
	if not alive(cam) then
		return
	end

	local max_dis = 2000
	local tmp_vec = Vector3()
	for i = self._draw_index, self._draw_index + self._draw_amount - 1 do
		local tile = self._tiles[((i - 1) % #self._tiles) + 1]
		mvector3.set_static(tmp_vec, tile:center_x(), tile:center_y(), 10)
		local pos_from = managers.hud._fullscreen_workspace:screen_to_world(cam, tmp_vec)
		mvector3.set_z(tmp_vec, max_dis)
		local pos_to = managers.hud._fullscreen_workspace:screen_to_world(cam, tmp_vec)
		local res = World:raycast("ray", pos_from, pos_to, "slot_mask", self._slot_mask)
		if not res or not alive(res.unit) then
			tile:set_color(Color.black)
		else
			local s = 1 - res.distance / max_dis
			local color = Color.white
			local unit = res.unit:in_slot(8) and res.unit:parent() or res.unit
			local team = unit:movement() and type(unit:movement().team) == "function" and unit:movement():team()
			if team and team.foes[self._player_team] and not unit:character_damage()._dead and unit:brain() and not unit:brain():is_hostage() then
				color = self._enemy_color
			else
				s = s ^ 3
			end
			tile:set_color(Color(color.r * s, color.g * s, color.b * s))
		end
	end
	self._draw_index = ((self._draw_index + self._draw_amount - 1) % #self._tiles) + 1
end

function ChaosModifierPixels:stop()
	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end
end

return ChaosModifierPixels
