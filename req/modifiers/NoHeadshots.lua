---@class ChaosModifierNoHeadshots : ChaosModifier
ChaosModifierNoHeadshots = class(ChaosModifier)
ChaosModifierNoHeadshots.class_name = "ChaosModifierNoHeadshots"
ChaosModifierNoHeadshots.duration = 30
ChaosModifierNoHeadshots.run_as_client = true

function ChaosModifierNoHeadshots:start()
	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		enemy.original_ignore_headshot = Utils:FirstNonNil(enemy.original_ignore_headshot, enemy.ignore_headshot, false)
		enemy.original_no_headshot_add_mul = Utils:FirstNonNil(enemy.original_no_headshot_add_mul, enemy.no_headshot_add_mul, false)
		enemy.ignore_headshot = true
		enemy.no_headshot_add_mul = true
	end
end

function ChaosModifierNoHeadshots:stop()
	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		if enemy.original_ignore_headshot ~= nil then
			enemy.ignore_headshot = enemy.original_ignore_headshot or nil
		end
		if enemy.original_no_headshot_add_mul ~= nil then
			enemy.no_headshot_add_mul = enemy.original_no_headshot_add_mul or nil
		end
	end
end

return ChaosModifierNoHeadshots
