ChaosModifierForceMelee = ChaosModifier.class("ChaosModifierForceMelee")
ChaosModifierForceMelee.register_name = "ChaosModifierAttackRestriction"
ChaosModifierForceMelee.duration = 45

function ChaosModifierForceMelee:start()
	self._instant_melee = tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].instant

	self:post_hook(PlayerStandard, "_get_input", function(playerstate)
		local input = Hooks:GetReturn()
		if input.btn_interact_state and managers.interaction:active_unit() or input.btn_use_item_state or input.btn_use_item_release then
			playerstate._state_data.meleeing = nil
			playerstate._camera_unit:base():unspawn_melee_item()
		elseif self._instant_melee then
			input.btn_melee_press = input.btn_melee_press or input.btn_primary_attack_press
		else
			input.btn_melee_press = not playerstate._state_data.meleeing
			input.btn_meleet_state = true
			input.btn_melee_release = input.btn_melee_release or input.btn_primary_attack_press
		end
		input.btn_primary_attack_press = false
		input.btn_primary_attack_state = false
		input.btn_primary_attack_release = false
	end)

	for _, melee_weapon in pairs(tweak_data.blackmarket.melee_weapons) do
		self:override(melee_weapon, "melee_charge_shaker", "player_melee_charge_wing")
		self:override(melee_weapon.stats, "min_damage", melee_weapon.stats.min_damage * 10)
		self:override(melee_weapon.stats, "max_damage", melee_weapon.stats.max_damage * 10)
	end

	self:pre_hook(PlayerDamage, "damage_bullet", function(damage, attack_data)
		attack_data.damage = attack_data.damage * 0.25
	end)
end

function ChaosModifierForceMelee:stop()
	local player_unit = managers.player:local_player()
	if alive(player_unit) then
		player_unit:movement():current_state():_interupt_action_melee(TimerManager:game():time())
	end
end

return ChaosModifierForceMelee
