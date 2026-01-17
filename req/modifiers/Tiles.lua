ChaosModifierTiles = ChaosModifier.class("ChaosModifierTiles")
ChaosModifierTiles.duration = 60

function ChaosModifierTiles:start()
	self._tiles = {}
	self._colors = {}

	self._panel = ChaosMod:panel():panel({
		layer = -10000000
	})

	local tile_size = 40
	local w, h = self._panel:size()
	for x = 0, math.ceil(w / tile_size) - 1 do
		self._tiles[x] = {}
		for y = 0, math.ceil(h / tile_size) - 1 do
			self._tiles[x][y] = self._panel:rect({
				blend_mode = "mulx2",
				x = x * tile_size + 1,
				y = y * tile_size + 1,
				w = tile_size - 2,
				h = tile_size - 2,
				color = Color(0.5, 0.5, 0.5)
			})
		end
	end
end

function ChaosModifierTiles:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + 0.05

	local x1 = table.random_key(self._tiles)
	local y1 = table.random_key(self._tiles[x1])
	if not y1 then
		return
	end
	local x2 = x1
	local y2 = y1

	local use_x = math.random() < 0.5
	if use_x and self._tiles[x2 - 1] and self._tiles[x2 - 1][y2] then
		x2 = x2 - 1
	elseif use_x and self._tiles[x2 + 1] and self._tiles[x2 + 1][y2] then
		x2 = x2 + 1
	elseif self._tiles[x2][y2 - 1] then
		y2 = y2 - 1
	elseif self._tiles[x2][y2 + 1] then
		y2 = y2 + 1
	end

	local tile1 = self._tiles[x1][y1]
	local tile2 = self._tiles[x2][y2]

	tile1:animate(function(o)
		self._tiles[x1][y1] = nil
		local start_x, start_y = o:position()
		local target_x, target_y = tile2:position()
		local start_color = o:color()
		local target_color = self._colors[o:key()] or Color(hsv_to_rgb(math.random(360), math.rand(0, 0.75), 0.75))
		self._colors[o:key()] = target_color
		ChaosMod:anim_over(0.5, function(p)
			o:set_position(math.lerp(start_x, target_x, p), math.lerp(start_y, target_y, p))
			o:set_color(math.lerp(start_color, target_color, p))
		end)
		self._tiles[x2][y2] = o
	end)

	tile2:animate(function(o)
		self._tiles[x2][y2] = nil
		local start_x, start_y = o:position()
		local target_x, target_y = tile1:position()
		local start_color = o:color()
		local target_color = self._colors[o:key()] or Color(hsv_to_rgb(math.random(360), math.rand(0, 0.75), 0.75))
		self._colors[o:key()] = target_color
		ChaosMod:anim_over(0.5, function(p)
			o:set_position(math.lerp(start_x, target_x, p), math.lerp(start_y, target_y, p))
			o:set_color(math.lerp(start_color, target_color, p))
		end)
		self._tiles[x1][y1] = o
	end)
end

function ChaosModifierTiles:stop()
	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end
end

return ChaosModifierTiles
