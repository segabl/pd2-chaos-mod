ChaosModifierDallasMedicBag = ChaosModifier.class("ChaosModifierDallasMedicBag")
ChaosModifierDallasMedicBag.register_name = "ChaosModifierVoiceChange"
ChaosModifierDallasMedicBag.run_as_client = true
ChaosModifierDallasMedicBag.duration = 60

function ChaosModifierDallasMedicBag:start()
	for _, character in pairs(managers.criminals:characters()) do
		if alive(character.unit) then
			character.unit:sound():set_voice("rb4")
		end
	end

	local say_original = PlayerSound.say
	self:override(PlayerSound, "say", function(playersound, sound_name, ...)
		return say_original(playersound, "g80x_plu", ...)
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
