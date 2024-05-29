ChaosModifierScreenSaver = ChaosModifier.class("ChaosModifierScreenSaver")
ChaosModifierScreenSaver.run_as_client = true
ChaosModifierScreenSaver.duration = 60

function ChaosModifierScreenSaver:start()
	local panel = managers.hud:panel(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)

	self._image = panel:bitmap({
		texture = "guis/textures/bink_df",
		layer = 10
	})

	local x = math.random(self._image:w() * 0.5, panel:w() - self._image:w() * 0.5)
	local y = math.random(self._image:h() * 0.5, panel:h() - self._image:h() * 0.5)
	self._image:set_center(x, y)

	self._dir = Vector3(0, 0, 1)
	mvector3.random_orthogonal(self._dir)
end

function ChaosModifierScreenSaver:update(t, dt)
	self._image:move(self._dir.x * dt * 160, self._dir.y * dt * 160)
	if self._image:left() <= 0 and self._dir.x < 0 or self._image:right() >= self._image:parent():w() and self._dir.x > 0 then
		mvector3.set_x(self._dir, -self._dir.x)
	elseif self._image:top() <= 0 and self._dir.y < 0 or self._image:bottom() >= self._image:parent():h() and self._dir.y > 0 then
		mvector3.set_y(self._dir, -self._dir.y)
	end
	if (self._image:left() <= 16 or self._image:right() >= self._image:parent():w() - 16) and (self._image:top() <= 16 or self._image:bottom() >= self._image:parent():h() - 16) then
		if self._said_yes then
			return
		end
		self._said_yes = true
		managers.dialog:_stop_dialog()
		managers.dialog:queue_dialog("play_pln_gen_dir_08", {})
		for u_key, data in pairs(managers.groupai:state():all_char_criminals()) do
			DelayedCalls:Add(self.class_name .. tostring(u_key), math.rand(0.25, 0.75), function()
				if alive(data.unit) then
					data.unit:sound():say("v46")
				end
			end)
		end
	end
end

function ChaosModifierScreenSaver:stop()
	if alive(self._image) then
		self._image:parent():remove(self._image)
	end
end

return ChaosModifierScreenSaver
