ChaosModifierBostonBasher = ChaosModifier.class("ChaosModifierBostonBasher")
ChaosModifierBostonBasher.duration = 30

function ChaosModifierBostonBasher:start()
	self:post_hook(RaycastWeaponBase, "fire", function(weaponbase, from_pos, direction, dmg_mul)
		if weaponbase._setup.user_unit ~= managers.player:player_unit() then
			return
		end

		local ray_res = Hooks:GetReturn()
		local missed = true
		for _, ray in pairs(ray_res and ray_res.rays or {}) do
			if alive(ray.unit) and ray.unit:character_damage() then
				missed = false
				break
			end
		end

		if missed then
			local damage = weaponbase:_get_current_damage(dmg_mul)
			local scaled_damage = math.min(damage, 1 + math.sqrt(damage))
			weaponbase._setup.user_unit:character_damage():delay_damage(scaled_damage, 4)
		end
	end)
end

return ChaosModifierBostonBasher
