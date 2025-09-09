ChaosModifierDallasMedicBag = ChaosModifier.class("ChaosModifierDallasMedicBag")
ChaosModifierDallasMedicBag.conflict_tags = { "VoiceChange" }
ChaosModifierDallasMedicBag.duration = 60

function ChaosModifierDallasMedicBag:start()
	for _, character in pairs(managers.criminals:characters()) do
		if alive(character.unit) then
			character.unit:sound():set_voice("rb4")
		end
	end

	self:override(PlayerSound, "say", function(playersound, _, ...)
		return self:get_override(PlayerSound, "say")(playersound, "g80x_plu", ...)
	end)
end

function ChaosModifierDallasMedicBag:stop()
	for _, character in pairs(managers.criminals:characters()) do
		if alive(character.unit) then
			character.unit:sound():set_voice(character.static_data.voice)
		end
	end
end

return ChaosModifierDallasMedicBag
