if HuskCopInventory.add_unit_by_factory_blueprint ~= HuskPlayerInventory.add_unit_by_factory_blueprint then
	return
end

function HuskCopInventory:add_unit_by_factory_blueprint(factory_name, equip, instant, blueprint, cosmetics)
	local factory_weapon = tweak_data.weapon.factory[factory_name]

	local ids_unit_name = Idstring(factory_weapon.unit)
	managers.dyn_resource:load(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)

	local new_unit = World:spawn_unit(ids_unit_name, Vector3(), Rotation())

	CopInventory._chk_spawn_shield(self, new_unit)

	new_unit:base():set_factory_data(factory_name)
	new_unit:base():set_cosmetics_data(cosmetics)
	new_unit:base():assemble_from_blueprint(factory_name, blueprint)
	new_unit:base():check_npc()

	local ignore_units = {
		self._unit,
		new_unit
	}

	if self._ignore_units then
		for _, ig_unit in pairs(self._ignore_units) do
			table.insert(ignore_units, ig_unit)
		end
	end

	local setup_data = {
		user_unit = self._unit,
		ignore_units = ignore_units,
		expend_ammo = false,
		hit_slotmask = managers.slot:get_mask("bullet_impact_targets"),
		hit_player = true,
		user_sound_variant = "1"
	}

	if Network:is_server() then
		setup_data.alert_AI = true
		setup_data.alert_filter = self._unit:brain():SO_access()
	end

	new_unit:base():setup(setup_data)

	if new_unit:base().AKIMBO then
		local first, second = self:_align_place(equip, new_unit, "left_hand")
		new_unit:base():create_second_gun(nil, second and second.obj3d_name or first.obj3d_name)
	end

	local weap_tweak = new_unit:base():weapon_tweak_data()
	if weap_tweak and weap_tweak.reload == "looped" then
		local hold = weap_tweak.usage == "is_shotgun_pump" and "shotgun" or weap_tweak.hold or "rifle"
		if not HuskPlayerMovement.reload_times[hold] then
			HuskPlayerMovement.reload_times[hold] = HuskPlayerMovement.reload_times.default
		end
	end

	self:add_unit(new_unit, equip, instant)
end
