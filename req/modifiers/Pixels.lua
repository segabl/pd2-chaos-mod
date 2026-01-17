ChaosModifierPixels = ChaosModifier.class("ChaosModifierPixels")
ChaosModifierPixels.conflict_tags = { "ScreenEffect" }
ChaosModifierPixels.duration = 40

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

	self._slot_mask_all = World:make_slot_mask(1, 3, 5, 8, 11, 12, 14, 16, 17, 18, 21, 22, 25, 26, 33, 34, 35, 39)
	self._slot_mask_enemies = managers.slot:get_mask("enemies")
	self._slot_mask_shield = managers.slot:get_mask("enemy_shield_check")

	self._enemy_color = Color(1, 0.5, 0.5)

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
		local res = World:raycast("ray", pos_from, pos_to, "slot_mask", self._slot_mask_all)
		if not res then
			tile:set_color(Color.black)
		else
			local color = Color.white
			if alive(res.unit) and (res.unit:in_slot(self._slot_mask_enemies) or res.unit:in_slot(self._slot_mask_shield) and res.unit:parent()) then
				color = self._enemy_color
			end
			local s = (1 - res.distance / max_dis) ^ 3
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
