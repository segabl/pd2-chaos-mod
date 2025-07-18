ChaosModifierWeaponTrade = ChaosModifier.class("ChaosModifierWeaponTrade")
ChaosModifierWeaponTrade.conflict_tags = { "NoGunsUsable" }
ChaosModifierWeaponTrade.duration = 60

function ChaosModifierWeaponTrade:can_trigger()
	return table.size(managers.groupai:state():all_player_criminals()) > 1
end

function ChaosModifierWeaponTrade:start()
	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local units = {}
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if alive(data.unit) then
			table.insert(units, data.unit)
		end
	end

	table.sort(units, function(a, b)
		return a:network():peer():id() > b:network():peer():id()
	end)

	local player_state = player_unit:movement():current_state()
	player_state:_check_stop_shooting()
	player_state:set_stance_switch_delay(0.5)
	if player_unit:movement():current_state_name() == "bipod" then
		player_state:_unmount_bipod()
		player_state = player_unit:movement():current_state()
	end

	for i, selection in pairs({ "primary", "secondary" }) do
		math.randomseed(self._seed * i)
		table.shuffle(units)

		local swap_index = (table.index_of(units, player_unit) % #units) + 1

		local outfit = units[swap_index]:network():peer():blackmarket_outfit()
		local weapon = outfit and outfit[selection]
		if weapon then
			player_unit:inventory():add_unit_by_factory_name(weapon.factory_id, false, false, weapon.blueprint, weapon.cosmetics)
		end
	end

	local speed_multiplier = player_state:_get_swap_speed_multiplier()
	player_unit:inventory():equipped_unit():base():tweak_data_anim_play("equip", speed_multiplier)
	player_unit:camera():play_redirect(player_state:get_animation("equip"), speed_multiplier)

	for index, weapon in pairs(player_unit:inventory():available_selections()) do
		managers.hud:set_ammo_amount(index, weapon.unit:base():ammo_info())
	end
end

function ChaosModifierWeaponTrade:stop()
	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local player_state = player_unit:movement():current_state()
	player_state:_check_stop_shooting()
	player_state:set_stance_switch_delay(0.5)
	if player_unit:movement():current_state_name() == "bipod" then
		player_state:_unmount_bipod()
		player_state = player_unit:movement():current_state()
	end

	local primary = managers.blackmarket:equipped_primary()
	if primary then
		local primary_slot = managers.blackmarket:equipped_weapon_slot("primaries")
		local texture_switches = managers.blackmarket:get_weapon_texture_switches("primaries", primary_slot, primary)
		player_unit:inventory():add_unit_by_factory_name(primary.factory_id, false, false, primary.blueprint, primary.cosmetics, texture_switches)
	end

	local secondary = managers.blackmarket:equipped_secondary()
	if secondary then
		local secondary_slot = managers.blackmarket:equipped_weapon_slot("secondaries")
		local texture_switches = managers.blackmarket:get_weapon_texture_switches("secondaries", secondary_slot, secondary)
		player_unit:inventory():add_unit_by_factory_name(secondary.factory_id, false, false, secondary.blueprint, secondary.cosmetics, texture_switches)
	end

	local speed_multiplier = player_state:_get_swap_speed_multiplier()
	player_unit:inventory():equipped_unit():base():tweak_data_anim_play("equip", speed_multiplier)
	player_unit:camera():play_redirect(player_state:get_animation("equip"), speed_multiplier)

	for index, weapon in pairs(player_unit:inventory():available_selections()) do
		managers.hud:set_ammo_amount(index, weapon.unit:base():ammo_info())
	end
end

return ChaosModifierWeaponTrade
