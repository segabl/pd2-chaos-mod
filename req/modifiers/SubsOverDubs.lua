ChaosModifierSubsOverDubs = ChaosModifier.class("ChaosModifierSubsOverDubs")
ChaosModifierSubsOverDubs.tags = { "VoiceChange" }
ChaosModifierSubsOverDubs.conflict_tags = { "VoiceChange" }
ChaosModifierSubsOverDubs.duration = 90

function ChaosModifierSubsOverDubs:start()
	for _, character in pairs(managers.criminals:characters()) do
		if alive(character.unit) then
			character.unit:sound():set_voice("rb12")
		end
	end
end

function ChaosModifierSubsOverDubs:stop()
	for _, character in pairs(managers.criminals:characters()) do
		if alive(character.unit) then
			character.unit:sound():set_voice(character.static_data.voice)
		end
	end
end

return ChaosModifierSubsOverDubs
