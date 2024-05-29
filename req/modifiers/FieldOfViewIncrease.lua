ChaosModifierFieldOfViewIncrease = ChaosModifier.class("ChaosModifierFieldOfViewIncrease")
ChaosModifierFieldOfViewIncrease.run_as_client = true
ChaosModifierFieldOfViewIncrease.duration = 30

function ChaosModifierFieldOfViewIncrease:start()
	self._active = true

	self:post_hook(PlayerStandard, "get_zoom_fov", function()
		return self._active and 160 or nil
	end)

	local player_unit = managers.player:player_unit()
	if alive(player_unit) then
		player_unit:movement():current_state():update_fov_external()
	end
end

function ChaosModifierFieldOfViewIncrease:stop()
	self._active = false

	local player_unit = managers.player:player_unit()
	if alive(player_unit) then
		player_unit:movement():current_state():update_fov_external()
	end
end

return ChaosModifierFieldOfViewIncrease
