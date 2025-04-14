ChaosModifierCaptcha = ChaosModifier.class("ChaosModifierCaptcha")
ChaosModifierCaptcha.register_name = "ChaosModifierUserInterface"
ChaosModifierCaptcha.color = "player_specific"
ChaosModifierCaptcha.duration = 60

function ChaosModifierCaptcha:start()
	local skills = {}
	for _, tree in pairs(tweak_data.skilltree.trees) do
		for _, tier in pairs(tree.tiers) do
			for _, skill in pairs(tier) do
				table.insert(skills, {
					skill = skill,
					tree_name_id = tweak_data.skilltree.skilltree[tree.skill].name_id,
					subtree_name_id = tree.name_id
				})
			end
		end
	end

	self._skills = {}  ---@type { skill: string, tree_name_id: string, subtree_name_id: string, button: Panel? }[]
	for _ = 1, 9 do
		table.insert(self._skills, table.remove(skills, math.random(#skills)))
	end
	local skill = table.random(self._skills)
	self._tree = skill.tree_name_id
	self._subtree = skill.subtree_name_id

	managers.mouse_pointer:use_mouse({
		mouse_move = callback(self, self, "mouse_move"),
		mouse_press = callback(self, self, "mouse_press"),
		mouse_release = callback(self, self, "mouse_release"),
		id = self.class_name
	})
	managers.mouse_pointer:set_pointer_image("arrow")

	if managers.player:local_player() then
		managers.player:local_player():character_damage()._god_mode = true
	end

	self:setup_gui()
end

function ChaosModifierCaptcha:update(t, dt)
	if alive(self._panel) and not self._completed then
		game_state_machine:current_state():set_controller_enabled(false)
	end
end

function ChaosModifierCaptcha:stop()
	managers.mouse_pointer:remove_mouse(self.class_name)

	if managers.player:local_player() then
		managers.player:local_player():character_damage()._god_mode = false
	end
	game_state_machine:current_state():set_controller_enabled(true)

	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end

	if not self._completed and self._expired then
		managers.player:set_player_state("incapacitated")
	end
end

function ChaosModifierCaptcha:setup_gui()
	local size = 64
	local padding = 8
	local col = 0
	local row = 0
	local y = padding

	self._panel = ChaosMod:panel(true):panel({
		layer = 200,
		w = padding + (size + padding) * 3
	})

	self._bg = self._panel:rect({
		color = Color.black:with_alpha(0.75),
		layer = -3
	})

	self._panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self._panel:w(),
		h = self._panel:h(),
		layer = -2
	})

	local prompt_text = managers.localization:text("ChaosModifierCaptchaPrompt", {
		SUBTREE = managers.localization:text(self._subtree),
		TREE = managers.localization:text(self._tree)
	})
	local color_ranges = {}
	local range_start
	while true do
		local pos = prompt_text:find("##")
		if pos then
			if range_start then
				table.insert(color_ranges, {
					range_start,
					pos - 1
				})
				range_start = nil
			else
				range_start = pos - 1
			end
			prompt_text = prompt_text:gsub("##", "", 1)
		else
			break
		end
	end

	local text = self._panel:text({
		text = prompt_text,
		font = tweak_data.menu.pd2_large_font,
		font_size = 20,
		wrap = true,
		align = "center",
		x = padding,
		y = y,
		w = self._panel:w() - padding * 2
	})
	local _, _, _, h = text:text_rect()
	text:set_h(h)
	for _, color_range in ipairs(color_ranges) do
		text:set_range_color(color_range[1], color_range[2], tweak_data.screen_colors.button_stage_3:with_alpha(1))
	end

	y = text:bottom() + padding

	for _, v in pairs(self._skills) do
		local icon_xy = tweak_data.skilltree.skills[v.skill].icon_xy

		v.button = HUDBGBox_create(self._panel, {
			w = size,
			h = size,
			x = padding + col * (size + padding),
			y = y + row * (size + padding)
		}, {
			bg_color = Color.white
		})
		self:set_button_corners_visible(v.button, false)
		v.button:child("bg"):set_alpha(0.05)

		v.button:bitmap({
			texture = "guis/textures/pd2/skilltree_2/icons_atlas_2",
			texture_rect = { icon_xy[1] * 80, icon_xy[2] * 80, 80, 80 },
			w = v.button:w(),
			h = v.button:h()
		})

		if col >= 2 then
			col = 0
			row = row + 1
		else
			col = col + 1
		end
	end

	y = self._skills[#self._skills].button:bottom() + padding

	self._ok_button = HUDBGBox_create(self._panel, {
		w = self._panel:w() - 2 * padding,
		h = 24,
		x = padding,
		y = y
	}, {
		bg_color = tweak_data.screen_colors.button_stage_3:with_alpha(1)
	})
	self:set_button_corners_visible(self._ok_button, false)
	self._ok_button:child("bg"):set_alpha(0.5)

	self._ok_button:text({
		text = managers.localization:to_upper_text("ChaosModifierCaptchaVerify"),
		font = tweak_data.menu.pd2_large_font,
		font_size = 20,
		align = "center",
		vertical = "center"
	})

	self._panel:set_h(self._ok_button:bottom() + padding)

	self._panel:set_center(self._panel:parent():w() * 0.5, self._panel:parent():h() * 0.5)

	if self._wrong_attempt then
		self._panel:animate(function()
			ChaosMod:anim_over(0.5, function(p)
				self._bg:set_color(math.lerp(Color.red, Color.black, p):with_alpha(0.75))
				local s = 8 * math.map_range_clamped(p, 0.5, 1, 1, 0)
				self._panel:set_center_x(self._panel:parent():w() * 0.5 + math.sin(p * 360 * 4) * s)
			end)
		end)
	end
end

function ChaosModifierCaptcha:set_button_corners_visible(button, visible)
	button:child("left_top"):set_visible(visible)
	button:child("left_bottom"):set_visible(visible)
	button:child("right_top"):set_visible(visible)
	button:child("right_bottom"):set_visible(visible)
end

function ChaosModifierCaptcha:mouse_move(o, x, y)
	local any_over = false
	for _, v in pairs(self._skills) do
		if v.button:inside(x, y) then
			any_over = true
			self:set_button_corners_visible(v.button, true)
		else
			self:set_button_corners_visible(v.button, false)
		end
	end
	if self._ok_button:inside(x, y) then
		any_over = true
		self:set_button_corners_visible(self._ok_button, true)
	else
		self:set_button_corners_visible(self._ok_button, false)
	end
	managers.mouse_pointer:set_pointer_image(any_over and "link" or "arrow")
end

function ChaosModifierCaptcha:mouse_press(o, button, x, y)
	if button ~= Idstring("0") then
		return
	end
	for _, v in pairs(self._skills) do
		if v.button:inside(x, y) then
			v.pressed = true
			v.button:child("bg"):set_alpha(0.2)
		end
	end
	if self._ok_button:inside(x, y) then
		self._ok_button_pressed = true
		self._ok_button:child("bg"):set_alpha(0.75)
	end
end

function ChaosModifierCaptcha:mouse_release(o, button, x, y)
	if button ~= Idstring("0") then
		return
	end
	for _, v in pairs(self._skills) do
		if v.pressed then
			v.pressed = false
			v.checked = not v.checked
		end
		v.button:child("bg"):set_color(v.checked and tweak_data.screen_colors.button_stage_3:with_alpha(1) or Color.white)
		v.button:child("bg"):set_alpha(v.checked and 0.25 or 0.05)
	end
	if self._ok_button_pressed then
		self._ok_button_pressed = false
		self:verify()
	end
end

function ChaosModifierCaptcha:verify()
	self._wrong_attempt = false

	for _, v in pairs(self._skills) do
		if (not v.checked) == (v.subtree_name_id == self._subtree) then
			self._wrong_attempt = true
			break
		end
	end

	if not self._wrong_attempt then
		self:complete()
	end

	self:stop()

	if not self._wrong_attempt then
		managers.menu:post_event("menu_exit")
	else
		managers.menu:post_event("menu_error")
		self:start()
	end
end

return ChaosModifierCaptcha
