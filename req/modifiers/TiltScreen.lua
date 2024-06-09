ChaosModifierTiltScreen = ChaosModifier.class("ChaosModifierTiltScreen")
ChaosModifierTiltScreen.duration = 30

function ChaosModifierTiltScreen:update(t, dt)
	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local s = math.sin(90 * (t - self._activation_t))
	player_unit:camera():camera_unit():base():set_target_tilt((s < 0 and -10 or 10) * (math.abs(s) ^ 0.9))
end

function ChaosModifierTiltScreen:stop()
	local player_unit = managers.player:local_player()
	if alive(player_unit) then
		player_unit:camera():camera_unit():base():set_target_tilt(0)
	end
end

return ChaosModifierTiltScreen
