ChaosModifierCivilianMagnet = ChaosModifier.class("ChaosModifierCivilianMagnet")
ChaosModifierCivilianMagnet.duration = 30

function ChaosModifierCivilianMagnet:is_valid_civilian(unit)
	local char_tweak = unit:base():char_tweak()
	local damage = unit:character_damage()
	return char_tweak.intimidateable and not char_tweak.is_escort and not damage._invulnerable and not damage._immortal
end

function ChaosModifierCivilianMagnet:can_trigger()
	for _, data in pairs(managers.enemy:all_civilians()) do
		if self:is_valid_civilian(data.unit) then
			return true
		end
	end
end

function ChaosModifierCivilianMagnet:update(t, dt)
	local player_criminals = managers.groupai:state():all_player_criminals()
	for _, data in pairs(managers.enemy:all_civilians()) do
		local logic_data = data.unit:brain()._logic_data
		if logic_data.objective and logic_data.objective.chaos then
			if not alive(logic_data.objective.follow_unit) then
				logic_data.brain:set_objective(nil)
			end
		elseif self:is_valid_civilian(data.unit) and (not logic_data.path_fail_t or t - logic_data.path_fail_t < 2) then
			local player_key = table.random_key(managers.groupai:state():all_player_criminals())
			if player_key then
				if logic_data.name == "surrender" then
					logic_data.is_tied = nil
					data.unit:interaction():set_active(false, true)
				end
				logic_data.brain:set_objective({
					chaos = true,
					forced = true,
					type = "follow",
					haste = "run",
					stance = "hos",
					follow_unit = player_criminals[player_key].unit
				})
				logic_data.brain:set_update_enabled_state(true)
			end
		end
	end
end

function ChaosModifierCivilianMagnet:stop()
	for _, data in pairs(managers.enemy:all_civilians()) do
		local brain = data.unit:brain()
		local objective = brain:objective()
		if objective and objective.chaos then
			brain:set_objective(nil)
		end
	end
end

return ChaosModifierCivilianMagnet
