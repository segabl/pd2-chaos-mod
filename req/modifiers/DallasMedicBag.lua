---@class ChaosModifierDallasMedicBag : ChaosModifier
ChaosModifierDallasMedicBag = class(ChaosModifier)
ChaosModifierDallasMedicBag.class_name = "ChaosModifierDallasMedicBag"
ChaosModifierDallasMedicBag.register_name = "ChaosModifierVoiceChange"
ChaosModifierDallasMedicBag.run_as_client = true
ChaosModifierDallasMedicBag.duration = 60

function ChaosModifierDallasMedicBag:start()
	for _, character in pairs(managers.criminals:characters()) do
		if alive(character.unit) then
			character.unit:sound():set_voice("rb4")
		end
	end

	ChaosModifierDallasMedicBag._say = ChaosModifierDallasMedicBag._say or PlayerSound.say
	PlayerSound.say = function(playersound, sound_name, ...)
		return ChaosModifierDallasMedicBag._say(playersound, "g80x_plu", ...)
	end
end

function ChaosModifierDallasMedicBag:stop()
	for _, character in pairs(managers.criminals:characters()) do
		if alive(character.unit) then
			character.unit:sound():set_voice(character.static_data.voice)
		end
	end

	PlayerSound.say = ChaosModifierDallasMedicBag._say
end

return ChaosModifierDallasMedicBag
