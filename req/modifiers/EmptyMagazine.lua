ChaosModifierEmptyMagazine = ChaosModifier.class("ChaosModifierEmptyMagazine")
ChaosModifierEmptyMagazine.conflict_tags = { "InfiniteAmmo" }

function ChaosModifierEmptyMagazine:start()
	local player = managers.player:local_player()
	if not alive(player) then
		return
	end

	local weapon = player:inventory():equipped_unit()
	if not alive(weapon) then
		return
	end

	local weapon_base = weapon:base()
	local mag_ammo = weapon_base:get_ammo_remaining_in_clip()
	weapon_base:set_ammo_remaining_in_clip(0)
	weapon_base:add_ammo_to_pool(mag_ammo, weapon_base:selection_index())
end

return ChaosModifierEmptyMagazine
