ChaosModifierMeleeKillConverts = ChaosModifier.class("ChaosModifierMeleeKillConverts")
ChaosModifierMeleeKillConverts.loud_only = true
ChaosModifierMeleeKillConverts.duration = 30

function ChaosModifierMeleeKillConverts:start()
	self:show_text(managers.localization:to_upper_text("ChaosModifierMeleeKillConvertsStart"), 4)

	if not Network:is_server() then
		return
	end

	self._units = {}

	self:post_hook(CopDamage, "die", function(copdamage, attack_data)
		if attack_data.variant ~= "melee" or not alive(attack_data.attacker_unit) or not managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
			return
		end

		local unit_name = copdamage._unit:name()
		local position = copdamage._unit:movement():m_pos()
		local rotation = copdamage._unit:movement():m_rot()
		DelayedCalls:Add(tostring(copdamage._unit:key()) .. "spawn", 0.25, function()
			self:spawn(unit_name, position, rotation, attack_data.attacker_unit)
		end)
	end)

	self:post_hook(GroupAIStateBase, "_determine_objective_for_criminal_AI", function(gstate, unit)
		local data = self._units[unit:key()]
		if data and alive(data.player_unit) and data.player_unit:movement():nav_tracker() then
			return ChaosModifierPlayerShields.get_follow_objective(self, data.player_unit)
		end
	end)
end

function ChaosModifierMeleeKillConverts:spawn(unit_name, pos, rot, player_unit)
	local unit = World:spawn_unit(unit_name, pos, rot)

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

	ChaosModifierPlayerShields.set_player_team(self, unit)

	unit:contour():add("generic_interactable_selected", true)

	local u_key = unit:key()
	local listener_key = self.class_name .. tostring(u_key)

	unit:character_damage():set_invulnerable(true)
	unit:network():send("set_unit_invulnerable", true, false)

	DelayedCalls:Add(tostring(u_key) .. "invulnerable", 5, function()
		if alive(unit) then
			unit:character_damage():set_invulnerable(false)
			unit:network():send("set_unit_invulnerable", false, false)
		end
	end)

	unit:character_damage():add_listener(listener_key, { "death" }, function()
		unit:contour():remove("generic_interactable_selected", true)
		self._units[u_key] = nil
	end)

	unit:base():add_destroy_listener(listener_key, function()
		self._units[u_key] = nil
	end)

	self._units[u_key] = {
		unit = unit,
		player_unit = player_unit
	}

	managers.groupai:state():on_criminal_jobless(unit)
end

return ChaosModifierMeleeKillConverts
