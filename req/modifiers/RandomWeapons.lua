ChaosModifierRandomWeapons = ChaosModifier.class("ChaosModifierRandomWeapons")
ChaosModifierRandomWeapons.tags = { "WeaponChange" }
ChaosModifierRandomWeapons.conflict_tags = { "NoGuns", "WeaponChange" }
ChaosModifierRandomWeapons.duration = 60

function ChaosModifierRandomWeapons:start()
	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local player_inventory = player_unit:inventory()

	local primaries = {}
	local secondaries = {}
	for weap_id, data in pairs(tweak_data.weapon) do
		if data.autohit ~= nil and Global.blackmarket_manager.weapons[weap_id] and Global.blackmarket_manager.weapons[weap_id].unlocked then
			local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weap_id)
			local selection_index = data.use_data.selection_index
			if factory_id and (selection_index == 1 or selection_index == 2) then
				table.insert(selection_index == 1 and secondaries or primaries, {
					weapon_id = weap_id,
					factory_id = factory_id
				})
			end
		end
	end

	local weapons_to_add = { table.random(primaries), table.random(secondaries) }
	for _, data in pairs(weapons_to_add) do
		local blueprint = clone(tweak_data.weapon.factory[data.factory_id].default_blueprint)
		for _, parts in pairs(managers.blackmarket:get_dropable_mods_by_weapon_id(data.weapon_id)) do
			if math.random() < 0.5 then
				local filtered_parts = table.filter_list(parts, function(part)
					local part_id = part[1]
					local part_data = tweak_data.weapon.factory.parts[part_id]
					local forbidden = managers.weapon_factory:_get_forbidden_parts(data.factory_id, blueprint)
					return not part_data.unatainable and not forbidden[part_id]
				end)
				local part = table.random(filtered_parts)
				if part then
					managers.weapon_factory:change_part_blueprint_only(data.factory_id, part[1], blueprint)
				end
			end
		end

		player_inventory:add_unit_by_factory_name(data.factory_id, false, false, blueprint)
	end

	local player_state = player_unit:movement():current_state()
	local speed_multiplier = player_state:_get_swap_speed_multiplier()
	player_inventory:equipped_unit():base():tweak_data_anim_play("equip", speed_multiplier)
	player_unit:camera():play_redirect(player_state:get_animation("equip"), speed_multiplier)

	for index, weapon in pairs(player_inventory:available_selections()) do
		managers.hud:set_ammo_amount(index, weapon.unit:base():ammo_info())
	end
end

function ChaosModifierRandomWeapons:stop()
	ChaosModifierWeaponTrade.stop(self)
end

return ChaosModifierRandomWeapons
