ChaosModifierSpinningEnemies = ChaosModifier.class("ChaosModifierSpinningEnemies")
ChaosModifierSpinningEnemies.duration = 30

function ChaosModifierSpinningEnemies:start()
	self._modifier_name = Idstring("action_upper_body")
	self._rotation = Rotation()
end

function ChaosModifierSpinningEnemies:update(t, dt)
	for _, data in pairs(managers.enemy:all_enemies()) do
		data.unit:anim_state_machine():force_modifier(self._modifier_name)
		data.unit:anim_state_machine():get_modifier(self._modifier_name):set_target_y(math.UP)

		mrotation.set_yaw_pitch_roll(self._rotation, (TimerManager:game_animation():time() * 1000) % 360, self._rotation:pitch(), self._rotation:roll())
		data.unit:set_local_rotation(self._rotation)
	end
end

return ChaosModifierSpinningEnemies
