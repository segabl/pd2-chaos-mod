ChaosModifierHeadshotsOnly = ChaosModifier.class("ChaosModifierHeadshotsOnly")
ChaosModifierHeadshotsOnly.duration = 60

function ChaosModifierHeadshotsOnly:start()
	self:override(CopDamage, "damage_bullet", function(copdamage, attack_data, ...)
		if not copdamage._head_body_name or attack_data.col_ray.body and attack_data.col_ray.body:name() == copdamage._ids_head_body_name then
			return self:get_override(CopDamage, "damage_bullet")(copdamage, attack_data, ...)
		end
	end)
end

return ChaosModifierHeadshotsOnly
