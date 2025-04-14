Hooks:PostHook(MissionEndState, "at_enter", "at_enter_chaos_mod", function()
	ChaosMod:stop_all_modifiers()
end)
