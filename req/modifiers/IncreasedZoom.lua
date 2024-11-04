ChaosModifierIncreasedZoom = ChaosModifier.class("ChaosModifierIncreasedZoom")
ChaosModifierIncreasedZoom.duration = 45

function ChaosModifierIncreasedZoom:start()
	self:post_hook(PlayerStandard, "get_zoom_fov", function(playerstate)
		if playerstate._state_data.in_steelsight then
			return 20
		end
	end)
end

return ChaosModifierIncreasedZoom
