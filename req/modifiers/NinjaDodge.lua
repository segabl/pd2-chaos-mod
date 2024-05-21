---@class ChaosModifierNinjaDodge : ChaosModifier
ChaosModifierNinjaDodge = class(ChaosModifier)
ChaosModifierNinjaDodge.class_name = "ChaosModifierNinjaDodge"
ChaosModifierNinjaDodge.duration = 120
ChaosModifierNinjaDodge.dodge_preset = {
	speed = 1.6,
	occasions = {
		hit = {
			chance = 1,
			check_timeout = { 0, 0 },
			variations = {
				side_step = {
					chance = 0.5,
					shoot_chance = 1,
					shoot_accuracy = 1,
					timeout = { 0, 0 }
				},
				roll = {
					chance = 1,
					timeout = { 0, 0 }
				},
				wheel = {
					chance = 1,
					timeout = { 0, 0 }
				},
				dive = {
					chance = 0.5,
					timeout = { 0, 0 }
				}
			}
		},
		preemptive = {
			chance = 1,
			check_timeout = { 0, 0 },
			variations = {
				side_step = {
					chance = 0.5,
					shoot_chance = 1,
					shoot_accuracy = 1,
					timeout = { 0, 0 }
				},
				roll = {
					chance = 1,
					timeout = { 0, 0 }
				},
				wheel = {
					chance = 1,
					timeout = { 0, 0 }
				},
				dive = {
					chance = 0.5,
					timeout = { 0, 0 }
				}
			}
		},
		scared = {
			chance = 1,
			check_timeout = { 0, 0 },
			variations = {
				side_step = {
					chance = 0.5,
					shoot_chance = 1,
					shoot_accuracy = 1,
					timeout = { 0, 0 }
				},
				roll = {
					chance = 1,
					timeout = { 0, 0 }
				},
				wheel = {
					chance = 1,
					timeout = { 0, 0 }
				},
				dive = {
					chance = 0.5,
					timeout = { 0, 0 }
				}
			}
		}
	}
}

function ChaosModifierNinjaDodge:start()
	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		if enemy.dodge ~= tweak_data.character.presets.dodge.ninja then
			enemy.original_dodge = Utils:FirstNonNil(enemy.original_dodge, enemy.dodge, false)
			enemy.dodge = self.dodge_preset
		end
	end
end

function ChaosModifierNinjaDodge:stop()
	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		if enemy.original_dodge ~= nil then
			enemy.dodge = enemy.original_dodge or nil
		end
	end
end

return ChaosModifierNinjaDodge
