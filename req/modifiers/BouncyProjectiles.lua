ChaosModifierBouncyProjectiles = ChaosModifier.class("ChaosModifierBouncyProjectiles")
ChaosModifierBouncyProjectiles.conflict_tags = { "ProjectileFuse" }
ChaosModifierBouncyProjectiles.duration = 60

function ChaosModifierBouncyProjectiles:has_grenade_launcher(peer)
	local outfit = peer:blackmarket_outfit()
	local primary_id = outfit and outfit.primary and managers.weapon_factory:get_weapon_id_by_factory_id(outfit.primary.factory_id)
	if tweak_data.weapon[primary_id] and table.contains(tweak_data.weapon[primary_id].categories, "grenade_launcher") then
		return true
	end
	local secondary_id = outfit and outfit.secondary and managers.weapon_factory:get_weapon_id_by_factory_id(outfit.secondary.factory_id)
	if tweak_data.weapon[secondary_id] and table.contains(tweak_data.weapon[secondary_id].categories, "grenade_launcher") then
		return true
	end
end

function ChaosModifierBouncyProjectiles:can_trigger()
	if self:has_grenade_launcher(managers.network:session():local_peer()) then
		return true
	end
	for _, peer in pairs(managers.network:session():peers()) do
		if self:has_grenade_launcher(peer) then
			return true
		end
	end
end

function ChaosModifierBouncyProjectiles:start()
	local function impact(base)
		base._chaos_impacted = true
	end
	self:override(FragGrenade, "clbk_impact", impact)
	self:override(FragGrenade, "_on_collision", impact)
	self:post_hook(ProjectileBase, "update", function(base, unit, t)
		if base._detonated or not base._chaos_impacted then
			return
		elseif not base._chaos_explode_t then
			base._chaos_explode_t = t + 2
		elseif base._chaos_explode_t < t then
			if type(base._detonate) == "function" then
				base:_detonate()
			end
			base._detonated = true
		end
	end)
end

return ChaosModifierBouncyProjectiles
