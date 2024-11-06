ChaosModifierExplosiveBullets = ChaosModifier.class("ChaosModifierExplosiveBullets")
ChaosModifierExplosiveBullets.register_name = "ChaosModifierBulletChange"
ChaosModifierExplosiveBullets.stealth_safe = false
ChaosModifierExplosiveBullets.duration = 30

function ChaosModifierExplosiveBullets:start()
	self:post_hook(RaycastWeaponBase, "bullet_class", function()
		return InstantExplosiveBulletBase
	end)
	self:post_hook(RaycastWeaponBase, "_get_current_damage", function(weaponbase)
		return Hooks:GetReturn() * (weaponbase:bullet_class() == InstantExplosiveBulletBase and weaponbase._bullet_class == InstantBulletBase and 1.5 or 1)
	end)
end

return ChaosModifierExplosiveBullets
