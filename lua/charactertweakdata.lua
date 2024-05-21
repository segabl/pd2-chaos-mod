Hooks:PostHook(CharacterTweakData, "init", "init_chaos_mod", function(self)
	local weapon_mt = {
		__index = function(t, k) return rawget(t, "is_rifle") end
	}
	for _, enemy_name in pairs(self._enemy_list) do
		setmetatable(self[enemy_name].weapon, weapon_mt)
		for _, weapon_data in pairs(self[enemy_name].weapon) do
			weapon_data.tase_sphere_cast_radius = self.taser.weapon.is_rifle.tase_sphere_cast_radius
			weapon_data.tase_distance = self.taser.weapon.is_rifle.tase_distance
		end
	end
end)
