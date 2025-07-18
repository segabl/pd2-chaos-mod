ChaosModifierKillQuota = ChaosModifier.class("ChaosModifierKillQuota")
ChaosModifierKillQuota.conflict_tags = { "Minigame" }
ChaosModifierKillQuota.loud_only = true
ChaosModifierKillQuota.color = "player_specific"
ChaosModifierKillQuota.duration = 20
ChaosModifierKillQuota.target = 5

function ChaosModifierKillQuota:can_trigger()
	local gstate = managers.groupai:state()
	if not gstate._hunt_mode or not gstate._task_data.assault.active then
		return
	end
	if gstate._task_data.assault.phase == "build" or gstate._task_data.assault.phase == "sustain" then
		return gstate:_count_police_force("assault") > self.target * 2
	end
end

function ChaosModifierKillQuota:start()
	self._kills = 0

	self:create_panel()

	local text = managers.localization:to_upper_text("ChaosModifierKillQuotaStart", {
		AMOUNT = tostring(self.target)
	})
	self:show_text(text, 2, true)

	managers.player:register_message(Message.OnEnemyKilled, "ChaosModifierKillQuota", function()
		self._kills = self._kills + 1
		self:update_panel()
		managers.hud:post_event("item_buy")

		if self._kills >= self.target then
			managers.player:unregister_message(Message.OnEnemyKilled, "ChaosModifierKillQuota")
			self:complete()
			self:remove_panel(true)
			managers.hud:post_event("slot_machine_win")
		end
	end)
end

function ChaosModifierKillQuota:create_panel()
	self._panel = ChaosMod:panel(true):panel({
		alpha = 0
	})

	local size = 48
	for i = 1, self.target do
		self._panel:bitmap({
			texture = "guis/textures/pd2/risklevel_blackscreen",
			w = size,
			h = size,
			x = size / 2 + (i - 1) * size,
			y = size / 2,
			color = Color.white,
			alpha = 0.2
		})
	end

	self._panel:set_size(size + self.target * size, size * 2)
	self._panel:set_center(self._panel:parent():w() * 0.5, self._panel:parent():h() * 0.145)

	self._panel:animate(function(o)
		ChaosMod:anim_over(0.5, function(p)
			o:set_alpha(p)
		end)
	end)
end

function ChaosModifierKillQuota:update_panel()
	if not alive(self._panel) then
		return
	end

	local bitmap = self._panel:child(self._kills - 1)
	if not bitmap then
		return
	end

	bitmap:animate(function(o)
		local a = bitmap:alpha()
		local x, y = bitmap:center()
		local w = bitmap:w()
		ChaosMod:anim_over(0.25, function(p)
			local size = math.lerp(w * 2, w, p)
			local alpha = math.lerp(a, 1, p)
			o:set_size(size, size)
			o:set_center(x, y)
			o:set_alpha(alpha)
			o:set_color(Color(1, 1, p ^ 3))
		end)
	end)
end

function ChaosModifierKillQuota:remove_panel(completed)
	if not alive(self._panel) then
		return
	end

	self._panel:animate(function(o)
		if completed then
			ChaosMod:anim_over(1, function(p)
				o:set_alpha(math.map_range(math.sin(p * 360 * 4), -1, 1, 0, 1))
			end)
		end
		ChaosMod:anim_over(0.5, function(p)
			o:set_alpha(1 - p)
		end)
		o:parent():remove(o)
	end)

	self._panel = nil
end

function ChaosModifierKillQuota:stop()
	managers.player:unregister_message(Message.OnEnemyKilled, "ChaosModifierKillQuota")

	if not self._completed then
		managers.player:set_player_state("incapacitated")
	end

	self:remove_panel()
end

return ChaosModifierKillQuota
