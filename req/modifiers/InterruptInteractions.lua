ChaosModifierInterruptInteractions = ChaosModifier.class("ChaosModifierInterruptInteractions")
ChaosModifierInterruptInteractions.duration = 30

function ChaosModifierInterruptInteractions:start()
	self:post_hook(PlayerStandard, "_get_input", function(playerstate, t)
		if self._next_t and self._next_t > t then
			return
		end

		if playerstate._use_item_expire_t or playerstate:_interacting() or playerstate:_is_reloading() or playerstate:in_steelsight() or playerstate:_is_meleeing() or playerstate:_is_throwing_projectile() then
			local timer = playerstate._interact_params and playerstate._interact_params.timer or 0
			self._next_t = t + math.rand(math.max(4, timer - 2), math.max(8, timer + 2))

			local input = Hooks:GetReturn()
			playerstate:_interupt_action_use_item(t, input)
			playerstate:_interupt_action_interact(t, input)
			playerstate:_interupt_action_reload(t, input)
			playerstate:_interupt_action_steelsight(t, input)
			playerstate:_interupt_action_melee(t, input)
			playerstate:_interupt_action_throw_projectile(t, input)

			playerstate._ext_camera:play_redirect(playerstate:get_animation("stop_running"))

			playerstate._unit:sound():say(math.random() < 0.5 and "g29" or "g60", true)
		elseif playerstate._moving and math.random() < (playerstate:running() and 0.7 or 0.2) then
			self._next_t = t + math.rand(4, 8)

			self._saved_health = playerstate._unit:character_damage():get_real_health()
			managers.player:set_player_state("incapacitated")

			self:queue("revive", 1)

			playerstate._unit:sound():say(math.random() < 0.5 and "g29" or "g60", true)
		else
			self._next_t = t + math.rand(2, 4)
		end
	end)
end

function ChaosModifierInterruptInteractions:revive()
	local player_unit = managers.player:local_player()
	if alive(player_unit) then
		managers.player:set_player_state("standard")
		player_unit:character_damage():set_health(self._saved_health)
	end
end

return ChaosModifierInterruptInteractions
