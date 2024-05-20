---@class ChaosModifier
---@field new fun(self, seed):ChaosModifier
ChaosModifier = class()
ChaosModifier.class_name = "ChaosModifier"
ChaosModifier.register_name = nil
ChaosModifier.name = "You shouldn't see this"
ChaosModifier.run_as_client = false
ChaosModifier.duration = 0

function ChaosModifier:can_trigger()
	return true
end

function ChaosModifier:init(seed)
	self._activation_t = TimerManager:game():time()
	self._seed = seed or math.random(1000000)

	if Network:is_server() then
		NetworkHelper:SendToPeers("ActivateChaosModifier", self.class_name .. "|" .. self._seed)
	end

	if Network:is_server() or self.run_as_client then
		self:start()
	end
end

function ChaosModifier:destroy()
	self._expired = true

	if Network:is_server() or self.run_as_client then
		self:stop()
	end
end

function ChaosModifier:start()
end

function ChaosModifier:stop()
end

function ChaosModifier:update(t, dt)
end

function ChaosModifier:expired(t)
	return self._expired or t > self._activation_t + self.duration
end
