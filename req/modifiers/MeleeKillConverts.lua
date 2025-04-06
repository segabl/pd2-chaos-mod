ChaosModifierMeleeKillConverts = ChaosModifier.class("ChaosModifierMeleeKillConverts")
ChaosModifierMeleeKillConverts.run_as_client = false
ChaosModifierMeleeKillConverts.loud_only = true
ChaosModifierMeleeKillConverts.duration = 45

function ChaosModifierMeleeKillConverts:start()
	self._units = {}

	self:post_hook(CopDamage, "die", function(copdamage, attack_data)
		if attack_data.variant == "melee" and alive(attack_data.attacker_unit) and managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
			DelayedCalls:Add(tostring(copdamage._unit:key()) .. "spawn", 0.25, function()
				self:spawn(copdamage._unit:name(), copdamage._unit:position(), copdamage._unit:rotation(), attack_data.attacker_unit)
			end)
		end
	end)

	self:post_hook(GroupAIStateBase, "_determine_objective_for_criminal_AI", function(gstate, unit)
		local data = self._units[unit:key()]
		if not data then
			return
		end

		if not alive(data.player_unit) or not data.player_unit:movement():nav_tracker() then
			return {
				type = "free",
				scan = true
			}
		else
			return {
				type = "follow",
				scan = true,
				follow_unit = data.player_unit,
				distance = 400
			}
		end
	end)

	self:show_text(managers.localization:to_upper_text("ChaosModifierMeleeKillConvertsStart"), 4)
end

function ChaosModifierMeleeKillConverts:stop()
	for _, data in pairs(self._units) do
		if alive(data.unit) then
			data.unit:character_damage():set_invulnerable(false)
			data.unit:character_damage():damage_mission({})
		end
	end
end

function ChaosModifierMeleeKillConverts:spawn(unit_name, pos, rot, player_unit)
	local unit = World:spawn_unit(unit_name, pos, rot)
	unit:movement():set_team(managers.groupai:state():team_data("criminal1"))
	unit:brain():set_spawn_ai({
		init_state = "idle",
		stance = "cbt",
		objective = {
			type = "act",
			action = {
				align_sync = true,
				type = "act",
				body_part = 1,
				variant = "e_sp_crh_to_std_rifle",
				blocks = {
					heavy_hurt = -1,
					hurt = -1,
					action = -1,
					walk = -1
				}
			}
		},
		params = {
			scan = true
		}
	})

	unit:character_damage():set_invulnerable(true)
	unit:network():send("set_unit_invulnerable", true, false)
	DelayedCalls:Add(tostring(unit:key()) .. "invulnerable", 3, function()
		if alive(unit) then
			unit:character_damage():set_invulnerable(false)
			unit:network():send("set_unit_invulnerable", false, false)
		end
	end)

	local brain = unit:brain()
	local attention = PlayerMovement._create_attention_setting_from_descriptor(brain, tweak_data.attention.settings.team_enemy_cbt, "team_enemy_cbt")
	brain._attention_handler:override_attention("enemy_team_cbt", attention)
	brain._slotmask_enemies = managers.slot:get_mask("enemies")
	brain._logic_data.enemy_slotmask = brain._slotmask_enemies

	brain._logic_data.objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_complete")
	brain._logic_data.objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_failed")
	managers.groupai:state():on_criminal_jobless(unit)

	local u_key = unit:key()
	local listener_key = self.class_name .. tostring(u_key)
	unit:contour():add("highlight_character", true)

	unit:character_damage():add_listener(listener_key, { "death" }, function()
		unit:contour():remove("highlight_character", true)
		self._units[u_key] = nil
	end)

	unit:base():add_destroy_listener(listener_key, function()
		self._units[u_key] = nil
	end)

	self._units[u_key] = {
		unit = unit,
		player_unit = player_unit
	}
end

return ChaosModifierMeleeKillConverts
