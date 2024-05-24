ChaosModifierRandomTeleport = ChaosModifier.class("ChaosModifierRandomTeleport")
ChaosModifierRandomTeleport.run_as_client = true
ChaosModifierRandomTeleport.duration = 18
ChaosModifierRandomTeleport.interval = 3

function ChaosModifierRandomTeleport:set_position(pos)
	if pos and alive(self._player_unit) then
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
		if mvector3.distance_sq(nav_seg.pos, self._player_position) < 5000 ^ 2 then
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
	self:set_position(self._player_position)
end

return ChaosModifierRandomTeleport
