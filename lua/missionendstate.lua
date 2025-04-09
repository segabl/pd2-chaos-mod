Hooks:PostHook(MissionEndState, "at_enter", "at_enter_chaos_mod", function(self, state)
	ChaosMod:stop_all_modifiers()
	ChaosMod:panel():hide()
end)
