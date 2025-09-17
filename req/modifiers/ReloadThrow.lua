ChaosModifierReloadThrow = ChaosModifier.class("ChaosModifierReloadThrow")
ChaosModifierReloadThrow.conflict_tags = { "NoGunsUsable", "InfiniteAmmo" }
ChaosModifierReloadThrow.duration = 60

function ChaosModifierReloadThrow:start()
	local grenade_damage = 200
	local is_reload_throw = false

	local unit_ids = Idstring("unit")
	local dyn_resources_package = managers.dyn_resource.DYN_RESOURCES_PACKAGE
	local tweak_entry = tweak_data.blackmarket.projectiles.sticky_grenade
	if not PackageManager:has(unit_ids, Idstring(tweak_entry.local_unit)) then
		managers.dyn_resource:load(unit_ids, Idstring(tweak_entry.local_unit), dyn_resources_package)
	end

	if not PackageManager:has(unit_ids, Idstring(tweak_entry.sprint_unit)) then
		managers.dyn_resource:load(unit_ids, Idstring(tweak_entry.sprint_unit), dyn_resources_package)
	end

	self:post_hook(PlayerStandard, "_is_reloading", function()
		return is_reload_throw or Hooks:GetReturn()
	end)

	self:override(PlayerStandard, "_start_action_reload_enter", function(playerstate, t, ...)
		local weapon_base = alive(playerstate._equipped_unit) and playerstate._equipped_unit:base()
		if is_reload_throw or not weapon_base or not weapon_base:can_reload() then
			return
		end

		is_reload_throw = true

		if playerstate._projectile_global_value then
			playerstate._camera_unit:anim_state_machine():set_global(playerstate._projectile_global_value, 0)
		end
		playerstate._projectile_global_value = "projectile_target"
		playerstate._camera_unit:anim_state_machine():set_global(playerstate._projectile_global_value, 1)
		playerstate._ext_camera:play_redirect(Idstring("throw_projectile"))

		managers.network:session():send_to_peers_synched("play_distance_interact_redirect", playerstate._unit, "throw_grenade")

		local ammo_base = weapon_base:ammo_base()
		ammo_usage = ammo_base:get_ammo_remaining_in_clip()
		grenade_damage = math.map_range(ammo_usage / ammo_base:get_ammo_max_per_clip(), 0, 1, 50, 200)
		ammo_base:set_ammo_remaining_in_clip(0)
		weapon_base:use_ammo(ammo_base, ammo_usage)
		managers.hud:set_ammo_amount(weapon_base:selection_index(), weapon_base:ammo_info())

		DelayedCalls:Add(self.class_name, 1, function()
			is_reload_throw = false
			if not alive(weapon_base._unit) then
				return
			end
			weapon_base:on_reload()
			managers.hud:set_ammo_amount(weapon_base:selection_index(), weapon_base:ammo_info())
		end)
	end)

	self:override(PlayerEquipment, "throw_projectile", function(equipment, ...)
		if not is_reload_throw then
			return self:get_override(PlayerEquipment, "throw_projectile")(equipment, ...)
		end

		local from = equipment._unit:movement():m_head_pos()
		local pos = from + equipment._unit:movement():m_head_rot():y() * 30 + Vector3(0, 0, 0)
		local dir = equipment._unit:movement():m_head_rot():y()

		local grenade_unit = World:spawn_unit(Idstring(tweak_entry.local_unit), pos, Rotation(dir, math.UP))
		local grenade_base = grenade_unit:base()
		grenade_unit:set_visible(false)

		local peer_id = managers.network:session():local_peer():id()
		grenade_base._damage = grenade_damage
		grenade_base._player_damage = grenade_damage * 0.2
		grenade_base._range = 300
		grenade_base._curve_pow = 0.5
		grenade_base:set_thrower_unit_by_peer_id(peer_id)
		grenade_base:set_owner_peer_id(peer_id)
		grenade_unit:damage():add_body_collision_callback(callback(grenade_base, grenade_base, "clbk_impact"))
		grenade_base:create_sweep_data()
		grenade_base._attach_to_hit_unit = function()
			local pos = grenade_base._col_ray.position - grenade_base._col_ray.velocity * 0.01 + math.UP * 5
			local network_damage = math.min(16384, math.ceil(grenade_base._damage * 163.84))
			grenade_base:_set_body_enabled(false)
			grenade_unit:set_position(pos)
			grenade_unit:set_position(pos)
			grenade_base:_detonate()
			managers.network:session():send_to_peers_synched("sync_explode_bullet", pos, math.UP, network_damage, peer_id)
		end
		grenade_base:throw({
			dir = dir * 0.5,
			projectile_entry = "sticky_grenade"
		})

		local player_unit = managers.player:local_player()
		local weapon_unit = alive(player_unit) and player_unit:inventory():equipped_unit()
		local weapon_base = alive(weapon_unit) and weapon_unit:base()
		if not weapon_base then
			return
		end

		local factory_weapon = tweak_data.weapon.factory[weapon_base._factory_id .. "_npc"]
		if not factory_weapon then
			return
		end

		player_unit:inventory():hide_equipped_unit()

		local weapon_ids = Idstring(factory_weapon.unit)
		if not managers.dyn_resource:has_resource(unit_ids, weapon_ids, dyn_resources_package) then
			managers.dyn_resource:load(unit_ids, weapon_ids, dyn_resources_package)
		end

		local weapon_unit = World:spawn_unit(weapon_ids, grenade_unit:position(), grenade_unit:rotation())
		weapon_unit:base():set_factory_data(weapon_base._factory_id)
		weapon_unit:base():set_cosmetics_data(weapon_base._cosmetics)
		weapon_unit:base():set_texture_switches(weapon_base._texture_switches)
		weapon_unit:base():assemble_from_blueprint(weapon_base._factory_id, weapon_base._blueprint)
		weapon_unit:base():check_npc()

		call_on_next_update(function()
			if alive(weapon_unit) then
				weapon_unit:set_enabled(true)
				weapon_unit:base():on_enabled()
			end
		end)

		grenade_unit:link(grenade_unit:orientation_object():name(), weapon_unit)
		grenade_base:add_destroy_listener("destroy_weapon_unit", function()
			if alive(weapon_unit) then
				weapon_unit:set_slot(0)
			end
		end)
	end)

	self:override(FPCameraPlayerBase, "spawn_grenade", function(...)
		if not is_reload_throw then
			return self:get_override(FPCameraPlayerBase, "spawn_grenade")(...)
		end
	end)
end

return ChaosModifierReloadThrow
