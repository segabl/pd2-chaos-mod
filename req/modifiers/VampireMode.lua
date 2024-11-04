ChaosModifierVampireMode = ChaosModifier.class("ChaosModifierVampireMode")
ChaosModifierVampireMode.run_in_stealth = false
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
			char_dmg:change_health(char_dmg:_max_health() * 0.05)
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
		char_dmg:change_health(-char_dmg:_max_health() * 0.025)
	end
end

function ChaosModifierVampireMode:stop()
	managers.player:unregister_message(Message.OnEnemyKilled, self.class_name)
end

return ChaosModifierVampireMode
