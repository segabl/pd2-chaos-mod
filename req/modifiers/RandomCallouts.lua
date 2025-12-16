ChaosModifierRandomCallouts = ChaosModifier.class("ChaosModifierRandomCallouts")
ChaosModifierRandomCallouts.duration = 60
ChaosModifierRandomCallouts.event_names = {
	"f30x_any", "f310x_any", "f32x_any", "f33x_any", "f35x_any", "f47x_any", "g80x_plu", "f11e_plu"
}

function ChaosModifierRandomCallouts:start()
	self._bain_chance = 0.1
	self._next_t = self._activation_t + math.rand(1, 3)
	self._ss = SoundDevice:create_source("ChaosModifierRandomCallouts")

	self._sound_events = {
		cloaker_detect_mono = true,
		taser_charge = true
	}
	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		if enemy.spawn_sound_event and enemy.tags and table.contains(enemy.tags, "special") and not table.contains(enemy.tags, "medic") then
			self._sound_events[enemy.spawn_sound_event] = true
			if enemy.chatter and enemy.chatter.aggressive then
				self._sound_events[tostring(enemy.speech_prefix_p1) .. "_g90"] = true
			end
			if enemy.chatter and enemy.chatter.contact then
				self._sound_events[tostring(enemy.speech_prefix_p1) .. "_c01"] = true
			end
		end
	end
	self._sound_events = table.map_keys(self._sound_events)
end

function ChaosModifierRandomCallouts:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + math.rand(5, 8)

	if self._downed_id then
		managers.hud:set_mugshot_normal(self._downed_id)
		self._downed_id = nil
	end

	local bain_say = managers.groupai:state():bain_state() and math.random() < self._bain_chance
	if not bain_say then
		self._bain_chance = self._bain_chance + 0.05
	else
		self._bain_chance = 0.1
	end

	local characters = {}
	local player_unit = managers.player:player_unit()
	for _, data in pairs(managers.groupai:state():all_char_criminals()) do
		if not data.status and alive(data.unit) and data.unit ~= player_unit then
			table.insert(characters, data.unit)
		end
	end

	local character = table.random(characters)

	if alive(player_unit) and (not character or not bain_say and math.random() < 0.5) then
		local pos = player_unit:movement():detect_look_dir():with_z(0)
		mvector3.normalize(pos)
		mvector3.negate(pos)
		local right = math.UP:cross(pos)
		if math.random() < 0.5 then
			mvector3.negate(right)
		end
		mvector3.lerp(pos, pos, right, math.random() * 0.85)
		mvector3.multiply(pos, math.random(300, 1000))
		mvector3.set_z(pos, math.random(-100, 200))
		mvector3.add(pos, player_unit:movement():m_head_pos())

		self._ss:set_position(pos)
		self._ss:post_event(table.random(self._sound_events))
	elseif character then
		if bain_say then
			managers.dialog:queue_narrator_dialog("q01" .. managers.criminals:character_static_data_by_unit(character).ssuffix, {})
			self._downed_id = character:unit_data().mugshot_id
			managers.hud:set_mugshot_downed(self._downed_id)
		else
			character:sound():say(table.random(self.event_names))
		end
	end
end

function ChaosModifierRandomCallouts:stop()
	if self._downed_id then
		managers.hud:set_mugshot_normal(self._downed_id)
	end

	self._ss:stop()
	self._ss:delete()
end

return ChaosModifierRandomCallouts
