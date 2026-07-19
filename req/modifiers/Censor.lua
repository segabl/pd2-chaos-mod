ChaosModifierCensor = ChaosModifier.class("ChaosModifierCensor")
ChaosModifierCensor.duration = 60

function ChaosModifierCensor:start()
	self._panel = ChaosMod:panel():panel({
		layer = 100
	})

	self._blocked_effects = {
		[Idstring("effects/payday2/particles/impacts/blood/blood_impact_a"):key()] = true
	}

	self._active_effects = {}

	self:post_hook(getmetatable(World:effect_manager()), "spawn", callback(self, self, "add_bitmap"))
end

function ChaosModifierCensor:add_bitmap(_, params)
	local pos = params.position
	if not pos then
		return
	end

	if not self._blocked_effects[params.effect:key()] then
		return
	end

	local cam = managers.viewport:get_current_camera()
	if not alive(cam) then
		return
	end

	if World:raycast("ray", pos, cam:position(), "slot_mask", managers.slot:get_mask("AI_visibility"), "report") then
		return
	end

	for _, other_pos in pairs(self._active_effects) do
		if mvector3.distance_sq(pos, other_pos) < 100 ^ 2 then
			return
		end
	end

	local bitmap = self._panel:bitmap({
		texture = "guis/textures/esrb_rating",
		layer = -math.floor(mvector3.distance(pos, cam:position()) / 100),
		visible = false
	})
	local key = bitmap:key()
	self._active_effects[key] = pos
	bitmap:animate(function(o)
		local w, h = o:size()
		over(1, function(p)
			if not alive(cam) then
				return
			end
			local screen_pos = ChaosMod:ws():world_to_screen(cam, pos)
			local scale = math.clamp(w / math.max(1, screen_pos.z) / 20, 0.1, 1)
			o:set_size(w * scale, h * scale)
			o:set_center(screen_pos.x, screen_pos.y)
			o:set_visible(screen_pos.z > 0)
			o:set_alpha(math.map_range_clamped(p, 0.9, 1, 1, 0))
		end)
		self._active_effects[key] = nil
		o:parent():remove(o)
	end)
end

function ChaosModifierCensor:stop()
	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end
end

return ChaosModifierCensor
