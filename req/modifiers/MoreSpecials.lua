ChaosModifierMoreSpecials = ChaosModifier.class("ChaosModifierMoreSpecials")
ChaosModifierMoreSpecials.register_name = "ChaosModifierUnitCategories"
ChaosModifierMoreSpecials.run_as_client = false
ChaosModifierMoreSpecials.loud_only = true
ChaosModifierMoreSpecials.color = "enemy_change"
ChaosModifierMoreSpecials.duration = 90

function ChaosModifierMoreSpecials:start()
	self:post_hook(JobManager, "current_spawn_limit", function()
		return math.huge
	end)

	for _, group_ai_state_name in pairs({ "besiege", "street", "safehouse" }) do
		for _, assault_state in pairs(tweak_data.group_ai[group_ai_state_name]) do
			if type(assault_state) == "table" and type(assault_state.groups) == "table" then
				for group_name, weights in pairs(assault_state.groups) do
					local group = tweak_data.group_ai.enemy_spawn_groups[group_name]
					if group then
						for _, data in pairs(group.spawn) do
							local special_type = tweak_data.group_ai.unit_categories[data.unit].special_type
							if special_type and special_type ~= "medic" and data.amount_min and data.amount_min > 0 then
								for i, weight in pairs(weights) do
									self:override(weights, i, weight * 10)
								end
								break
							end
						end
					end
				end
			end
		end
	end
end

return ChaosModifierMoreSpecials
