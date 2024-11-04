ChaosModifierAmmoLeak = ChaosModifier.class("ChaosModifierAmmoLeak")
ChaosModifierAmmoLeak.duration = 20

function ChaosModifierAmmoLeak:start()
	self:lose_ammo_primary()
	self:lose_ammo_secondary()
end

function ChaosModifierAmmoLeak:lose_ammo_primary()
	self:queue("lose_ammo_primary", self:lose_ammo(2))
end

function ChaosModifierAmmoLeak:lose_ammo_secondary()
	self:queue("lose_ammo_secondary", self:lose_ammo(1))
end

function ChaosModifierAmmoLeak:lose_ammo(selection_index)
	local player_unit = managers.player:local_player()
	local weapon_unit = player_unit and player_unit:inventory():unit_by_selection(selection_index)
	if not weapon_unit then
		return 0
	end

	local weapon_base = weapon_unit:base()
	local clip_max, clip_current, total_current, total_max = weapon_base:ammo_info()
	if total_current > clip_current then
		weapon_base:add_ammo_to_pool(-1, weapon_base:selection_index())
	end
	return (self.duration * 2) / (total_max - clip_max)
end

function ChaosModifierAmmoLeak:stop()
	self:unqueue("lose_ammo_primary")
	self:unqueue("lose_ammo_secondary")
end

return ChaosModifierAmmoLeak
