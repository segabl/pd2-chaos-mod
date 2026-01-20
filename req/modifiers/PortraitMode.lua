ChaosModifierPortraitMode = ChaosModifier.class("ChaosModifierPortraitMode")
ChaosModifierPortraitMode.conflict_tags = { "ScreenRestriction" }
ChaosModifierPortraitMode.duration = 45

function ChaosModifierPortraitMode:start()
	local panel = ChaosMod:panel()
	local w = 0.5 * (panel:w() - panel:h() * panel:h() / panel:w())

	self._left = panel:rect({
		layer = -10,
		color = Color.black,
		w = w
	})

	self._right = panel:rect({
		layer = -10,
		color = Color.black,
		w = w
	})

	self._right:set_right(panel:w())
end

function ChaosModifierPortraitMode:stop()
	if alive(self._left) then
		self._left:parent():remove(self._left)
	end
	if alive(self._right) then
		self._right:parent():remove(self._right)
	end
end

return ChaosModifierPortraitMode
