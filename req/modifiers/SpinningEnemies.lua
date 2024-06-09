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

		mrotation.set_yaw(self._rotation, (t * 1000) % 360)
		data.unit:set_local_rotation(self._rotation)
	end
end

return ChaosModifierSpinningEnemies
