ChaosModifierInvisibleEnemies = ChaosModifier.class("ChaosModifierInvisibleEnemies")
ChaosModifierInvisibleEnemies.duration = 10

function ChaosModifierInvisibleEnemies:update(t, dt)
	local visible = false
	if t < self._activation_t + 1 then
		visible = math.floor((t - self._activation_t) * 10) % 2 == 0
	elseif t > self._activation_t + self.duration - 1 then
		visible = math.floor((t - self._activation_t - self.duration) * 10) % 2 == 0
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
