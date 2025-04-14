ChaosModifierKillQuota = ChaosModifier.class("ChaosModifierKillQuota")
ChaosModifierKillQuota.loud_only = true
ChaosModifierKillQuota.color = "player_specific"
ChaosModifierKillQuota.duration = 20

function ChaosModifierKillQuota:can_trigger()
	local gstate = managers.groupai:state()
	return gstate._hunt_mode or gstate._task_data.assault.active and (gstate._task_data.assault.phase == "build" or gstate._task_data.assault.phase == "sustain")
end

function ChaosModifierKillQuota:start()
	self._kills = 0
	self._target = 5

	self:create_panel()

	local text = managers.localization:to_upper_text("ChaosModifierKillQuotaStart", {
		AMOUNT = tostring(self._target)
	})
	self:show_text(text, 2, true)

	managers.player:register_message(Message.OnEnemyKilled, "ChaosModifierKillQuota", function()
		self._kills = self._kills + 1
		self:update_panel()

		if self._kills >= self._target then
			self:complete()
		end
	end)
end

function ChaosModifierKillQuota:create_panel()
	self._panel = ChaosMod:panel(true):panel({
		alpha = 0
	})

	local size = 48
	for i = 1, self._target do
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

	self._panel:set_size(size + self._target * size, size * 2)
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

	bitmap:set_alpha(1)

	self._panel:bitmap({
		texture = "guis/textures/pd2/risklevel_blackscreen",
		w = bitmap:w(),
		h = bitmap:h(),
		x = bitmap:x(),
		y = bitmap:y(),
		color = Color.white,
		alpha = 1
	}):animate(function(o)
		ChaosMod:anim_over(0.25, function(p)
			local size = math.lerp(bitmap:w(), bitmap:w() * 2, p)
			local alpha = math.lerp(1, 0, p)
			o:set_size(size, size)
			o:set_center(bitmap:center())
			o:set_alpha(alpha)
		end)
		o:parent():remove(o)
	end)
end

function ChaosModifierKillQuota:remove_panel()
	if not alive(self._panel) then
		return
	end

	self._panel:animate(function(o)
		ChaosMod:anim_over(0.5, function(p)
			o:set_alpha(1 - p)
		end)
		o:parent():remove(o)
	end)

	self._panel = nil
end

function ChaosModifierKillQuota:complete(...)
	ChaosModifierKillQuota.super.complete(self, ...)

	managers.player:unregister_message(Message.OnEnemyKilled, "ChaosModifierKillQuota")

	self:remove_panel()
end

function ChaosModifierKillQuota:stop()
	managers.player:unregister_message(Message.OnEnemyKilled, "ChaosModifierKillQuota")

	if self._kills < self._target then
		managers.player:set_player_state("incapacitated")
	end

	self:remove_panel()
end

return ChaosModifierKillQuota
