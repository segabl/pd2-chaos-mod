ChaosModifierExplosiveBullets = ChaosModifier.class("ChaosModifierExplosiveBullets")
ChaosModifierExplosiveBullets.run_as_client = true
ChaosModifierExplosiveBullets.duration = 30

function ChaosModifierExplosiveBullets:start()
	self:post_hook(RaycastWeaponBase, "bullet_class", function()
		return InstantExplosiveBulletBase
	end)
end

return ChaosModifierExplosiveBullets
