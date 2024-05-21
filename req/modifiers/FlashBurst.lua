---@class ChaosModifierFlashBurst : ChaosModifier
ChaosModifierFlashBurst = class(ChaosModifier)
ChaosModifierFlashBurst.class_name = "ChaosModifierFlashBurst"

function ChaosModifierFlashBurst:start()
	for i = 1, 4 do
		DelayedCalls:Add(tostring(self) .. i, i * 0.5, callback(self, self, "detonate"))
	end
end

function ChaosModifierFlashBurst:detonate()
	local nav_segs = {}
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if not nav_segs[data.seg] then
			nav_segs[data.seg] = true
			managers.groupai:state():detonate_smoke_grenade(managers.navigation:find_random_position_in_segment(data.seg), nil, 1, true)
		end
	end
end

return ChaosModifierFlashBurst
