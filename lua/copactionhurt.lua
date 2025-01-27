function CopActionHurt:clbk_shooting_hurt()
	self._delayed_shooting_hurt_clbk_id = nil

	if not alive(self._weapon_unit) then
		return
	end

	local fire_obj = self._weapon_unit:base().fire_object and self._weapon_unit:base():fire_object()
	if fire_obj then
		self._weapon_unit:base():singleshot(fire_obj:position(), fire_obj:rotation():y())
	end
end
