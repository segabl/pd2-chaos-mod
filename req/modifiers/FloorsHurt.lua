ChaosModifierFloorsHurt = ChaosModifier.class("ChaosModifierFloorsHurt")
ChaosModifierFloorsHurt.duration = 30
ChaosModifierFloorsHurt.exceptions = {
	alex_1 = { 36, 94, 95, 97, 98 },
	arm_for = { 35, 48 },
	election_day_1 = { 88, 89, 142, 143, 144, 145, 146, 203, 219, 223, 231, 234 },
	election_day_2 = { 22, 29, 47, 48, 68, 243 },
	firestarter_1 = { 60, 120, 121, 122, 123, 124, 125, 126 },
	hox_3 = { 6, 77, 80, 84 },
	rat = { 36, 94, 95, 103, 108 },
	trai = { 17, 56, 57, 58, 60, 61, 62, 63, 64, 66, 68, 69, 70, 71, 72, 73, 116, 117, 118, 119, 120, 121, 122, 123, 124, 230, 231, 232 }
}

function ChaosModifierFloorsHurt:start()
	self._next_t = self._activation_t + 1
	self._exceptions = table.list_to_set(ChaosModifierFloorsHurt.exceptions[Global.game_settings.level_id] or {})
	self:show_text(managers.localization:to_upper_text("ChaosModifierFloorsHurt"), 2, true)
end

function ChaosModifierFloorsHurt:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + 0.5

	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local actual_pos = player_unit:movement():m_pos()
	local nav_tracker = player_unit:movement():nav_tracker()
	local field_pos = nav_tracker:field_position()
	if self._exceptions[nav_tracker:nav_segment()] or mvector3.distance(actual_pos, field_pos) > 50 then
		return
	end

	player_unit:character_damage():damage_simple({
		variant = "bullet",
		damage = 0.5
	})
end

return ChaosModifierFloorsHurt
