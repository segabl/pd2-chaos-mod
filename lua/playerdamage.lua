function PlayerDamage:do_medic_heal()
	self:revive(true)
	managers.hint:show_hint("you_were_helpedup", nil, false, {
		TEAMMATE = self._unit:base():nick_name(),
		HELPER = managers.localization:text("ChaosModifierPocketMedicHelperName")
	})
end

Hooks:PostHook(PlayerDamage, "update", "update_chaos_mod", function(self, unit, t)
	if not self:need_revive() then
		self._chaos_medic_revive_check_t = nil
		if not self._chaos_medic_heal_t or t >= self._chaos_medic_heal_t then
			self._chaos_medic_heal_t = t + 1
			if next(managers.enemy:find_nearby_affiliated_medics(unit)) then
				self:restore_health(0.015, false, true)
			end
		end
		return
	elseif not self._chaos_medic_revive_check_t then
		self._chaos_medic_revive_check_t = t + 0.5
		return
	elseif self._chaos_medic_revive_check_t > t then
		return
	end

	self._chaos_medic_revive_check_t = t + 0.5
	local medic = managers.enemy:get_nearby_medic(unit)
	if medic then
		medic:character_damage():heal_unit(unit)
	end
end)
