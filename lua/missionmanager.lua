Hooks:PreHook(MissionManager, "on_retry_job_stage", "on_retry_job_stage_chaos_mod", function()
	ChaosMod:stop_all_modifiers()
end)

Hooks:PreHook(MissionManager, "pre_destroy", "pre_destroy_chaos_mod", function()
	ChaosMod:stop_all_modifiers()
end)
