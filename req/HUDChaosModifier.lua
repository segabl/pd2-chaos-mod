---@class HUDChaosModifier
---@field new fun(self, modifier):HUDChaosModifier
HUDChaosModifier = class()
HUDChaosModifier.colors = {
	default = Color(1, 0.5, 1),
	instant = Color(0.5, 1, 1),
	conditional = Color(1, 0.75, 0.5),
	enemy_change = Color(0.75, 1, 0.75),
	player_specific = Color(0.5, 0.75, 1),
	completed = Color(0.5, 0.5, 0.5)
}

---@param modifier ChaosModifier
function HUDChaosModifier:init(modifier)
	self._modifier = modifier

	self._panel = ChaosMod:panel():panel({
		w = 240,
		h = 24
	})

	self._panel:rect({
		layer = 1,
		color = Color.black:with_alpha(0.5)
	})

	self._progress = self._panel:rect({
		layer = 2,
		color = self.colors[modifier.color] or modifier.duration < 0 and self.colors.conditional or modifier.duration == 0 and self.colors.instant or self.colors.default,
		alpha = 0.75,
		x = 3,
		y = 3,
		w = self._panel:w() - 6,
		h = self._panel:h() - 6
	})

	self._panel:text({
		layer = 3,
		text = managers.localization:to_upper_text(modifier.class_name),
		font = tweak_data.menu.pd2_medium_font,
		font_size = 16,
		color = Color.white,
		align = "center",
		vertical = "center"
	})

	self._completed_panel = ChaosMod:panel():panel({
		w = 0,
		h = self._panel:h()
	})

	self._completed_panel:rect({
		layer = 1,
		color = Color.black:with_alpha(0.5),
		halign = "grow"
	})

	self._panel:animate(callback(self, self, "_animate_fade_in"))
end

function HUDChaosModifier:_animate_fade_in(o)
	ChaosMod:anim_over(1, function(p)
		o:set_alpha(math.map_range(math.cos(540 * p), -1, 1, 1, 0))
	end)
end

function HUDChaosModifier:_animate_fade_out(o)
	o:set_layer(o:layer() - 1)
	ChaosMod:anim_over(1, function(p)
		o:set_alpha(1 - p)
		o:set_x(math.lerp(o:x(), o:parent():w(), p))
	end)
	o:parent():remove(o)
end

function HUDChaosModifier:update(t, dt, index)
	if not self._target_index then
		self._target_index = index
		self._index = index
	elseif self._target_index ~= index then
		self._target_index = index
	end

	if self._index ~= self._target_index then
		self._index = math.lerp(self._index, self._target_index, dt * 10)
	end

	self._panel:set_righttop(self._panel:parent():w() - 40, self._panel:parent():h() * 0.45 + self._index * self._panel:h())

	self._completed_panel:set_righttop(self._panel:lefttop())

	if self._modifier.duration > 0 then
		self._progress:set_w((self._panel:w() - 6) * (1 - math.clamp(self._modifier:progress(t, dt), 0, 1)))
	end
end

function HUDChaosModifier:complete(peer_id)
	if not peer_id then
		peer_id = managers.network:session():local_peer():id()
		self._progress:set_color(self.colors.completed)
	end

	if self._completed_panel:child("peer" .. peer_id) then
		return
	end

	self._completed_panel:bitmap({
		layer = 2,
		name = "peer" .. peer_id,
		texture = "guis/textures/menu_singletick",
		w = self._completed_panel:h(),
		h = self._completed_panel:h(),
		y = -self._completed_panel:h() * 0.125,
		color = tweak_data.chat_colors[peer_id]
	})

	self._completed_panel:set_w((self._completed_panel:num_children() - 1) * self._completed_panel:h())

	for i = 1, self._completed_panel:num_children() - 1 do
		self._completed_panel:child(i):set_x(self._completed_panel:w() - i * self._completed_panel:h())
	end
end

function HUDChaosModifier:expired(t, dt)
	return self._expired or self._modifier:expired(t, dt) and (self._modifier.duration > 0 or self._modifier._activation_t + 5 < t)
end

function HUDChaosModifier:destroy()
	if not self._expired and alive(self._panel) then
		self._panel:animate(callback(self, self, "_animate_fade_out"))
		self._completed_panel:parent():remove(self._completed_panel)
	end

	self._expired = true
end
