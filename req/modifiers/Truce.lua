ChaosModifierTruce = ChaosModifier.class("ChaosModifierTruce")
ChaosModifierTruce.loud_only = true
ChaosModifierTruce.duration = 20

function ChaosModifierTruce:start()
	local react_func = function(data, attention_data)
		local reaction = AIAttentionObject.REACT_IDLE
		if attention_data.verified then
			if data.internal_data.advancing then
				reaction = AIAttentionObject.REACT_IDLE
			elseif attention_data.dis < 400 and attention_data.settings.relation == "foe" then
				reaction = AIAttentionObject.REACT_AIM
			elseif attention_data.dis < 8000 then
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

	local aim_allow_fire_original = CopLogicAttack.aim_allow_fire
	self:override(CopLogicAttack, "aim_allow_fire", function(shoot, ...)
		return aim_allow_fire_original(false, ...)
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
end

function ChaosModifierTruce:update(t, dt)
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

return ChaosModifierTruce
