ChaosModifierShowHitboxes = ChaosModifier.class("ChaosModifierShowHitboxes")
ChaosModifierShowHitboxes.run_as_client = true
ChaosModifierShowHitboxes.duration = 40

function ChaosModifierShowHitboxes:start()
	self._hitbox_mask = managers.slot:get_mask("world_geometry", "persons", "pickups", "vehicles") - managers.slot:get_mask("players_only_local")
	self._hitbox_pen = Draw:pen(Color(0, 1, 0))
end

function ChaosModifierShowHitboxes:update(t, dt)
	local cam = managers.viewport:get_current_camera()
	if not alive(cam) then
		return
	end
	for _, body in ipairs(World:find_bodies("intersect", "sphere", cam:position(), 1000, self._hitbox_mask)) do
		self._hitbox_pen:body(body)
	end
end

return ChaosModifierShowHitboxes
