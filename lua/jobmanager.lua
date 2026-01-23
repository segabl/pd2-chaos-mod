Hooks:PostHook(JobManager, "deactivate_current_job", "deactivate_current_job_chaos_mod", function()
	ChaosMod:stop_all_modifiers()
end)
