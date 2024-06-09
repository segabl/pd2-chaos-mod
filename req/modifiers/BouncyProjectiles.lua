ChaosModifierBouncyProjectiles = ChaosModifier.class("ChaosModifierBouncyProjectiles")
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
	self:override(FragGrenade, "clbk_impact", function()end)
	self:override(FragGrenade, "_on_collision", function()end)
end

return ChaosModifierBouncyProjectiles
