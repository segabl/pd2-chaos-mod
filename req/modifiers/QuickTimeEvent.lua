ChaosModifierQuickTimeEvent = ChaosModifier.class("ChaosModifierQuickTimeEvent")
ChaosModifierQuickTimeEvent.register_name = "ChaosModifierPlayerInteraction"
ChaosModifierQuickTimeEvent.duration = 120

function ChaosModifierQuickTimeEvent:start()
	self._size = 32
	self._gap = 16
	self._speed = self._size * 4
	self._fade_distance = self._size * 2 + self._gap * 2
	self._last_stick_move = Vector3()
	self._rotations = {
		[-90] = Vector3(-1, 0),
		[90] = Vector3(1, 0),
		[0] = Vector3(0, 1),
		[180] = Vector3(0, -1)
	}

	self._panel = ChaosMod:panel():panel({
		layer = 100
	})

	self._panel_bg = self._panel:panel({
		alpha = 0
	})

	self._panel_bg:bitmap({
		color = Color.white,
		texture = "guis/textures/pd2/hud_cooldown_timer",
		w = self._size * 1.2,
		h = self._size * 1.2,
		x = self._panel_bg:w() * 0.5 - self._size * 0.6,
		y = self._panel_bg:h() * 0.5 - self._size * 0.6
	})

	self._panel_bg:bitmap({
		color = Color.black,
		texture = "guis/textures/pd2/hud_cooldown_timer",
		w = self._size * 1.1,
		h = self._size * 1.1,
		x = self._panel_bg:w() * 0.5 - self._size * 0.55,
		y = self._panel_bg:h() * 0.5 - self._size * 0.55
	})

	self:pre_hook(PlayerStandard, "_chk_tap_to_interact_enable", function(playerstate, t, timer, interact_object)
		if interact_object then
			self:set_player_state_settings(playerstate, true)
		end
	end)

	self:post_hook(PlayerStandard, "_interacting", function()
		if self._complete_interact_t and self._complete_interact_t > TimerManager:game():time() then
			return true
		end
	end)

	self:pre_hook(PlayerStandard, "_interupt_action_interact", function(playerstate, t, input, complete)
		if playerstate._interact_expire_t then
			self:stop_sequence(playerstate, complete)
		end
		self:set_player_state_settings(playerstate, false)
	end)

	self:override(PlayerStandard, "_update_interaction_timers", function(playerstate, t)
		if not playerstate._interact_expire_t then
			return
		end

		if not alive(playerstate._interact_params.object) or playerstate._interact_params.object ~= playerstate._interaction:active_unit() or playerstate._interact_params.tweak_data ~= playerstate._interact_params.object:interaction().tweak_data or playerstate._interact_params.object:interaction():check_interupt() then
			playerstate:_interupt_action_interact(t)
			return
		end

		self:update_sequence(playerstate, t)
	end)
end

function ChaosModifierQuickTimeEvent:get_sequence_groups(num_events)
	local group_sizes = {}

	while num_events > 0 do
		if num_events > 9 or num_events % 4 == 0 then
			table.insert(group_sizes, 4)
			num_events = num_events - 4
		else
			table.insert(group_sizes, math.min(3, num_events))
			num_events = num_events - 3
		end
	end

	table.shuffle(group_sizes)

	return group_sizes
end

function ChaosModifierQuickTimeEvent:start_sequence(playerstate)
	self._sequence = {}
	self._index = 1

	mvector3.set(self._last_stick_move, playerstate._stick_move)

	local num_events = math.max(2, math.ceil(playerstate._interact_expire_t * 1.5))
	local offset = self._panel:h() * 0.5 + self._fade_distance
	local group_sizes = self:get_sequence_groups(num_events)
	for _ = 1, num_events do
		local button = self._panel:bitmap({
			layer = 1,
			texture = "guis/textures/pd2/hud_icon_assaultbox",
			rotation = table.random_key(self._rotations),
			w = self._size,
			h = self._size,
			x = self._panel:w() * 0.5 - self._size * 0.5,
			y = offset
		})
		button:animate(callback(self, self, "animate_move"))
		table.insert(self._sequence, button)

		offset = offset + self._size + self._gap

		group_sizes[1] = group_sizes[1] - 1
		if group_sizes[1] == 0 then
			table.remove(group_sizes, 1)
			offset = offset + self._size + self._gap
		end
	end

	self._panel_bg:stop()
	self._panel_bg:animate(callback(self, self, "animate_fade_in"))
end

function ChaosModifierQuickTimeEvent:update_sequence(playerstate, t)
	if not self._sequence then
		self:start_sequence(playerstate)
	end

	playerstate._interact_expire_t = math.map_range(self._index - 1, 0, #self._sequence, playerstate._interact_params.timer, 0)
	managers.hud:set_interaction_bar_width(self._index - 1, #self._sequence)

	local current_button = self._sequence[self._index]
	local button_distance = self._panel:world_center_y() - current_button:world_center_y()

	local pressed_direction
	if playerstate._stick_move and playerstate._stick_move:dot(self._last_stick_move) < 0.75 then
		mvector3.set(self._last_stick_move, playerstate._stick_move)
		if self._last_stick_move:length() > 0 then
			pressed_direction = self._last_stick_move
		end
	end

	if pressed_direction and self._rotations[current_button:rotation()]:dot(pressed_direction) > 0.75 and math.abs(button_distance) <= self._size * 0.75 then
		managers.hud:post_event("prompt_enter")
		if self._index >= #self._sequence then
			playerstate:_end_action_interact(t)
			playerstate._interact_expire_t = nil
		else
			self._index = self._index + 1
		end
		current_button:stop()
		current_button:animate(callback(self, self, "animate_success"))
	elseif pressed_direction or button_distance > self._size * 0.75 then
		managers.hud:post_event("menu_error")
		playerstate:_interupt_action_interact(t)
	end
end

function ChaosModifierQuickTimeEvent:stop_sequence(playerstate, complete)
	self._complete_interact_t = TimerManager:game():time() + 0.25

	self._panel_bg:stop()
	self._panel_bg:animate(callback(self, self, "animate_fade_out"))

	if not complete then
		for _, button in pairs(self._sequence) do
			if alive(button) then
				button:stop()
				button:animate(callback(self, self, "animate_fail"))
			end
		end
	end

	self._sequence = nil
end

function ChaosModifierQuickTimeEvent:animate_move(o)
	while o:bottom() > 0 do
		local diff = math.abs(o:world_center_y() - self._panel:world_center_y())
		o:set_alpha(math.map_range_clamped(diff, self._size + self._gap, self._fade_distance, 1, 0))
		o:move(0, -self._speed * coroutine.yield())
	end
	o:parent():remove(o)
end

function ChaosModifierQuickTimeEvent:animate_fade_in(o)
	local a = o:alpha()
	over(0.5, function(p)
		o:set_alpha(math.min(a + p, 1))
	end)
end

function ChaosModifierQuickTimeEvent:animate_fade_out(o)
	local a = o:alpha()
	over(0.5, function(p)
		o:set_alpha(math.max(a - p, 0))
	end)
end

function ChaosModifierQuickTimeEvent:animate_success(o)
	local a = o:alpha()
	local c = o:color()
	local w, h = o:size()
	over(0.25, function(p)
		local x, y = o:center()
		o:set_alpha(a - p)
		o:set_size(w * (1 + p), h * (1 + p))
		o:set_center(x, y)
		o:set_color(math.map_range_clamped(p, 0.15, 0.3, HUDChaosModifier.colors.default, c))
	end)
	o:parent():remove(o)
end

function ChaosModifierQuickTimeEvent:animate_fail(o)
	local a = o:alpha()
	local x = math.random(-self._size * 10, self._size * 10)
	local y = -self._speed
	local rotation = math.random(-360, 360)
	over(0.5, function(p)
		local dt = TimerManager:game():delta_time()
		y = y + dt * self._size * 25
		o:move(x * dt, y * dt)
		o:set_alpha(a - p)
		o:rotate(rotation * dt)
	end)
	o:parent():remove(o)
end

function ChaosModifierQuickTimeEvent:set_player_state_settings(playerstate, enable)
	playerstate._setting_tap_to_interact = enable and "toggle_hold" or managers.user:get_setting("tap_to_interact")
	playerstate._setting_tap_to_interact_time = enable and 0 or managers.user:get_setting("tap_to_interact_time")
	playerstate._setting_tap_to_interact_show_text = not enable and managers.user:get_setting("tap_to_interact_show_text") or nil
end

function ChaosModifierQuickTimeEvent:stop()
	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end

	local player_unit = managers.player:local_player()
	if alive(player_unit) then
		self:set_player_state_settings(player_unit:movement():current_state(), false)
	end
end

return ChaosModifierQuickTimeEvent
