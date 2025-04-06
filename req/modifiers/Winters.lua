ChaosModifierWinters = ChaosModifier.class("ChaosModifierWinters")
ChaosModifierWinters.run_as_client = false
ChaosModifierWinters.loud_only = false
ChaosModifierWinters.duration = -1

function ChaosModifierWinters:can_trigger()
	local gstate = managers.groupai:state()
	return gstate._phalanx_center_pos and not gstate._hunt_mode and gstate._task_data and gstate._task_data.assault.active and not gstate._phalanx_spawn_group and (gstate._task_data.assault.phase == "build" or gstate._task_data.assault.phase == "sustain")
end

function ChaosModifierWinters:start()
	managers.groupai:state():_spawn_phalanx()
end

function ChaosModifierWinters:expired(t, dt)
	return self.super.expired(self, t, dt) or Network:is_server() and t > self._activation_t + 5 and not managers.groupai:state()._hunt_mode
end

return ChaosModifierWinters
