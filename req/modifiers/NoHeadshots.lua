ChaosModifierNoHeadshots = ChaosModifier.class("ChaosModifierNoHeadshots")
ChaosModifierNoHeadshots.duration = 25

function ChaosModifierNoHeadshots:start()
	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		self:override(enemy, "ignore_headshot", true)
		self:override(enemy, "no_headshot_add_mul", true)
	end
end

return ChaosModifierNoHeadshots
