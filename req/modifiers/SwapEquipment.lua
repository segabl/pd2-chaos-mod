ChaosModifierSwapEquipment = ChaosModifier.class("ChaosModifierSwapEquipment")
ChaosModifierSwapEquipment.run_as_client = true

function ChaosModifierSwapEquipment:is_valid_equipment(unit)
	local interaction = unit:interaction()
	if not interaction or interaction._interact_object then
		return
	end
	local valid_interactions = {
		ammo_bag = true,
		bodybags_bag = true,
		doctor_bag = true,
		first_aid_kit = true,
		grenade_briefcase = true,
		grenade_crate = true
	}
	return valid_interactions[interaction.tweak_data]
end

function ChaosModifierSwapEquipment:can_trigger()
	local num = 0
	for _, unit in pairs(World:find_units_quick("all", World:make_slot_mask(14))) do
		if self:is_valid_equipment(unit) then
			num = num + 1
			if num > 1 then
				return true
			end
		end
	end
end

function ChaosModifierSwapEquipment:set_pos_rot(unit, pos, rot)
	unit:set_moving()
	unit:set_position(pos)
	unit:set_rotation(rot)
	unit:interaction():external_upd_interaction_topology()
	World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/explosion_flash_grenade"),
		position = pos,
		rotation = rot
	})
end

function ChaosModifierSwapEquipment:start()
	local units = {}
	for _, unit in pairs(World:find_units_quick("all", World:make_slot_mask(14))) do
		if self:is_valid_equipment(unit) then
			table.insert(units, unit)
		end
	end

	table.sort(units, function(a, b)
		return a:id() > b:id()
	end)

	math.randomseed(self._seed)
	table.shuffle(units)

	local first_pos = units[1]:position()
	local first_rot = units[1]:rotation()
	for i = 1, #units - 1 do
		self:set_pos_rot(units[i], units[i + 1]:position(), units[i + 1]:rotation())
	end
	self:set_pos_rot(units[#units], first_pos, first_rot)
end

return ChaosModifierSwapEquipment
