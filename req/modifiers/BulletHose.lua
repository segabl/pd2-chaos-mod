ChaosModifierBulletHose = ChaosModifier.class("ChaosModifierBulletHose")
ChaosModifierBulletHose.run_as_client = true
ChaosModifierBulletHose.duration = 20

function ChaosModifierBulletHose:start()
	for i, spread in pairs(tweak_data.weapon.stats.spread) do
		self:override(tweak_data.weapon.stats.spread, i, 2 + spread * 4)
	end

	managers.player:add_to_temporary_property("bullet_storm", self.duration, 1)
end

function ChaosModifierBulletHose:stop()
	managers.player:remove_temporary_property("bullet_storm")
end

return ChaosModifierBulletHose
