ChaosModifierAutoAim = ChaosModifier.class("ChaosModifierAutoAim")
ChaosModifierAutoAim.duration = 30

function ChaosModifierAutoAim:start()
	self:pre_hook(NewRaycastWeaponBase, "_fire_raycast", function(_, user_unit, from_pos, direction)
		if user_unit == managers.player:local_player() and alive(self._autoaim_enemy) then
			local movement = self._autoaim_enemy:movement()
			mvector3.lerp(direction, movement._obj_spine:position(), movement._obj_head:position(), math.rand(0.75, 1))
			mvector3.direction(direction, from_pos, direction)
		end
	end)

	self:pre_hook(ShotgunBase, "_fire_raycast", function(_, user_unit, from_pos, direction)
		if user_unit == managers.player:local_player() and alive(self._autoaim_enemy) then
			local movement = self._autoaim_enemy:movement()
			mvector3.lerp(direction, movement._obj_spine:position(), movement._obj_head:position(), math.rand(0.75, 1))
			mvector3.direction(direction, from_pos, direction)
		end
	end)
end

function ChaosModifierAutoAim:update(t, dt)
	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local cam = player_unit:camera()
	local from_pos = cam:position()
	local view_enemies = World:find_units("camera_cone", cam:camera_object(), Vector3(), 1.5, 5000, managers.slot:get_mask("enemies"))
	local block_slot_mask = managers.slot:get_mask("bullet_blank_impact_targets")

	local enemies = {}
	for _, enemy in pairs(view_enemies) do
		local to_pos = enemy:movement()._obj_head and enemy:movement()._obj_head:position()
		if to_pos and not World:raycast("ray", from_pos, to_pos, "slot_mask", block_slot_mask, "report") then
			enemies[enemy:key()] = enemy
		end
	end

	if not alive(self._autoaim_enemy) or not enemies[self._autoaim_enemy:key()] or self._autoaim_enemy:character_damage():dead() or self._next_t and self._next_t < t then
		if alive(self._autoaim_enemy) then
			self._autoaim_enemy:contour():remove("vulnerable_character")
			if table.size(enemies) > 1 then
				enemies[self._autoaim_enemy:key()] = nil
			end
		end
		self._autoaim_enemy = enemies[table.random_key(enemies)]
		self._next_t = t + math.rand(0.75, 1.5)
		if alive(self._autoaim_enemy)then
			self._autoaim_enemy:contour():add("vulnerable_character", false, 1, Color(1, 0.35, 0))
		end
	end
end

function ChaosModifierAutoAim:stop()
	if alive(self._autoaim_enemy)then
		self._autoaim_enemy:contour():remove("vulnerable_character")
	end
end

return ChaosModifierAutoAim
