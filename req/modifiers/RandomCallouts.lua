ChaosModifierRandomCallouts = ChaosModifier.class("ChaosModifierRandomCallouts")
ChaosModifierRandomCallouts.run_as_client = true
ChaosModifierRandomCallouts.duration = 60
ChaosModifierRandomCallouts.event_names = {
	"f30x_any", "f310x_any", "f32x_any", "f33x_any", "f35x_any", "f47x_any", "g80x_plu", "g81x_plu", "f11e_plu"
}

function ChaosModifierRandomCallouts:start()
	self._bain_chance = 0.1
	self._next_t = self._activation_t + math.rand(1, 3)
end

function ChaosModifierRandomCallouts:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

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
	local player_unit = managers.player:local_player()
	for _, data in pairs(managers.groupai:state():all_char_criminals()) do
		if not data.status and alive(data.unit) and data.unit ~= player_unit and (bain_say or not data.unit:sound():speaking(t)) then
			table.insert(characters, data.unit)
		end
	end

	local character = table.random(characters)
	if character then
		if bain_say then
			managers.dialog:queue_narrator_dialog("q01" .. managers.criminals:character_static_data_by_unit(character).ssuffix, {})
			self._downed_id = character:unit_data().mugshot_id
			managers.hud:set_mugshot_downed(self._downed_id)
		else
			character:sound():say(table.random(self.event_names))
		end
		self._next_t = t + math.rand(4, 6)
	end
end

function ChaosModifierRandomCallouts:stop()
	if self._downed_id then
		managers.hud:set_mugshot_normal(self._downed_id)
	end
end

return ChaosModifierRandomCallouts
