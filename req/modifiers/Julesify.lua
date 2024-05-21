ChaosModifierJulesify = ChaosModifier.class("ChaosModifierJulesify")
ChaosModifierJulesify.duration = 120
ChaosModifierJulesify.allowed_poses = { crouch = true }

function ChaosModifierJulesify:can_trigger()
	return StreamHeist and true
end

function ChaosModifierJulesify:start()
	self:post_hook(CopLogicIdle, "_chk_relocate", function(data)
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
			self:override(enemy, "allowed_poses", self.allowed_poses)
		end
	end

	self:override(tweak_data.group_ai, "spawn_cooldown_mul", 0)

	self:override(tweak_data.group_ai.besiege.assault, "force", { 14, 16, 18 })
	self:override(tweak_data.group_ai.besiege.assault, "force_balance_mul", { 1.5, 3, 4.5, 6 })
	self:override(tweak_data.group_ai.besiege.assault, "force_pool", { 150, 175, 225 })
	self:override(tweak_data.group_ai.besiege.assault, "force_pool_balance_mul", { 1.5, 3, 4.5, 6 })

	self:override(tweak_data.group_ai.enemy_spawn_groups, "tac_swat_shotgun_rush", nil)
	self:override(tweak_data.group_ai.enemy_spawn_groups, "tac_swat_shotgun_rush_no_medic", nil)
	self:override(tweak_data.group_ai.enemy_spawn_groups, "tac_swat_shotgun_flank", nil)
	self:override(tweak_data.group_ai.enemy_spawn_groups, "tac_swat_shotgun_flank_no_medic", nil)
	self:override(tweak_data.group_ai.enemy_spawn_groups, "tac_swat_rifle", nil)
	self:override(tweak_data.group_ai.enemy_spawn_groups, "tac_swat_shotgun_rush", nil)
	self:override(tweak_data.group_ai.enemy_spawn_groups, "tac_swat_rifle_no_medic", nil)
end

return ChaosModifierJulesify
