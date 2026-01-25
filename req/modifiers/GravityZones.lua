ChaosModifierGravityZones = ChaosModifier.class("ChaosModifierGravityZones")
ChaosModifierGravityZones.tags = { "Gravity" }
ChaosModifierGravityZones.conflict_tags = { "Gravity" }
ChaosModifierGravityZones.duration = 40
ChaosModifierGravityZones.string_ids = {
	{ 0.2, "ChaosModifierGravityZonesSuperLow" },
	{ 0.5, "ChaosModifierGravityZonesVeryLow" },
	{ 0.8, "ChaosModifierGravityZonesLow" },
	{ 1.2, "ChaosModifierGravityZonesNormal" },
	{ 1.5, "ChaosModifierGravityZonesHigh" },
	{ 1.8, "ChaosModifierGravityZonesVeryHigh" },
	{ 2, "ChaosModifierGravityZonesSuperHigh" }
}

function ChaosModifierGravityZones:start()
	self._gravity_mul = 1
	self._iteration = 1

	self:change_gravity()
end

function ChaosModifierGravityZones:change_gravity()
	math.randomseed(self._seed * self._iteration)

	local delay = math.rand(5, 10)
	self._gravity_mul = 1 + (math.random() ^ 0.75) * (math.random() < 0.5 and 1 or -1)

	local string_id
	for _, v in pairs(self.string_ids) do
		if self._gravity_mul <= v[1] then
			string_id = v[2]
			break
		end
	end

	managers.hud:show_hint({
		text = managers.localization:text(string_id),
		time = 1
	})

	self._iteration = self._iteration + 1

	self:queue("change_gravity", delay)
end

function ChaosModifierGravityZones:update(t, dt)
	local player_unit = managers.player:local_player()
	if alive(player_unit) and player_unit:mover() and player_unit:mover():gravity():length() > 0 then
		player_unit:mover():set_gravity(Vector3(0, 0, -982 * self._gravity_mul))
	end
end

function ChaosModifierGravityZones:stop()
	self:unqueue("change_gravity")

	local player_unit = managers.player:local_player()
	if alive(player_unit) and player_unit:mover() and player_unit:mover():gravity():length() > 0 then
		player_unit:mover():set_gravity(Vector3(0, 0, -982))
	end
end

return ChaosModifierGravityZones
