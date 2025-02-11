ChaosModifierMeleeCuffs = ChaosModifier.class("ChaosModifierMeleeCuffs")
ChaosModifierMeleeCuffs.loud_only = true
ChaosModifierMeleeCuffs.duration = 60

function ChaosModifierMeleeCuffs:start()
	self:override(CopBrain._logic_variants.security, "attack", TankCopLogicAttack)
	self:override(CopLogicAttack, "_find_flank_pos", function(_, _, flank_tracker)
		return flank_tracker:field_position()
	end)
	self:post_hook(PlayerDamage, "damage_melee", function(playerdamage)
		if Hooks:GetReturn() ~= "countered" and playerdamage._unit == managers.player:local_player() then
			managers.player:set_player_state("arrested")
		end
	end)
end

return ChaosModifierMeleeCuffs
