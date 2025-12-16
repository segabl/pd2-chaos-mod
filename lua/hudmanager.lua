Hooks:PostHook(HUDManager, "update", "update_chaos_mod", function(self)
	local cam = managers.viewport:get_current_camera()
	if cam then
		self._sound_source:set_position(cam:position())
	end
end)
