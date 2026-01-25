ChaosModifierTruce = ChaosModifier.class("ChaosModifierTruce")
ChaosModifierTruce.tags = { "NoGuns" }
ChaosModifierTruce.conflict_tags = { "NoGuns" }
ChaosModifierTruce.loud_only = true
ChaosModifierTruce.duration = 20

function ChaosModifierTruce:start()
	local react_func = function(data, attention_data)
		local reaction = AIAttentionObject.REACT_IDLE
		if attention_data.verified then
			if data.internal_data.advancing then
				reaction = AIAttentionObject.REACT_IDLE
			elseif attention_data.dis < 300 and attention_data.settings.relation == "foe" then
				reaction = AIAttentionObject.REACT_AIM
			elseif attention_data.dis < 4000 then
				reaction = AIAttentionObject.REACT_CHECK
			end
		end
		return math.min(attention_data.settings.reaction, reaction)
	end

	self:override(CopLogicArrest, "_chk_reaction_to_attention_object", react_func)
	self:override(CopLogicFlee, "_chk_reaction_to_attention_object", react_func)
	self:override(CopLogicIdle, "_chk_reaction_to_attention_object", react_func)
	self:override(CopLogicSniper, "_chk_reaction_to_attention_object", react_func)
	self:override(TeamAILogicBase, "_chk_reaction_to_attention_object", react_func)

	self:override(CopLogicAttack, "aim_allow_fire", function(shoot, ...)
		return self:get_override(CopLogicAttack, "aim_allow_fire")(false, ...)
	end)

	for _, data in pairs(tweak_data.group_ai.enemy_chatter) do
		self:override(data, "queue", "a06")
	end

	self:post_hook(PlayerStandard, "_get_input", function()
		local input = Hooks:GetReturn()
		if not managers.interaction:active_unit() then
			input.btn_interact_press = false
			input.btn_interact_release = false
			input.btn_interact_state = false
		end
		input.btn_melee_press = false
		input.btn_melee_release = false
		input.btn_meleet_state = false
		input.btn_throw_grenade_press = false
		input.btn_projectile_press = false
		input.btn_projectile_release = false
		input.btn_projectile_state = false
		input.btn_primary_attack_press = false
		input.btn_primary_attack_state = false
		input.btn_primary_attack_release = false
	end)

	self:override(GroupAIStateBesiege, "_chk_group_use_flash_grenade", function() end)
	self:override(GroupAIStateBesiege, "_chk_group_use_smoke_grenade", function() end)
	self:override(GroupAIStateBesiege, "_chk_group_use_grenade", function() end)

	self:override(SentryGunBrain, "_select_focus_attention", function(brain)
		if brain._attention_obj then
			brain._ext_movement:set_attention()
			brain._attention_obj = nil
		end
	end)

	SoundDevice:set_rtpc("option_music_volume", managers.user:get_setting("music_volume"))
end

function ChaosModifierTruce:update(t, dt)
	local vol = 0
	local time_elapsed, time_left = self:time_elapsed(t), self:time_left(t)
	if time_elapsed < 0.5 then
		vol = math.map_range(time_elapsed, 0, 0.5, managers.user:get_setting("music_volume"), 0)
	elseif time_left < 0.5 then
		vol = math.map_range(time_left, 0.5, 0, 0, managers.user:get_setting("music_volume"))
	end
	SoundDevice:set_rtpc("option_music_volume", vol)
	XAudio._base_gains.music = vol / 100

	if self._next_t and self._next_t > t then
		return
	end

	local enemies = {}
	for _, data in pairs(managers.enemy:all_enemies()) do
		if alive(data.unit) and not data.unit:sound():speaking(t) then
			table.insert(enemies, data.unit)
		end
	end

	local enemy = table.random(enemies)
	if enemy then
		enemy:sound():say("a06")
		self._next_t = t + 1 / math.ceil(#enemies * 0.1)
	end
end

function ChaosModifierTruce:stop()
	local vol = managers.user:get_setting("music_volume")
	SoundDevice:set_rtpc("option_music_volume", vol)
	XAudio._base_gains.music = vol / 100
end

return ChaosModifierTruce
