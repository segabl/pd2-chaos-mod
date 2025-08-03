Hooks:PostHook(PlayerStandard, "_get_unit_intimidation_action", "_get_unit_intimidation_action_chaos_mod", function()
	local voice_type, _, prime_target = Hooks:GetReturn()
	if voice_type == "come" and prime_target and managers.enemy:is_enemy(prime_target.unit) then
		return false
	end
end)
