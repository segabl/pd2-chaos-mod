ChaosModifierMeleeCuffs = ChaosModifier.class("ChaosModifierMeleeCuffs")
ChaosModifierMeleeCuffs.loud_only = true
ChaosModifierMeleeCuffs.duration = 60

function ChaosModifierMeleeCuffs:start()
	self:override(CopBrain._logic_variants.security, "attack", TankCopLogicAttack)
	self:override(CopLogicAttack, "_find_flank_pos", function(data, _, flank_tracker)
		local field_pos = flank_tracker:field_position()
		local pos = Vector3(0, 0, 0)
		mvector3.direction(pos, field_pos, data.m_pos)
		mvector3.multiply(pos, 75)
		mvector3.add(pos, field_pos)
		return pos
	end)
	self:post_hook(PlayerDamage, "damage_melee", function(playerdamage)
		if Hooks:GetReturn() ~= "countered" and playerdamage._unit == managers.player:local_player() then
			managers.player:set_player_state("arrested")
		end
	end)
end

return ChaosModifierMeleeCuffs
