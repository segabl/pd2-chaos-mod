ChaosModifierPushUp = ChaosModifier.class("ChaosModifierPushUp")
ChaosModifierPushUp.run_as_client = true
ChaosModifierPushUp.duration = 20

function ChaosModifierPushUp:start()
	self:pre_hook(PlayerDamage, "damage_fall", function(playerdamage, data)
		data.height = 0
	end)
end

function ChaosModifierPushUp:update(t, dt)
	local player_unit = managers.player:player_unit()
	if alive(player_unit) and not player_unit:movement():in_air() then
		player_unit:movement():push(math.UP * 600)
	end
end

return ChaosModifierPushUp
