ChaosModifierScreenShakeSteps = ChaosModifier.class("ChaosModifierScreenShakeSteps")
ChaosModifierScreenShakeSteps.duration = 60

function ChaosModifierScreenShakeSteps:start()
	self:override(CopMovement, "get_footstep_event", function(movement)
		return "footstep_npc_bulldozer_" .. (movement._unit:anim_data().run and "run" or "walk")
	end)

	self:post_hook(GamePlayCentralManager, "request_play_footstep", function(_, unit, m_pos)
		local player_unit = managers.player:local_player()
		if not alive(player_unit) or unit == player_unit then
			return
		end

		local feedback = managers.feedback:create("mission_triggered")
		local dis = mvector3.distance(m_pos, player_unit:position())
		local mul = math.map_range_clamped(dis, 0, 1000, 1.5, 0)

		feedback:set_unit(player_unit)
		feedback:set_enabled("camera_shake", true)

		feedback:play(
			"camera_shake",
			"multiplier",
			mul,
			"camera_shake",
			"amplitude",
			0.5,
			"camera_shake",
			"attack",
			0,
			"camera_shake",
			"sustain",
			0.1,
			"camera_shake",
			"decay",
			0.25
		)
	end)
end

return ChaosModifierScreenShakeSteps
