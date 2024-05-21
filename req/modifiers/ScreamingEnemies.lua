---@class ChaosModifierScreamingEnemies : ChaosModifier
ChaosModifierScreamingEnemies = class(ChaosModifier)
ChaosModifierScreamingEnemies.class_name = "ChaosModifierScreamingEnemies"
ChaosModifierScreamingEnemies.duration = 60

function ChaosModifierScreamingEnemies:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	local enemies = {}
	for _, data in pairs(managers.enemy:all_enemies()) do
		if alive(data.unit) and not data.unit:sound():speaking(t) then
			table.insert(enemies, data.unit)
		end
	end

	local enemy = table.random(enemies)
	if enemy then
		enemy:sound():say("burndeath", true)
		self._next_t = t + 0.1
	end
end

return ChaosModifierScreamingEnemies
