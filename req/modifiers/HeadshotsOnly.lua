---@class ChaosModifierHeadshotsOnly : ChaosModifier
ChaosModifierHeadshotsOnly = class(ChaosModifier)
ChaosModifierHeadshotsOnly.class_name = "ChaosModifierHeadshotsOnly"
ChaosModifierHeadshotsOnly.name = "Aim for the Head"
ChaosModifierHeadshotsOnly.duration = 60
ChaosModifierHeadshotsOnly.run_as_client = true

function ChaosModifierHeadshotsOnly:start()
	ChaosModifierHeadshotsOnly._damage_bullet = ChaosModifierHeadshotsOnly._damage_bullet or CopDamage.damage_bullet
	CopDamage.damage_bullet = function(copdamage, attack_data, ...)
		if not copdamage._head_body_name or attack_data.col_ray.body and attack_data.col_ray.body:name() == copdamage._ids_head_body_name then
			return ChaosModifierHeadshotsOnly._damage_bullet(copdamage, attack_data, ...)
		end
	end
end

function ChaosModifierHeadshotsOnly:stop()
	CopDamage.damage_bullet = ChaosModifierHeadshotsOnly._damage_bullet
end

return ChaosModifierHeadshotsOnly
