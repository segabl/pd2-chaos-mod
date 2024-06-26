ChaosModifierJulesify = ChaosModifier.class("ChaosModifierJulesify")
ChaosModifierJulesify.run_as_client = false
ChaosModifierJulesify.run_in_stealth = false
ChaosModifierJulesify.duration = 120
ChaosModifierJulesify.weight_mul = 0.5
ChaosModifierJulesify.enabled = StreamHeist and true
ChaosModifierJulesify.allowed_poses = { crouch = true }

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

	for tactic_name, tactic_data in pairs(tweak_data.group_ai._tactics) do
		local new_tactic_data = clone(tactic_data)
		table.delete(new_tactic_data, "shield")
		table.delete(new_tactic_data, "shield_cover")
		table.delete(new_tactic_data, "flank")
		table.delete(new_tactic_data, "ranged_fire")
		table.delete(new_tactic_data, "murder")
		self:override(tweak_data.group_ai._tactics, tactic_name, new_tactic_data)
	end

	for group_name in pairs(tweak_data.group_ai.enemy_spawn_groups) do
		if group_name:match("shotgun") then
			self:override(tweak_data.group_ai.enemy_spawn_groups, group_name, nil)
		end
	end

	self:override(tweak_data.group_ai, "spawn_cooldown_mul", 0)

	self:override(tweak_data.group_ai.besiege.assault, "force", { 14, 16, 18 })
	self:override(tweak_data.group_ai.besiege.assault, "force_balance_mul", { 1.5, 3, 4.5, 6 })
	self:override(tweak_data.group_ai.besiege.assault, "force_pool", { 150, 175, 225 })
	self:override(tweak_data.group_ai.besiege.assault, "force_pool_balance_mul", { 1.5, 3, 4.5, 6 })
end

return ChaosModifierJulesify
