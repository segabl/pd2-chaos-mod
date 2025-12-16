ChaosModifierVampireMode = ChaosModifier.class("ChaosModifierVampireMode")
ChaosModifierVampireMode.stealth_safe = false
ChaosModifierVampireMode.duration = 45

function ChaosModifierVampireMode:can_trigger()
	local gstate = managers.groupai:state()
	return gstate._hunt_mode or gstate._task_data.assault.active and (gstate._task_data.assault.phase == "build" or gstate._task_data.assault.phase == "sustain")
end

function ChaosModifierVampireMode:start()
	self._next_t = 0

	managers.player:register_message(Message.OnEnemyKilled, self.class_name, function(_, _, killed_unit)
		local player_unit = managers.player:local_player()
		if alive(player_unit) then
			local char_dmg = player_unit:character_damage()
			char_dmg:change_health(char_dmg:_max_health() * char_dmg._max_health_reduction * 0.06)
			self:health_popup(killed_unit:body(0):position())
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

function ChaosModifierVampireMode:health_popup(pos)
	local w = math.X * 20
	local h = math.UP * 20
	for _ = 1, 5 do
		local offset = Vector3(math.rand(-10, 10), math.rand(-10, 10), math.rand(-10, 10))
		local current_pos = mvector3.copy(pos)
		local color = Color(math.rand(0.25, 1), 0, 0)
		local ws = ChaosMod:world_gui():create_world_workspace(10, 10, current_pos, w, h)
		ws:set_billboard(ws.BILLBOARD_BOTH)
		ws:panel():rect({
			color = color,
			x = ws:panel():w() * 0.35,
			w = ws:panel():w() * 0.3
		})
		ws:panel():rect({
			color = color,
			y = ws:panel():h() * 0.35,
			h = ws:panel():h() * 0.3
		})
		ws:panel():animate(function()
			over(math.rand(0.25, 1), function(t)
				local player_unit = managers.player:local_player()
				if not alive(player_unit) then
					return
				end
				mvector3.lerp(current_pos, pos, player_unit:position(), t)
				mvector3.add(current_pos, offset)
				ws:set_world(10, 10, current_pos, w, h)
				ws:panel():set_alpha(1 - t ^ 2)
			end)
			ws:gui():destroy_workspace(ws)
		end)
	end
end

return ChaosModifierVampireMode
