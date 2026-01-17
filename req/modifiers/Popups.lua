ChaosModifierPopups = ChaosModifier.class("ChaosModifierPopups")
ChaosModifierPopups.duration = 60

function ChaosModifierPopups:start()
	math.randomseed(self._seed)
	if math.random() < 0.01 then
		self._fixed_texture = "guis/dlcs/pda10/textures/pd2/new_heists/pda10_04"
	end

	self._textures = {}
	for _, info in ipairs(tweak_data.gui.new_heists) do
		if info.texture_path then
			table.insert(self._textures, info.texture_path)
		end
	end

	self._image_w = 419
	self._image_h = 126

	local w, h = ChaosMod:panel():size()
	local left = (w - self._image_w - 60) / 2
	local right = (w + self._image_w + 60) / 2
	local top = (h - self._image_h - 60) / 2
	local bottom = (h + self._image_h + 60) / 2

	local grid_w = (w - self._image_w / 2) / 30
	local grid_h = (h - self._image_h / 2) / 30
	self._grid = {}
	for x = self._image_w / 4, w - self._image_w / 4, grid_w do
		for y = self._image_h / 4, h - self._image_h / 4, grid_h do
			if x < left or x > right or y < top or y > bottom then
				table.insert(self._grid, { x = x, y = y })
			end
		end
	end

	self._panels = {}

	self:queue("add_image", 0.3)
end

function ChaosModifierPopups:add_image()
	local location = table.random(self._grid)
	if not location then
		return
	end

	local texture = nil
	if self._fixed_texture then
		texture = self._fixed_texture
	elseif #self._textures > 0 then
		local index = math.random(#self._textures)
		texture = self._textures[index]
		table.remove(self._textures, index)
	else
		return
	end

	local mul = math.rand(0.75, 1)
	local panel = ChaosMod:panel():panel()
	local bitmap = panel:bitmap({
		texture = texture,
		texture_rect = { 0, 0, self._image_w, self._image_h },
		layer = 10 + #self._panels,
		w = self._image_w * mul,
		h = self._image_h * mul
	})

	local w, h = bitmap:size()
	panel:set_size(w, h)
	panel:set_center(location.x, location.y)

	local left = location.x - w / 2
	local right = location.x + w / 2
	local top = location.y - h / 2
	local bottom = location.y + h / 2

	for index = #self._grid, 1, -1 do
		local coordinates = self._grid[index]
		if coordinates.x > left and coordinates.x < right and coordinates.y > top and coordinates.y < bottom then
			table.remove(self._grid, index)
		end
	end

	table.insert(self._panels, panel)

	bitmap:animate(callback(self, self, "animate_appear"))

	self:queue("add_image", math.rand(2, 4))
end

function ChaosModifierPopups:animate_appear(o)
	local x, y = o:center()
	local w, h = o:size()
	ChaosMod:anim_over(0.2, function(p)
		o:set_size(math.lerp(0, w, p), math.lerp(0, h, p))
		o:set_center(x, y)
	end)
end

function ChaosModifierPopups:animate_disappear(o)
	ChaosMod:anim_over(math.rand(0.1, 0.75), function(p)
		o:set_alpha(1 - p)
	end)
	o:parent():remove(o)
end

function ChaosModifierPopups:stop()
	self:unqueue("add_image")

	for _, panel in pairs(self._panels) do
		if alive(panel) then
			panel:animate(callback(self, self, "animate_disappear"))
		end
	end
end

return ChaosModifierPopups
