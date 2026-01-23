ChaosModifierInvisibleEnemies = ChaosModifier.class("ChaosModifierInvisibleEnemies")
ChaosModifierInvisibleEnemies.duration = 10

function ChaosModifierInvisibleEnemies:update(t, dt)
	local visible = false
	local time_elapsed, time_left = self:time_elapsed(t), self:time_left(t)
	if time_elapsed < 1 then
		visible = math.floor(time_elapsed * 10) % 2 == 0
	elseif time_left < 1 then
		visible = math.floor(time_left * 10) % 2 == 0
	end
	for _, data in pairs(managers.enemy:all_enemies()) do
		data.unit:set_visible(visible)
	end
end

function ChaosModifierInvisibleEnemies:stop()
	for _, data in pairs(managers.enemy:all_enemies()) do
		data.unit:set_visible(true)
	end
end

return ChaosModifierInvisibleEnemies
