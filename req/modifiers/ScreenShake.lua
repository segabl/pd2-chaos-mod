ChaosModifierScreenShake = ChaosModifier.class("ChaosModifierScreenShake")
ChaosModifierScreenShake.duration = 30

function ChaosModifierScreenShake:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local duration = math.min(math.rand(2, 5), self._activation_t + self.duration - t)
	local feedback = managers.feedback:create("mission_triggered")

	feedback:set_unit(player_unit)
	feedback:set_enabled("camera_shake", true)

	feedback:play(
		"camera_shake",
		"multiplier",
		math.rand(1, 2),
		"camera_shake",
		"amplitude",
		1,
		"camera_shake",
		"attack",
		duration * 0.1,
		"camera_shake",
		"sustain",
		duration * 0.5,
		"camera_shake",
		"decay",
		duration * 0.4
	)

	self._next_t = t + duration + math.rand(0, 2)
end

return ChaosModifierScreenShake
