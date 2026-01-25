ChaosModifierShortFuse = ChaosModifier.class("ChaosModifierShortFuse")
ChaosModifierShortFuse.tags = { "ProjectileFuse" }
ChaosModifierShortFuse.conflict_tags = { "ProjectileFuse" }
ChaosModifierShortFuse.duration = 60

function ChaosModifierShortFuse:start()
	self:post_hook(ProjectileBase, "update", function(base, unit, t)
		if base._detonated then
			return
		elseif not base._chaos_explode_t then
			local tweak_entry = tweak_data.projectiles[base._tweak_projectile_entry]
			base._chaos_explode_t = t + math.min(0.2, 200 / (tweak_entry and tweak_entry.launch_speed or 500))
		elseif base._chaos_explode_t < t then
			if type(base._detonate) == "function" then
				base:_detonate()
			end
			base._detonated = true
		end
	end)
end

return ChaosModifierShortFuse
