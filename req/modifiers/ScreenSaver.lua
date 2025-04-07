ChaosModifierScreenSaver = ChaosModifier.class("ChaosModifierScreenSaver")
ChaosModifierScreenSaver.duration = 60

function ChaosModifierScreenSaver:start()
	local panel = ChaosMod:panel()

	self._image = panel:bitmap({
		texture = "guis/textures/bink_df",
		layer = 10
	})

	math.randomseed(self._seed)

	local x = math.random(self._image:w(), panel:w() - self._image:w())
	local y = math.random(self._image:h(), panel:h() - self._image:h())
	self._image:set_center(x, y)

	self._dir = Vector3((math.random() < 0.5 and -1 or 1) * math.rand(0.5, 1), (math.random() < 0.5 and -1 or 1) * math.rand(0.5, 1), 0)
	mvector3.normalize(self._dir)
end

function ChaosModifierScreenSaver:update(t, dt)
	self._image:move(self._dir.x * dt * 160, self._dir.y * dt * 160)

	local parent_w, parent_h = self._image:parent():size()
	if self._image:left() <= 0 and self._dir.x < 0 or self._image:right() >= parent_w and self._dir.x > 0 then
		mvector3.set_x(self._dir, -self._dir.x)
	elseif self._image:top() <= 0 and self._dir.y < 0 or self._image:bottom() >= parent_h and self._dir.y > 0 then
		mvector3.set_y(self._dir, -self._dir.y)
	end

	if (self._image:left() < 4 or self._image:right() > parent_w - 4) and (self._image:top() < 4 or self._image:bottom() > parent_h - 4) then
		if not self._said_yes then
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
	else
		self._said_yes = false
	end
end

function ChaosModifierScreenSaver:stop()
	if alive(self._image) then
		self._image:parent():remove(self._image)
	end
end

return ChaosModifierScreenSaver
