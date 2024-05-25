ChaosModifierForceCrouch = ChaosModifier.class("ChaosModifierForceCrouch")
ChaosModifierForceCrouch.run_as_client = true
ChaosModifierForceCrouch.duration = 20

function ChaosModifierForceCrouch:start()
	self:post_hook(PlayerStandard, "_get_input", function(playerstate)
		local input = Hooks:GetReturn()
		input.btn_duck_press = playerstate._setting_hold_to_duck or not playerstate._state_data.ducking
		input.btn_duck_release = false
	end)
end

function ChaosModifierForceCrouch:stop()
	local player_unit = managers.player:local_player()
	if alive(player_unit) then
		player_unit:movement():current_state():_interupt_action_ducking(TimerManager:game():time())
	end
end

return ChaosModifierForceCrouch
