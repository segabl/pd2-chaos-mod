ChaosModifierProximityEnemies = ChaosModifier.class("ChaosModifierProximityEnemies")
ChaosModifierProximityEnemies.run_as_client = false
ChaosModifierProximityEnemies.duration = 45

function ChaosModifierProximityEnemies:start()
	self._enemies = {}

	self:override(CopBrain._logic_variants.security, "attack", TankCopLogicAttack)
	self:override(CopLogicAttack, "_find_flank_pos", CopLogicAttack._find_pos_close_to_tracker)
end

function ChaosModifierProximityEnemies:update(t, dt)
	for _, data in pairs(managers.enemy:all_enemies()) do
		self:check_enemy(data.unit)
	end
end

function ChaosModifierProximityEnemies:check_enemy(unit)
	local char_dmg = alive(unit) and unit:character_damage()
	if not char_dmg or char_dmg._dead or char_dmg._invulnerable or char_dmg._immortal then
		return
	end

	local u_key = unit:key()
	local brain = unit:brain()
	local target = brain and brain._logic_data and brain._logic_data.attention_obj
	if not target or not alive(target.unit) then
		return
	end

	local t = TimerManager:game():time()
	local enemy_data = self._enemies[u_key]
	local alive = target.unit:character_damage() and not target.unit:character_damage()._dead
	local valid_target = alive and target.verified and target.dis < 350 and target.reaction > AIAttentionObject.REACT_AIM
	if not enemy_data then
		if valid_target then
			self._enemies[u_key] = {
				explode_t = t + 2,
				beep_t = t + 2 / 8
			}
		end
	elseif not valid_target then
		self._enemies[u_key] = nil
	elseif enemy_data.explode_t < t then
		self._enemies[u_key] = nil
		self:explode(unit)
	elseif enemy_data.beep_t < t then
		enemy_data.beep_t = t + math.max(0.05, (enemy_data.explode_t - t) / 8)
		unit:sound():play("USM_Beep", nil, true)
	end
end

function ChaosModifierProximityEnemies:explode(unit)
	unit:character_damage():damage_mission({
		forced = true
	})

	local pos = unit:movement():m_com()
	local range = 500
	local damage = math.min(unit:character_damage()._HEALTH_INIT, 200)
	local normal = math.UP
	local curve_pow = 0.5
	managers.explosion:play_sound_and_effects(pos, normal, range)
	managers.explosion:detect_and_give_dmg({
		hit_pos = pos,
		range = range,
		collision_slotmask = managers.slot:get_mask("explosion_targets"),
		curve_pow = curve_pow,
		damage = damage
	})
	managers.network:session():send_to_peers_synched("sync_explosion_to_client", unit, pos, normal, damage, range, curve_pow)
end

return ChaosModifierProximityEnemies
