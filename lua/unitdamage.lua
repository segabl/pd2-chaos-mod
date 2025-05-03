Hooks:PreHook(UnitDamage, "run_sequence_simple", "run_sequence_simple_chaos_mod", function(self, sequence_name)
	if sequence_name == "turn_on_spook_lights" and not self._unit:get_object(Idstring("point_light")) and not alive(self._spooc_light) then
		self._spooc_light = World:create_light("omni")
		self._spooc_light:set_far_range(40)
		self._spooc_light:set_multiplier(20)
		self._spooc_light:set_color(Color.green)
		self._spooc_light:link(self._unit:get_object(Idstring("Head")))
		self._spooc_light:set_local_position(Vector3(0, 25, 25))
	elseif sequence_name == "kill_spook_lights" and alive(self._spooc_light) then
		World:delete_light(self._spooc_light)
	end
end)
