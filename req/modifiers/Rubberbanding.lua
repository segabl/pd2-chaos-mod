---@class ChaosModifierRubberbanding : ChaosModifier
ChaosModifierRubberbanding = class(ChaosModifier)
ChaosModifierRubberbanding.class_name = "ChaosModifierRubberbanding"
ChaosModifierRubberbanding.run_as_client = true
ChaosModifierRubberbanding.duration = 30

function ChaosModifierRubberbanding:start()
	self._next_t = self._activation_t + math.rand(2, 4)
end

function ChaosModifierRubberbanding:stop()
	DelayedCalls:Remove(tostring(self))
end

function ChaosModifierRubberbanding:update(t, dt)
	if self._next_t > t then
		return
	end

	self._next_t = t + math.rand(2, 4)

	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	self._recorded_position = player_unit:position()
	DelayedCalls:Add(tostring(self), math.rand(0.5, 1), callback(self, self, "set_position"))
end

function ChaosModifierRubberbanding:set_position()
	local player_unit = managers.player:local_player()
	if alive(player_unit) then
		player_unit:movement():set_position(self._recorded_position)
	end
end

return ChaosModifierRubberbanding
