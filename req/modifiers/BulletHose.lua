---@class ChaosModifierBulletHose : ChaosModifier
ChaosModifierBulletHose = class(ChaosModifier)
ChaosModifierBulletHose.class_name = "ChaosModifierBulletHose"
ChaosModifierBulletHose.name = "Bullet Hose"
ChaosModifierBulletHose.run_as_client = true
ChaosModifierBulletHose.duration = 20

function ChaosModifierBulletHose:start()
	ChaosModifierBulletHose._spread = ChaosModifierBulletHose._spread or clone(tweak_data.weapon.stats.spread)
	for i, spread in pairs(ChaosModifierBulletHose._spread) do
		tweak_data.weapon.stats.spread[i] = 2 + spread * 4
	end

	managers.player:add_to_temporary_property("bullet_storm", self.duration, 1)
end

function ChaosModifierBulletHose:stop()
	for i, spread in pairs(ChaosModifierBulletHose._spread) do
		tweak_data.weapon.stats.spread[i] = spread
	end

	managers.player:remove_temporary_property("bullet_storm")
end

return ChaosModifierBulletHose
