ChaosModifierNoSleep = ChaosModifier.class("ChaosModifierNoSleep")
ChaosModifierNoSleep.duration = 40

function ChaosModifierNoSleep:start()
	local panel = managers.hud:panel(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)

	self._top = panel:gradient({
		layer = 100,
		orientation = "vertical",
		gradient_points = {
			0, Color.black,
			1, Color.transparent
		},
		h = 0
	})

	self._bottom = panel:gradient({
		layer = 100,
		color = Color.black,
		orientation = "vertical",
		gradient_points = {
			0, Color.transparent,
			1, Color.black
		},
		h = 0
	})

	self._next_t = math.rand(2, 4)
end

function ChaosModifierNoSleep:stop()
	if alive(self._top) then
		self._top:parent():remove(self._top)
	end
	if alive(self._bottom) then
		self._bottom:parent():remove(self._bottom)
	end
end

function ChaosModifierNoSleep:update(t, dt)
	if self._next_t > t then
		return
	end

	self._next_t = t + math.rand(4, 8)

	local wait_t = math.rand(0.5, 1)

	self._top:animate(function(o)
		ChaosMod:anim_over(2, function(p)
			o:set_h(math.lerp(o:parent():h() * 2, 0, 1 - p ^ 4))
		end)
		ChaosMod:anim_over(wait_t)
		ChaosMod:anim_over(0.25, function(p)
			o:set_h(math.lerp(o:parent():h() * 2, 0, p))
		end)
	end)

	self._bottom:animate(function(o)
		ChaosMod:anim_over(2, function(p)
			o:set_h(math.lerp(o:parent():h() * 2, 0, 1 - p ^ 4))
			o:set_bottom(o:parent():h())
		end)
		ChaosMod:anim_over(wait_t)
		ChaosMod:anim_over(0.25, function(p)
			o:set_h(math.lerp(o:parent():h() * 2, 0, p))
			o:set_bottom(o:parent():h())
		end)
	end)
end

return ChaosModifierNoSleep
