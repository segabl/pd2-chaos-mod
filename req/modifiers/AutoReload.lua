ChaosModifierAutoReload = ChaosModifier.class("ChaosModifierAutoReload")
ChaosModifierAutoReload.register_name = "PlayerReload"
ChaosModifierAutoReload.duration = 30

function ChaosModifierAutoReload:start()
	self._trigger_ratio = 0.75
	self:post_hook(PlayerStandard, "_get_input", function(playerstate)
		if not playerstate._equipped_unit then
			return
		end
		local mag_max, mag_remaining = playerstate._equipped_unit:base():ammo_info()
		local mag_ratio = mag_remaining / mag_max
		if mag_ratio < self._trigger_ratio then
			self._trigger_ratio = mag_ratio - 0.25
			Hooks:GetReturn().btn_reload_press = true
		elseif mag_ratio == 1 then
			self._trigger_ratio = 0.75
		end
	end)
end

return ChaosModifierAutoReload
