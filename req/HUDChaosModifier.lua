---@class HUDChaosModifier
---@field new fun(self, modifier):HUDChaosModifier
HUDChaosModifier = class()
HUDChaosModifier.colors = {
	default = Color(0.75, 1, 0.5, 1),
	instant = Color(0.75, 0.5, 1, 1),
	conditional = Color(0.75, 1, 0.75, 0.5),
	enemy_change = Color(0.5, 0.75, 0.5)
}

---@param modifier ChaosModifier
function HUDChaosModifier:init(modifier)
	self._activation_t = ChaosMod:time()

	self._modifier = modifier

	self._panel = managers.hud:panel(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2):panel({
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
	self._panel:parent():remove(self._panel)
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

	if self._modifier.duration > 0 then
		self._progress:set_w((self._panel:w() - 6) * (1 - math.clamp(self._modifier:progress(t, dt), 0, 1)))
	end
end

function HUDChaosModifier:expired(t, dt)
	return self._expired or self._modifier:expired(t, dt) and (self._modifier.duration > 0 or self._activation_t + 5 < t)
end

function HUDChaosModifier:destroy()
	if not self._expired and alive(self._panel) then
		self._panel:animate(callback(self, self, "_animate_fade_out"))
	end

	self._expired = true
end
