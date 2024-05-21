---@class ChaosModifierRandomVoices : ChaosModifier
ChaosModifierRandomVoices = class(ChaosModifier)
ChaosModifierRandomVoices.class_name = "ChaosModifierRandomVoices"
ChaosModifierRandomVoices.register_name = "ChaosModifierVoiceChange"
ChaosModifierRandomVoices.run_as_client = true
ChaosModifierRandomVoices.duration = 90

function ChaosModifierRandomVoices:start()
	Hooks:PreHook(PlayerSound, "say", self.class_name, function(playersound)
		if math.random() < 0.75 then
			playersound:set_voice("rb" .. math.random(1, 22))
		end
	end)
end

function ChaosModifierRandomVoices:stop()
	Hooks:RemovePreHook(self.class_name)

	for _, character in pairs(managers.criminals:characters()) do
		if alive(character.unit) then
			character.unit:sound():set_voice(character.static_data.voice)
		end
	end
end

return ChaosModifierRandomVoices
