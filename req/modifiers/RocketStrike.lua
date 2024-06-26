ChaosModifierRocketStrike = ChaosModifier.class("ChaosModifierRocketStrike")
ChaosModifierRocketStrike.run_as_client = false
ChaosModifierRocketStrike.run_in_stealth = false
ChaosModifierRocketStrike.duration = 45

function ChaosModifierRocketStrike:can_trigger()
	local check_pos = Vector3()
	local slot_mask = managers.slot:get_mask("bullet_blank_impact_targets")
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		mvector3.set(check_pos, data.m_det_pos)
		mvector3.add_scaled(check_pos, math.UP, 5000)
		if not World:raycast("ray", data.m_det_pos, check_pos, "slot_mask", slot_mask, "report") then
			return true
		end
	end
end

function ChaosModifierRocketStrike:start()
	self:pre_hook(TeamAIDamage, "damage_explosion", function(teamaidamage, attack_data)
		if attack_data.damage then
			attack_data.damage = math.min(attack_data.damage, 200)
		end
	end)
end

function ChaosModifierRocketStrike:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + math.rand(0.75, 1)

	local radius = 2000
	local positions = {}
	local check_pos = Vector3()
	local slot_mask = managers.slot:get_mask("bullet_blank_impact_targets")
	local check_tracker = managers.navigation:create_nav_tracker(check_pos)
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		for _ = 1, 20 do
			mvector3.set(check_pos, math.UP)
			mvector3.random_orthogonal(check_pos)
			mvector3.multiply(check_pos, math.random(200, radius))
			mvector3.add(check_pos, data.m_det_pos)
			check_tracker:move(check_pos)
			local field_pos = check_tracker:field_position()
			mvector3.set(check_pos, field_pos)
			mvector3.set_z(check_pos, check_pos.z + 5000)
			if not World:raycast("ray", field_pos, check_pos, "slot_mask", slot_mask, "report") then
				table.insert(positions, mvector3.copy(check_pos))
				break
			end
		end
	end
	managers.navigation:destroy_nav_tracker(check_tracker)

	local pos = table.random(positions)
	if not pos then
		return
	end

	ProjectileBase.throw_projectile_npc("rocket_frag", pos, math.DOWN)
end

return ChaosModifierRocketStrike
