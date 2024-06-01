ChaosModifierFieldOfViewIncrease = ChaosModifier.class("ChaosModifierFieldOfViewIncrease")
ChaosModifierFieldOfViewIncrease.run_as_client = true
ChaosModifierFieldOfViewIncrease.duration = 30

function ChaosModifierFieldOfViewIncrease:update_fov()
	local player_unit = managers.player:player_unit()
	if alive(player_unit) then
		player_unit:movement():current_state():update_fov_external()
	end
end

function ChaosModifierFieldOfViewIncrease:start()
	self:post_hook(PlayerDriving, "get_zoom_fov", function()
		return math.max(Hooks:GetReturn(), math.min(Hooks:GetReturn() * 2.5, 160))
	end)

	self:post_hook(PlayerStandard, "get_zoom_fov", function()
		return math.max(Hooks:GetReturn(), math.min(Hooks:GetReturn() * 2.5, 160))
	end)

	self:update_fov()
end

function ChaosModifierFieldOfViewIncrease:stop()
	self:update_fov()
end

return ChaosModifierFieldOfViewIncrease
