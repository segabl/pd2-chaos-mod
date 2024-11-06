ChaosModifierRandomTeleport = ChaosModifier.class("ChaosModifierRandomTeleport")
ChaosModifierRandomTeleport.register_name = "ChaosModifierTeleport"
ChaosModifierRandomTeleport.stealth_safe = false
ChaosModifierRandomTeleport.duration = 18
ChaosModifierRandomTeleport.interval = 3

function ChaosModifierRandomTeleport:set_position(pos, force)
	if pos and alive(self._player_unit) and (force or not self._player_unit:movement():on_zipline()) then
		self._player_unit:warp_to(self._player_unit:rotation(), pos)
	end
end

function ChaosModifierRandomTeleport:start()
	self._player_unit = managers.player:local_player()
	if not alive(self._player_unit) then
		return
	end

	self._player_position = mvector3.copy(self._player_unit:movement():m_pos())
	self._player_nav_seg = self._player_unit:movement():nav_tracker():nav_segment()

	self:pre_hook(PlayerDamage, "damage_fall", function(playerdamage, data)
		data.height = 0
	end)
end

function ChaosModifierRandomTeleport:update(t, dt)
	if not alive(self._player_unit) then
		return
	end

	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + self.interval

	local positions = {}
	for nav_seg_id, nav_seg in pairs(managers.navigation._nav_segments) do
		if mvector3.distance_sq(nav_seg.pos, self._player_position) < 6000 ^ 2 then
			local search_params = {
				id = "ChaosModifierRandomTeleport",
				from_seg = nav_seg_id,
				to_seg = self._player_nav_seg
			}
			if managers.navigation:search_coarse(search_params) then
				table.insert(positions, managers.navigation:find_random_position_in_segment(nav_seg_id))
			end
		end
	end

	self:set_position(table.random(positions))
end

function ChaosModifierRandomTeleport:stop()
	self:set_position(self._player_position, true)
end

return ChaosModifierRandomTeleport
