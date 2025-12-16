ChaosModifierHeadshotsOnly = ChaosModifier.class("ChaosModifierHeadshotsOnly")
ChaosModifierHeadshotsOnly.duration = 60

function ChaosModifierHeadshotsOnly:start()
	self:override(CopDamage, "damage_bullet", function(copdamage, attack_data, ...)
		if not copdamage._head_body_name or attack_data.col_ray.body and attack_data.col_ray.body:name() == copdamage._ids_head_body_name then
			return self:get_override(CopDamage, "damage_bullet")(copdamage, attack_data, ...)
		elseif attack_data.col_ray.position and attack_data.col_ray.ray then
			World:effect_manager():spawn({
				effect = Idstring("effects/payday2/particles/impacts/heavy_swat_steel_impact_pd2"),
				position = attack_data.col_ray.position,
				normal = -attack_data.col_ray.ray
			})
			return "friendly_fire"
		end
	end)
end

return ChaosModifierHeadshotsOnly
