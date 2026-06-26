Hooks:PostHook(_G, "pd2_version", "pd2_version_chaos", function()
	return Hooks:GetReturn() .. "_chaos_v" .. ChaosMod.mod_instance:GetVersion()
end)
