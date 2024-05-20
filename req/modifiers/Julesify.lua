---@class ChaosModifierJulesify : ChaosModifier
ChaosModifierJulesify = class(ChaosModifier)
ChaosModifierJulesify.class_name = "ChaosModifierJulesify"
ChaosModifierJulesify.name = "Jules-ify"
ChaosModifierJulesify.duration = 120
ChaosModifierJulesify.allowed_poses = { crouch = true }

function ChaosModifierJulesify:can_trigger()
	return StreamHeist and true
end

function ChaosModifierJulesify:start()
	Hooks:PostHook(CopLogicIdle, "_chk_relocate", self.class_name, function(data)
		if not data.objective or data.objective.type ~= "defend_area" then
			return
		end

		local area = data.objective.area
		if not area or next(area.criminal.units) then
			return
		end

		local found_areas = { [area] = true }
		local areas_to_search = { area }
		local target_area

		while next(areas_to_search) do
			local current_area = table.remove(areas_to_search)
			if next(current_area.criminal.units) then
				target_area = current_area
				break
			end

			for _, n_area in pairs(current_area.neighbours) do
				if not found_areas[n_area] then
					found_areas[n_area] = true
					table.insert(areas_to_search, n_area)
				end
			end
		end

		if target_area then
			data.objective.pose = "crouch"
			data.objective.in_place = nil
			data.objective.nav_seg = next(target_area.nav_segs)
			data.objective.path_data = { { data.objective.nav_seg } }
			data.logic._exit(data.unit, "travel")
			return true
		end
	end)

	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		if not enemy.allowed_poses then
			enemy.original_allowed_poses = false
			enemy.allowed_poses = self.allowed_poses
		end
	end

	ChaosModifierJulesify._spawn_cooldown_mul = ChaosModifierJulesify._spawn_cooldown_mul or tweak_data.group_ai.spawn_cooldown_mul

	tweak_data.group_ai.spawn_cooldown_mul = 0

	local assault = tweak_data.group_ai.besiege.assault
	ChaosModifierJulesify._force = ChaosModifierJulesify._force or assault.force
	ChaosModifierJulesify._force_balance_mul = ChaosModifierJulesify._force_balance_mul or assault.force_balance_mul
	ChaosModifierJulesify._force_pool = ChaosModifierJulesify._force_pool or assault.force_pool
	ChaosModifierJulesify._force_pool_balance_mul = ChaosModifierJulesify._force_pool_balance_mul or assault.force_pool_balance_mul

	assault.force = { 14, 16, 18 }
	assault.force_balance_mul = { 1.5, 3, 4.5, 6 }
	assault.force_pool = { 150, 175, 225 }
	assault.force_pool_balance_mul = { 1.5, 3, 4.5, 6 }

	local groups = tweak_data.group_ai.enemy_spawn_groups
	ChaosModifierJulesify._tac_swat_shotgun_rush = ChaosModifierJulesify._tac_swat_shotgun_rush or groups.tac_swat_shotgun_rush
	ChaosModifierJulesify._tac_swat_shotgun_rush_no_medic = ChaosModifierJulesify._tac_swat_shotgun_rush_no_medic or groups.tac_swat_shotgun_rush_no_medic
	ChaosModifierJulesify._tac_swat_shotgun_flank = ChaosModifierJulesify._tac_swat_shotgun_flank or groups.tac_swat_shotgun_flank
	ChaosModifierJulesify._tac_swat_shotgun_flank_no_medic = ChaosModifierJulesify._tac_swat_shotgun_flank_no_medic or groups.tac_swat_shotgun_flank_no_medic
	ChaosModifierJulesify._tac_swat_rifle = ChaosModifierJulesify._tac_swat_rifle or groups.tac_swat_rifle
	ChaosModifierJulesify._tac_swat_rifle_no_medic = ChaosModifierJulesify._tac_swat_rifle_no_medic or groups.tac_swat_rifle_no_medic

	groups.tac_swat_shotgun_rush = nil
	groups.tac_swat_shotgun_rush_no_medic = nil
	groups.tac_swat_shotgun_flank = nil
	groups.tac_swat_shotgun_flank_no_medic = nil
	groups.tac_swat_rifle = nil
	groups.tac_swat_rifle_no_medic = nil
end

function ChaosModifierJulesify:stop()
	Hooks:RemovePostHook(self.class_name)

	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		if enemy.original_allowed_poses ~= nil then
			enemy.allowed_poses = enemy.original_allowed_poses or nil
		end
	end

	tweak_data.group_ai.spawn_cooldown_mul = ChaosModifierJulesify._spawn_cooldown_mul

	local assault = tweak_data.group_ai.besiege.assault
	assault.force = ChaosModifierJulesify._force
	assault.force_balance_mul = ChaosModifierJulesify._force_balance_mul
	assault.force_pool = ChaosModifierJulesify._force_pool
	assault.force_pool_balance_mul = ChaosModifierJulesify._force_pool_balance_mul

	local groups = tweak_data.group_ai.enemy_spawn_groups
	groups.tac_swat_shotgun_rush = ChaosModifierJulesify._tac_swat_shotgun_rush
	groups.tac_swat_shotgun_rush_no_medic = ChaosModifierJulesify._tac_swat_shotgun_rush_no_medic
	groups.tac_swat_shotgun_flank = ChaosModifierJulesify._tac_swat_shotgun_flank
	groups.tac_swat_shotgun_flank_no_medic = ChaosModifierJulesify._tac_swat_shotgun_flank_no_medic
	groups.tac_swat_rifle = ChaosModifierJulesify._tac_swat_rifle
	groups.tac_swat_rifle_no_medic = ChaosModifierJulesify._tac_swat_rifle_no_medic
end

return ChaosModifierJulesify
