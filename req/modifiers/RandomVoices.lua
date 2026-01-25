ChaosModifierRandomVoices = ChaosModifier.class("ChaosModifierRandomVoices")
ChaosModifierRandomVoices.tags = { "VoiceChange" }
ChaosModifierRandomVoices.conflict_tags = { "VoiceChange" }
ChaosModifierRandomVoices.duration = 90

function ChaosModifierRandomVoices:start()
	self:pre_hook(PlayerSound, "say", function(playersound)
		if math.random() < 0.75 then
			playersound:set_voice("rb" .. math.random(1, 22))
		end
	end)
end

function ChaosModifierRandomVoices:stop()
	for _, character in pairs(managers.criminals:characters()) do
		if alive(character.unit) then
			character.unit:sound():set_voice(character.static_data.voice)
		end
	end
end

return ChaosModifierRandomVoices
