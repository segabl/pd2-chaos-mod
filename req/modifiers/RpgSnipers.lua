ChaosModifierRpgSnipers = ChaosModifier.class("ChaosModifierRpgSnipers")
ChaosModifierRpgSnipers.loud_only = true
ChaosModifierRpgSnipers.duration = 60

function ChaosModifierRpgSnipers:can_trigger()
	for _, data in pairs(managers.enemy:all_enemies()) do
		if alive(data.unit) and data.unit:base():has_tag("sniper") then
			return true
		end
	end
end

function ChaosModifierRpgSnipers:start()
	self:override(NPCRaycastWeaponBase, "_fire_raycast", function(weaponbase, user_unit, from_pos, direction, ...)
		if not alive(user_unit) or not user_unit:base().has_tag or not user_unit:base():has_tag("sniper") then
			return self:get_override(NPCRaycastWeaponBase, "_fire_raycast")(weaponbase, user_unit, from_pos, direction, ...)
		end

		if Network:is_server() then
			ProjectileBase.throw_projectile_npc("rocket_frag", from_pos, direction, user_unit)
		end

		return {}
	end)
end

return ChaosModifierRpgSnipers
