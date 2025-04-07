ChaosModifierKaraoke = ChaosModifier.class("ChaosModifierKaraoke")
ChaosModifierKaraoke.fixed_duration = true
ChaosModifierKaraoke.duration = 1
ChaosModifierKaraoke.weight_mul = 0.5
ChaosModifierKaraoke.songs = {
	"biting_elbows_for_the_kill",
	"drifting",
	"im_a_wild_one",
	"its_payday",
	"pth_i_will_give_you_my_all",
	"the_flames_of_love",
	"today_is_payday_too"
}

function ChaosModifierKaraoke:start()
	math.randomseed(self._seed)
	self.song_name = table.random(self.songs)

	self:parse_song(ChaosMod.mod_path .. "/data/" .. self.song_name .. ".txt")
	self.song = self:load_song(ChaosMod.mod_path .. "/data/" .. self.song_name .. ".json")
	self.current_line = 0

	self.start_t = self._activation_t + math.max(0, 4 - self.song[1].start)
	self.song_duration = self.song[#self.song].stop + 1

	self.lyrics_ball = self:create_lyrics_ball()

	self.current_event_name = Global.music_manager.current_event

	managers.music:post_event("stop_all_music")

	self:override(managers.music, "post_event", function(_, event) self.current_event_name = event end)
	self:override(managers.music, "check_music_switch", function()end)

	self:show_text(managers.localization:to_upper_text("ChaosModifierKaraoke") .. "\n\"" .. managers.localization:text("menu_jukebox_screen_" .. self.song_name) .. "\"", 3, true)
end

function ChaosModifierKaraoke:stop()
	if alive(self.lyrics_ball) then
		self.lyrics_ball:parent():remove(self.lyrics_ball)
	end

	for _, v in pairs(self.song) do
		if alive(v.panel) then
			v.panel:parent():remove(v.panel)
		end
	end

	Global.music_manager.source:post_event("stop_all_music")
	Global.music_manager.source:set_switch("music_randomizer", Global.music_manager.current_track)
	managers.music:post_event(self.current_event_name)
end

function ChaosModifierKaraoke:update(t, dt)
	if self.start_t > t then
		return
	end

	if not self.play_event then
		self.play_event = Global.music_manager.source:post_event(self.song_name, function(event, source, event_type, cookie, label)
			if event_type == "duration" then
				self.song_duration = math.max(label - 4, self.song_duration)
			elseif event_type == "end_of_event" then
				self._expired = true
			end
		end, nil, "end_of_event", "duration")
	end

	local song_t = t - self.start_t
	local current_line = self.song[self.current_line]
	local next_line = self.song[self.current_line + 1]

	local line_change_t
	if not current_line then
		line_change_t = math.max(next_line.start - 2, 0)
	elseif not next_line then
		line_change_t = math.min(current_line.stop + 4, self.song_duration)
	else
		line_change_t = math.max(math.lerp(current_line and current_line.stop or 0, next_line.start, 0.5), next_line.start - 2)
	end

	if current_line and alive(current_line.panel) then
		local line_hide_t = current_line.stop + 4
		if song_t >= line_change_t or song_t >= line_hide_t and line_change_t - line_hide_t > 2 then
			current_line.panel:stop()
			current_line.panel:animate(function(o)
				local a = o:alpha()
				local y = o:center_y()
				ChaosMod:anim_over(0.2, function(p)
					o:set_alpha(math.lerp(a, 0, p))
					o:set_center_y(math.lerp(y, y - o:h(), p))
				end)
				o:parent():remove(o)
			end)
			current_line.panel = nil
		else
			local next, current
			local current_color = (HUDChaosModifier.colors.default * 0.75):with_alpha(1)
			local prev_color = current_color * 2
			for i, text in pairs(current_line.panel:children()) do
				local note = current_line[i]
				if song_t < note.start then
					next = i
					break
				elseif song_t >= note.start and song_t <= note.stop then
					current = i
					text:set_color(current_color)
				elseif song_t > note.stop then
					text:set_color(prev_color)
				end
			end

			local x, y, a
			if song_t < current_line.start then
				local text = current_line.panel:child(0)
				x = math.map_range_clamped(song_t, current_line.start - 0.5, current_line.start, text:world_left() - 32, text:world_left())
				a = math.map_range_clamped(song_t, current_line.start - 0.5, current_line.start, 0, 1)
			elseif song_t > current_line.stop then
				local text = current_line.panel:child(#current_line - 1)
				x = math.map_range_clamped(song_t, current_line.stop, current_line.stop + 0.25, text:world_right(), text:world_right() + text:w())
				a = math.map_range_clamped(song_t, current_line.stop, current_line.stop + 0.25, 1, 0)
			elseif current then
				local note, text = current_line[current], current_line.panel:child(current - 1)
				x = math.map_range(song_t, note.start, note.stop, text:world_left(), text:world_right())
				y = math.sin(math.map_range(song_t, note.start, note.stop, 0, 180))
				a = 1
			elseif next then
				local prev_note, prev_text = current_line[next - 1], current_line.panel:child(next - 2)
				local next_note, next_text = current_line[next], current_line.panel:child(next - 1)
				x = math.map_range(song_t, prev_note.stop, next_note.start, prev_text:world_right(), next_text:world_left())
				a = 1
			end

			if alive(self.lyrics_ball) then
				self.lyrics_ball:set_world_center_x(x)
				self.lyrics_ball:set_world_bottom(current_line.panel:world_top() - (y or 0) * 16)
				self.lyrics_ball:set_alpha(a)
			end
		end
	end

	if next_line then
		if not alive(next_line.panel) then
			next_line.panel = self:create_lyrics_text(next_line)
			next_line.panel:set_center_y(next_line.panel:parent():h() * 0.675 + next_line.panel:h())
		else
			local a = math.map_range_clamped(song_t, math.max(line_change_t - 4, current_line and current_line.start or 0), line_change_t, 0, 0.5)
			next_line.panel:set_alpha(a)
		end

		if song_t > line_change_t then
			next_line.panel:stop()
			next_line.panel:animate(function(o)
				local a = o:alpha()
				local y = o:center_y()
				local y_target = next_line.panel:parent():h() * 0.675
				ChaosMod:anim_over(0.2, function(p)
					o:set_alpha(math.lerp(a, 1, p))
					o:set_center_y(math.lerp(y, y_target, p))
				end)
			end)
			self.current_line = self.current_line + 1
		end
	end
end

function ChaosModifierKaraoke:progress(t, dt)
	return self.start_t > t and 0 or (t - self.start_t) / self.song_duration
end

function ChaosModifierKaraoke:load_song(song_path)
	local song = io.load_as_json(song_path)
	for _, line in ipairs(song) do
		for i, note in ipairs(line) do
			if i < #line and not note.lyrics:ends(" ") and not line[i + 1].lyrics:begins(" ") then
				note.stop = (note.stop + line[i + 1].start) * 0.5
				line[i + 1].start = note.stop
			end
		end
		line.start = line[1].start
		line.stop = line[#line].stop
	end
	return song
end

function ChaosModifierKaraoke:create_lyrics_ball()
	return ChaosMod:panel():bitmap({
		layer = 99,
		texture = "guis/textures/pd2/hud_progress_32px",
		alpha = 0,
		color = (HUDChaosModifier.colors.default * HUDChaosModifier.colors.default.a):with_alpha(1),
		w = 16,
		h = 16
	})
end

function ChaosModifierKaraoke:create_lyrics_text(line, color)
	local panel = ChaosMod:panel():panel({
		layer = 98,
		alpha = 0
	})

	local max_w = 0
	local max_h = 0
	for _, v in ipairs(line) do
		local t = panel:text({
			text = v.lyrics,
			font = tweak_data.menu.pd2_large_font,
			font_size = 40,
			color = color or Color.white
		})
		local _, _, w, h = t:text_rect()
		t:set_x(max_w)
		t:set_size(w, h)
		max_w = max_w + w
		max_h = math.max(max_h, h)
		t:set_text(v.lyrics:trim())
		_, _, w, h = t:text_rect()
		if string.begins(v.lyrics, " ") then
			local r = t:right()
			t:set_size(w, h)
			t:set_right(r)
		else
			t:set_size(w, h)
		end
	end

	panel:set_size(max_w, max_h)
	panel:set_center_x(panel:parent():w() * 0.5)

	return panel
end

function ChaosModifierKaraoke:parse_song(song_path)
	local file = io.open(song_path, "r")
	if not file then
		return
	end

	local gap = 0
	local bps = 1
	local line = {}
	local song = {}

	for l in file:lines("*l") do
		local bpm_match = l:match("^#BPM:([0-9,.]+)")
		local gap_match = l:match("^#GAP:([0-9,.]+)")
		local start, length, lyrics = l:match("^[:*F] ([0-9]+) ([0-9]+) [0-9-]+ (.+)")
		local line_break_or_end = l:match("^[-E]")

		if bpm_match then
			bpm_match = bpm_match:gsub(",", ".")
			bps = (tonumber(bpm_match) / 60) * 4
		elseif gap_match then
			gap_match = gap_match:gsub(",", ".")
			gap = tonumber(gap_match) / 1000
		elseif start then
			if #line > 0 and lyrics:match("^%s?~+%s?$") then
				line[#line].stop = gap + (tonumber(start) + tonumber(length)) / bps
			else
				table.insert(line, {
					start = gap + tonumber(start) / bps,
					stop = gap + (tonumber(start) + tonumber(length)) / bps,
					lyrics = lyrics:gsub("~", "")
				})
			end
		elseif line_break_or_end then
			table.insert(song, line)
			line = {}
		end
	end
	file:close()

	io.save_as_json(song, song_path:gsub("%.txt$", ".json"))
end

return ChaosModifierKaraoke
