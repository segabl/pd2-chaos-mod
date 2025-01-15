ChaosModifierCombustJokers = ChaosModifier.class("ChaosModifierCombustJokers")
ChaosModifierCombustJokers.loud_only = true

function ChaosModifierCombustJokers:can_trigger()
	return table.size(managers.groupai:state()._converted_police) > 0
end

function ChaosModifierCombustJokers:start()
	for _, unit in pairs(managers.groupai:state()._converted_police) do
		if alive(unit) then
			managers.explosion:play_sound_and_effects(unit:position(), math.UP, 300, {
				effect = "effects/payday2/particles/explosions/grenade_incendiary_explosion",
				sound_event = "white_explosion"
			})
		end
	end

	if Network:is_server() then
		self:queue("combust", 0.5)
	end
end

function ChaosModifierCombustJokers:combust()
	for _, unit in pairs(managers.groupai:state()._converted_police) do
		unit:character_damage():damage_fire({
			variant = "fire",
			damage = math.huge,
			col_ray = {
				unit = unit,
				position = unit:position(),
				ray = math.UP
			}
		})
	end
end

return ChaosModifierCombustJokers
