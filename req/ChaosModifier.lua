---@class ChaosModifier
---@field new fun(self, seed):ChaosModifier
ChaosModifier = class()
ChaosModifier.class_name = "ChaosModifier"
ChaosModifier.register_name = nil
ChaosModifier.run_as_client = false
ChaosModifier.duration = 0
ChaosModifier.nil_value = {}

---@return ChaosModifier
function ChaosModifier.class(name, super)
	local c = class(super or ChaosModifier)
	c.class_name = name
	return c
end

function ChaosModifier:can_trigger()
	return true
end

function ChaosModifier:init(seed)
	self._activation_t = TimerManager:game():time()
	self._seed = seed or math.random(1000000)
	self._overrides = {}

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

	if self._pre_hooked then
		Hooks:RemovePreHook(self.class_name)
	end

	if self._post_hooked then
		Hooks:RemovePostHook(self.class_name)
	end

	for obj, data in pairs(self._overrides) do
		for k, v in pairs(data) do
			if v == ChaosModifier.nil_value then
				obj[k] = nil
			else
				obj[k] = v
			end
		end
	end

	self._overrides = nil
end

function ChaosModifier:start()
end

function ChaosModifier:stop()
end

function ChaosModifier:update(t, dt)
end

function ChaosModifier:override(obj, k, v)
	self._overrides[obj] = self._overrides[obj] or {}
	if not self._overrides[obj][k] then
		self._overrides[obj][k] = obj[k] == nil and ChaosModifier.nil_value or obj[k]
	end
	obj[k] = v
end

function ChaosModifier:pre_hook(obj, func_name, func)
	Hooks:PreHook(obj, func_name, self.class_name, func)
	self._pre_hooked = true
end

function ChaosModifier:post_hook(obj, func_name, func)
	Hooks:PostHook(obj, func_name, self.class_name, func)
	self._post_hooked = true
end

function ChaosModifier:queue(func_name, seconds)
	DelayedCalls:Add(tostring(self) .. func_name, seconds, callback(self, self, func_name))
end

function ChaosModifier:unqueue(func_name)
	DelayedCalls:Remove(tostring(self) .. func_name)
end

function ChaosModifier:expired(t)
	return self._expired or t > self._activation_t + self.duration
end