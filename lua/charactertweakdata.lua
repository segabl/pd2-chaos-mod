Hooks:PostHook(CharacterTweakData, "init", "init_chaos_mod", function(self)
	local char_mt = {
		__index = function(t, k)
			if k == "spooc_attack_timeout" or k == "spooc_attack_beating_time" or k == "spooc_sound_events" then
				return rawget(self.spooc, k)
			elseif k == "spooc_attack_use_smoke_chance" then
				return 0
			end
		end
	}
	local weapon_mt = {
		__index = function(t, k) return rawget(t, "is_rifle") end
	}
	local preset_mt = {
		__index = function(t, k)
			if k == "tase_sphere_cast_radius" or k == "tase_distance" then
				return rawget(self.taser.weapon.is_rifle, k)
			end
		end
	}
	for _, enemy_name in pairs(self._enemy_list) do
		local enemy = self[enemy_name]
		setmetatable(enemy, char_mt)
		setmetatable(enemy.weapon, weapon_mt)
		for _, preset in pairs(enemy.weapon) do
			setmetatable(preset, preset_mt)
		end
	end
end)
