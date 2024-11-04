ChaosModifierPulsingFov = ChaosModifier.class("ChaosModifierPulsingFov")
ChaosModifierPulsingFov.duration = 30

function ChaosModifierPulsingFov:start()
	self._fov_multiplier = 1
	self:post_hook(PlayerStandard, "get_zoom_fov", function(playerstate)
		return Hooks:GetReturn() * self._fov_multiplier
	end)
end

function ChaosModifierPulsingFov:update(t, dt)
	self._fov_multiplier = 1 + (math.sin((t - self._activation_t) * 270) - 1) * 0.05

	local player_unit = managers.player:player_unit()
	if alive(player_unit) then
		player_unit:movement():current_state():update_fov_external()
	end
end

return ChaosModifierPulsingFov
