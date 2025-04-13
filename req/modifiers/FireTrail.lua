ChaosModifierFireTrail = ChaosModifier.class("ChaosModifierFireTrail")
ChaosModifierFireTrail.loud_only = true
ChaosModifierFireTrail.duration = 60
ChaosModifierFireTrail.params = {
	sound_event = "no_sound",
	range = 50,
	curve_pow = 1,
	no_fire_alert = true,
	sound_event_burning = "no_sound",
	sound_event_burning_stop = "burn_loop_gen_stop_fade",
	damage = 0,
	player_damage = 2,
	sound_event_impact_duration = 0,
	burn_tick_period = 0.25,
	burn_duration = 2,
	dot_data_name = "proj_molotov_groundfire",
	effect_name = "effects/payday2/particles/explosions/molotov_grenade"
}

function ChaosModifierFireTrail:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + self.params.burn_duration

	for _, data in pairs(managers.enemy:all_enemies()) do
		if managers.groupai:state():is_enemy_special(data.unit) and data.unit:movement():team().foes.criminal1 then
			EnvironmentFire.spawn(data.unit:movement():m_com(), data.unit:rotation(), self.params, math.UP, data.unit, nil, 0, 1)
		end
	end
end

return ChaosModifierFireTrail
