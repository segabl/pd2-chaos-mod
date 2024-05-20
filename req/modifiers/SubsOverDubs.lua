---@class ChaosModifierSubsOverDubs : ChaosModifier
ChaosModifierSubsOverDubs = class(ChaosModifier)
ChaosModifierSubsOverDubs.class_name = "ChaosModifierSubsOverDubs"
ChaosModifierSubsOverDubs.register_name = "ChaosModifierVoiceChange"
ChaosModifierSubsOverDubs.name = "Subs > Dubs"
ChaosModifierSubsOverDubs.run_as_client = true
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
