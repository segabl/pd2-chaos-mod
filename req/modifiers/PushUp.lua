---@class ChaosModifierPushUp : ChaosModifier
ChaosModifierPushUp = class(ChaosModifier)
ChaosModifierPushUp.class_name = "ChaosModifierPushUp"
ChaosModifierPushUp.duration = 20
ChaosModifierPushUp.run_as_client = true

function ChaosModifierPushUp:start()
	Hooks:PreHook(PlayerDamage, "damage_fall", self.class_name, function(playerdamage, data)
		data.height = 0
	end)
end

function ChaosModifierPushUp:stop()
	Hooks:RemovePreHook(self.class_name)
end

function ChaosModifierPushUp:update(t, dt)
	local player_unit = managers.player:player_unit()
	if alive(player_unit) and not player_unit:movement():in_air() then
		player_unit:movement():push(math.UP * 600)
	end
end

return ChaosModifierPushUp
