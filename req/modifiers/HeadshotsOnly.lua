ChaosModifierHeadshotsOnly = ChaosModifier.class("ChaosModifierHeadshotsOnly")
ChaosModifierHeadshotsOnly.duration = 60

function ChaosModifierHeadshotsOnly:start()
	local damage_bullet_original = CopDamage.damage_bullet
	self:override(CopDamage, "damage_bullet", function(copdamage, attack_data, ...)
		if not copdamage._head_body_name or attack_data.col_ray.body and attack_data.col_ray.body:name() == copdamage._ids_head_body_name then
			return damage_bullet_original(copdamage, attack_data, ...)
		end
	end)
end

return ChaosModifierHeadshotsOnly
