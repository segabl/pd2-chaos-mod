---@class ChaosModifierRandomCallouts : ChaosModifier
ChaosModifierRandomCallouts = class(ChaosModifier)
ChaosModifierRandomCallouts.class_name = "ChaosModifierRandomCallouts"
ChaosModifierRandomCallouts.duration = 60
ChaosModifierRandomCallouts.run_as_client = true
ChaosModifierRandomCallouts.event_names = {
	"f30x_any", "f310x_any", "f32x_any", "f33x_any", "f35x_any", "f47x_any", "g80x_plu", "g81x_plu", "f11e_plu"
}

function ChaosModifierRandomCallouts:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	local characters = {}
	local player_unit = managers.player:local_player()
	for _, data in pairs(managers.groupai:state():all_char_criminals()) do
		if not data.status and alive(data.unit) and data.unit ~= player_unit and not data.unit:sound():speaking(t) then
			table.insert(characters, data.unit)
		end
	end

	local character = table.random(characters)
	if character then
		character:sound():say(table.random(self.event_names))
		self._next_t = t + math.rand(4, 6)
	end
end

return ChaosModifierRandomCallouts
