Hooks:PostHook(CopMovement, "set_team", "set_team_chaos_mod", function(self)
	if self._team and self._team.id == "criminal1" and self._ext_damage.set_mover_collision_state then
		self._ext_damage:set_mover_collision_state(false)
	end
end)