ChaosModifierWeaponSwitch = ChaosModifier.class("ChaosModifierWeaponSwitch")
ChaosModifierWeaponSwitch.duration = 30

function ChaosModifierWeaponSwitch:start()
	self._switch_weapon = false
	self:post_hook(PlayerStandard, "_get_input", function()
		if self._switch_weapon then
			Hooks:GetReturn().btn_switch_weapon_press = true
			self._switch_weapon = false
		end
	end)
end

function ChaosModifierWeaponSwitch:update(t, dt)
	if self._next_t and self._next_t > t then
		return
	end

	self._next_t = t + math.rand(5, 10)

	self._switch_weapon = true
end

return ChaosModifierWeaponSwitch
