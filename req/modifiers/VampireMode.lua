ChaosModifierVampireMode = ChaosModifier.class("ChaosModifierVampireMode")
ChaosModifierVampireMode.stealth_safe = false
ChaosModifierVampireMode.duration = 45

function ChaosModifierVampireMode:can_trigger()
	local gstate = managers.groupai:state()
	return gstate._hunt_mode or gstate._task_data.assault.active and (gstate._task_data.assault.phase == "build" or gstate._task_data.assault.phase == "sustain")
end

function ChaosModifierVampireMode:start()
	self._next_t = 0

	managers.player:register_message(Message.OnEnemyKilled, self.class_name, function()
		local player_unit = managers.player:local_player()
		if alive(player_unit) then
			local char_dmg = player_unit:character_damage()
			char_dmg:change_health(char_dmg:_max_health() * char_dmg._max_health_reduction * 0.06)
		end
	end)
end

function ChaosModifierVampireMode:update(t, dt)
	if self._next_t > t then
		return
	end

	self._next_t = t + 1

	local player_unit = managers.player:local_player()
	if alive(player_unit) then
		local char_dmg = player_unit:character_damage()
		if not char_dmg:is_downed() then
			char_dmg:change_health(-char_dmg:_max_health() * char_dmg._max_health_reduction * 0.02)
			char_dmg:_check_bleed_out()
		end
	end
end

function ChaosModifierVampireMode:stop()
	managers.player:unregister_message(Message.OnEnemyKilled, self.class_name)
end

return ChaosModifierVampireMode
