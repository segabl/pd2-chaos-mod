ChaosModifierInvisibleEnemies = ChaosModifier.class("ChaosModifierInvisibleEnemies")
ChaosModifierInvisibleEnemies.duration = 10

function ChaosModifierInvisibleEnemies:update(t, dt)
	for _, data in pairs(managers.enemy:all_enemies()) do
		data.unit:set_visible(false)
	end
end

function ChaosModifierInvisibleEnemies:stop()
	for _, data in pairs(managers.enemy:all_enemies()) do
		data.unit:set_visible(true)
	end
end

return ChaosModifierInvisibleEnemies
