ChaosModifierMeleeCuffs = ChaosModifier.class("ChaosModifierMeleeCuffs")
ChaosModifierMeleeCuffs.tags = { "EnemyMelee" }
ChaosModifierMeleeCuffs.conflict_tags = { "EnemyMelee" }
ChaosModifierMeleeCuffs.loud_only = true
ChaosModifierMeleeCuffs.duration = 60

function ChaosModifierMeleeCuffs:start()
	self:override(CopBrain._logic_variants.security, "attack", TankCopLogicAttack)
	self:override(CopLogicAttack, "_find_flank_pos", CopLogicAttack._find_pos_close_to_tracker)
	self:post_hook(PlayerDamage, "damage_melee", function(playerdamage)
		if Hooks:GetReturn() ~= "countered" and playerdamage._unit == managers.player:local_player() and not playerdamage:is_downed() then
			managers.player:set_player_state("arrested")
		end
	end)
end

return ChaosModifierMeleeCuffs
