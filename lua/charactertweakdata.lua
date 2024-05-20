Hooks:PostHook(CharacterTweakData, "init", "init_chaos_mod", function(self)
	local weapon_mt = {
		__index = function(t, k) return rawget(t, "is_rifle") end
	}
	for _, enemy_name in pairs(self._enemy_list) do
		setmetatable(self[enemy_name].weapon, weapon_mt)
	end
end)
