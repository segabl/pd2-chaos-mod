TimerGui.active_units = {}

Hooks:PostHook(TimerGui, "_start", "_start_chaosmod", function(self)
	TimerGui.active_units[self._unit:key()] = self._unit
end)

Hooks:PostHook(TimerGui, "_set_done", "_set_done_chaosmod", function(self)
	TimerGui.active_units[self._unit:key()] = nil
end)
