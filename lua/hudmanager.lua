Hooks:PostHook(HUDManager, "update", "update_chaos_mod", function(self)
	self._sound_source:set_position(managers.viewport:get_current_camera_position())
end)
