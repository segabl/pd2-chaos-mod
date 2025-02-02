ChaosModifierMeleeCuffs = ChaosModifier.class("ChaosModifierMeleeCuffs")
ChaosModifierMeleeCuffs.loud_only = true
ChaosModifierMeleeCuffs.duration = 60

function ChaosModifierMeleeCuffs:start()
	self:post_hook(PlayerDamage, "damage_melee", function(playerdamage)
		if Hooks:GetReturn() ~= "countered" and playerdamage._unit == managers.player:local_player() then
			managers.player:set_player_state("arrested")
		end
	end)
end

return ChaosModifierMeleeCuffs
