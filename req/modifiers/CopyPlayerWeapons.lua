ChaosModifierCopyPlayerWeapons = ChaosModifier.class("ChaosModifierCopyPlayerWeapons")
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
	self:override(CopMovement, "add_weapons", function(movement)
		if not movement._ext_base:default_weapon_name("primary") and not movement._ext_base:default_weapon_name("secondary") then
			return
		end

		local factory_id, blueprint, cosmetics = self:get_weapon()
		local inventory = movement._unit:inventory()

		HuskCopInventory.add_unit_by_factory_blueprint(inventory, factory_id, true, true, blueprint, cosmetics)

		local _fire_raycast = inventory:equipped_unit():base()._fire_raycast
		inventory:equipped_unit():base()._fire_raycast = function(weaponbase, user_unit, from_pos, direction, ...)
			local weapon_tweak = tweak_data.weapon[weaponbase._name_id:gsub("_crew$", "")]
			if not weapon_tweak or not weapon_tweak.projectile_type then
				return _fire_raycast(weaponbase, user_unit, from_pos, direction, ...)
			end
			ProjectileBase.throw_projectile_npc(weapon_tweak.projectile_type, from_pos, direction, user_unit)
			return {}
		end
	end)
end

return ChaosModifierCopyPlayerWeapons
