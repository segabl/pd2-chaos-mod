ChaosModifierRogueBots = ChaosModifier.class("ChaosModifierRogueBots")
ChaosModifierRogueBots.run_as_client = false
ChaosModifierRogueBots.stealth_safe = false
ChaosModifierRogueBots.duration = 90

function ChaosModifierRogueBots:can_trigger()
	return table.size(managers.groupai:state():all_AI_criminals()) > 0
end

function ChaosModifierRogueBots:start()
	self:post_hook(GroupAIStateBase, "_determine_objective_for_criminal_AI", function(gstate, unit)
		if not gstate:all_AI_criminals()[unit:key()] then
			return
		end

		local area = gstate._area_data[table.random_key(gstate._area_data)]
		return {
			type = "free",
			area = area,
			nav_seg = area.pos_nav_seg
		}
	end)

	self:override(TeamAIBrain, "on_long_dis_interacted", function(brain)
		DelayedCalls:Add(tostring(brain._unit:key()) .. self.class_name, math.rand(2, 3), function()
			if alive(brain._unit) then
				brain._unit:sound():say(table.random({ "g11", "g29", "g60", }), true)
			end
		end)
	end)

	for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
		if alive(data.unit) then
			managers.groupai:state():on_criminal_jobless(data.unit)
		end
	end
end

function ChaosModifierRogueBots:stop()
	for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
		if alive(data.unit) then
			managers.groupai:state():on_criminal_jobless(data.unit)
		end
	end
end

return ChaosModifierRogueBots
