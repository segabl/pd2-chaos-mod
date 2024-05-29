ChaosModifierInvisibleEnemies = ChaosModifier.class("ChaosModifierInvisibleEnemies")
ChaosModifierInvisibleEnemies.run_as_client = true
ChaosModifierInvisibleEnemies.duration = 5

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
