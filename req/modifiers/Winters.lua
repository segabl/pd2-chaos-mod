---@class ChaosModifierWinters : ChaosModifier
ChaosModifierWinters = class(ChaosModifier)
ChaosModifierWinters.class_name = "ChaosModifierWinters"
ChaosModifierWinters.name = "THERE, THE PAYDAY GANG!"
ChaosModifierWinters.duration = -1

function ChaosModifierWinters:can_trigger()
	local gstate = managers.groupai:state()
	return gstate._phalanx_center_pos and not gstate._hunt_mode and gstate._task_data and gstate._task_data.assault.active and not gstate._phalanx_spawn_group and (gstate._task_data.assault.phase == "build" or gstate._task_data.assault.phase == "sustain")
end

function ChaosModifierWinters:start()
	managers.groupai:state():_spawn_phalanx()
end

function ChaosModifierWinters:expired(t)
	local gstate = managers.groupai:state()
	return self._expired or not gstate._phalanx_spawn_group and not gstate._hunt_mode
end

return ChaosModifierWinters
