local function assign_metatables(self)
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
		__index = function(t, k) return rawget(self.russian.weapon, k) or rawget(t, "is_rifle") end
	}
	local preset_mt = {
		__index = function(t, k)
			if k == "tase_sphere_cast_radius" or k == "tase_distance" then
				return rawget(self.taser.weapon.is_rifle, k)
			end
		end
	}
	for _, v in pairs(self) do
		if type(v) == "table" and type(v.weapon) == "table" and type(v.damage) == "table" then
			setmetatable(v, char_mt)
			setmetatable(v.weapon, weapon_mt)
			for _, preset in pairs(v.weapon) do
				setmetatable(preset, preset_mt)
			end
		end
	end
end

Hooks:PostHook(CharacterTweakData, "_set_easy", "_set_easy_chaos_mod", assign_metatables)
Hooks:PostHook(CharacterTweakData, "_set_normal", "_set_normal_chaos_mod", assign_metatables)
Hooks:PostHook(CharacterTweakData, "_set_hard", "_set_hard_chaos_mod", assign_metatables)
Hooks:PostHook(CharacterTweakData, "_set_overkill", "_set_overkill_chaos_mod", assign_metatables)
Hooks:PostHook(CharacterTweakData, "_set_overkill_145", "_set_overkill_145_chaos_mod", assign_metatables)
Hooks:PostHook(CharacterTweakData, "_set_easy_wish", "_set_easy_wish_chaos_mod", assign_metatables)
Hooks:PostHook(CharacterTweakData, "_set_overkill_290", "_set_overkill_290_chaos_mod", assign_metatables)
Hooks:PostHook(CharacterTweakData, "_set_sm_wish", "_set_sm_wish_chaos_mod", assign_metatables)
