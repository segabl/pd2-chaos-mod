Hooks:PostHook(HUDManager, "update", "update_chaos_mod", function(self)
	local cam = managers.viewport:get_current_camera()
	if cam then
		self._sound_source:set_position(cam:position())
	end
end)

Hooks:PreHook(HUDManager, "teammate_progress", "teammate_progress_chaos_mod", function(self, peer_id, type_index, enabled, tweak_data_id)
	if type_index == 1 and not tweak_data.interaction[tweak_data_id] and tweak_data_id then
		tweak_data.interaction[tweak_data_id] = {}
	end
end)
