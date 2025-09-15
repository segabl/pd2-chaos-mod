ChaosModifierCopyPlayerWeapons = ChaosModifier.class("ChaosModifierCopyPlayerWeapons")
ChaosModifierCopyPlayerWeapons.conflict_tags = { "EnemyWeapons" }
ChaosModifierCopyPlayerWeapons.run_as_client = false
ChaosModifierCopyPlayerWeapons.loud_only = true
ChaosModifierCopyPlayerWeapons.color = "enemy_change"
ChaosModifierCopyPlayerWeapons.duration = 60

function ChaosModifierCopyPlayerWeapons:get_weapon()
	local available_weapons = {}
	for _, v in pairs(managers.groupai:state():all_char_criminals()) do
		if alive(v.unit) then
			local weapon = v.unit:inventory():equipped_unit()
			local factory_id = alive(weapon) and weapon:base()._factory_id
			if factory_id and not factory_id:match("_npc$") then
				factory_id = factory_id .. "_npc"
			end
			if tweak_data.weapon.factory[factory_id] and tweak_data.weapon.factory[factory_id].unit then
				if not weapon:base():is_category("bow", "crossbow", "saw") then
					table.insert(available_weapons, {
						factory_id = factory_id,
						blueprint = weapon:base()._blueprint,
						cosmetics = weapon:base()._cosmetics
					})
				end
			end
		end
	end

	local weapon = table.random(available_weapons)
	local factory_id = weapon and weapon.factory_id or "wpn_fps_ass_amcar_npc"
	local blueprint = weapon and weapon.blueprint or tweak_data.weapon.factory[factory_id].default_blueprint
	local cosmetics = weapon and weapon.cosmetics or nil

	return factory_id, blueprint, cosmetics
end

function ChaosModifierCopyPlayerWeapons:start()
	local adjust_z_tbl = {
		gre_m79 = true,
		m32 = true,
		china = true,
		ms3gl = true,
		slap = true
	}

	local function add_weapon(inventory, factory_id, blueprint, cosmetics)
		HuskCopInventory.add_unit_by_factory_blueprint(inventory, factory_id, true, true, blueprint, cosmetics)

		local stats = managers.weapon_factory:get_stats(factory_id, blueprint)
		local weapon_base = inventory:equipped_unit():base()
		weapon_base:set_ammo_max_per_clip(weapon_base:get_ammo_max_per_clip() + (stats.extra_ammo or 0))
		weapon_base:set_ammo_remaining_in_clip(weapon_base:get_ammo_max_per_clip())

		local name_id = weapon_base._name_id:gsub("_crew$", "")
		local weapon_tweak = tweak_data.weapon[name_id]
		if not weapon_tweak then
			return
		end

		local projectile_type = weapon_tweak.projectile_type or weapon_tweak.projectile_types and next(weapon_tweak.projectile_types)
		if weapon_base._ammo_data and weapon_base._ammo_data.launcher_grenade then
			if weapon_tweak.projectile_types then
				projectile_type = weapon_tweak.projectile_types[weapon_base._ammo_data.launcher_grenade] or weapon_base._ammo_data.launcher_grenade
			else
				projectile_type = weapon_base._ammo_data.launcher_grenade
			end
		end

		local projectile_tweak = tweak_data.projectiles[projectile_type]
		if not projectile_tweak then
			return
		end

		local adjust_z = adjust_z_tbl[name_id] or adjust_z_tbl[weapon_tweak.based_on]

		weapon_base._spawn_trail_effect = function() end
		weapon_base._fire_raycast = function(_, user_unit, from_pos, direction, _, _, _, _, _, target_unit)
			if alive(target_unit) then
				direction = target_unit:position()
				local dis = mvector3.distance(from_pos, direction)
				local compensation = adjust_z and ((dis / 10) ^ 2) / ((projectile_tweak.launch_speed or 250) / 10) or 0
				mvector3.set_z(direction, direction.z + compensation + 25)
				mvector3.direction(direction, from_pos, direction)
			end
			ProjectileBase.throw_projectile_npc(projectile_type, from_pos, direction, user_unit)
			return {}
		end
	end

	self:override(CopMovement, "add_weapons", function(movement)
		if not movement._ext_base:default_weapon_name("primary") and not movement._ext_base:default_weapon_name("secondary") then
			return
		end

		local factory_id, blueprint, cosmetics = self:get_weapon()

		add_weapon(movement._ext_inventory, factory_id, blueprint, cosmetics)

		local convert_to_criminal = movement._ext_brain.convert_to_criminal
		movement._ext_brain.convert_to_criminal = function(brain, ...)
			convert_to_criminal(brain, ...)
			add_weapon(brain._unit:inventory(), factory_id, blueprint, cosmetics)
		end
	end)
end

return ChaosModifierCopyPlayerWeapons
