---@class ChaosModifier
---@field new fun(self, seed):ChaosModifier
ChaosModifier = class()
ChaosModifier.class_name = "ChaosModifier"
ChaosModifier.register_name = nil
ChaosModifier.run_as_client = true
ChaosModifier.stealth_safe = true
ChaosModifier.loud_only = false
ChaosModifier.duration = 0
ChaosModifier.fixed_duration = false
ChaosModifier.weight_mul = 1
ChaosModifier.activation_sound = "Play_star_hit"
ChaosModifier.enabled = true
ChaosModifier._overrides = {} ---@type table<table, table<string, { original: any, overrides: { modifier: ChaosModifier, value: any }[] }>>
ChaosModifier._show_text_queue = {}

---@return ChaosModifier
function ChaosModifier.class(name, super)
	local c = class(super or ChaosModifier)
	c.class_name = name
	c.weight = 1
	return c
end

function ChaosModifier:can_trigger()
	return true
end

function ChaosModifier:init(seed)
	self._activation_t = ChaosMod:time()
	self._seed = seed or math.random(1000000)
	self._completed_peers = {}
	self._hud_modifier = HUDChaosModifier:new(self)

	if Network:is_server() then
		NetworkHelper:SendToPeers("ActivateChaosModifier", self.class_name .. "|" .. self._seed)
	end

	if Network:is_server() or self.run_as_client then
		self:start()
	end

	if self.activation_sound then
		managers.hud:post_event(self.activation_sound)
	end
end

function ChaosModifier:destroy()
	if self._pre_hooked then
		Hooks:RemovePreHook(self.class_name)
		self._pre_hooked = nil
	end

	if self._post_hooked then
		Hooks:RemovePostHook(self.class_name)
		self._post_hooked = nil
	end

	if self._overrides then
		-- This monstrosity makes sure overriden values get restored properly,
		-- either to the value another modifier set it to before or to the original value
		for obj, value_data in pairs(ChaosModifier._overrides) do
			for value_name, override_data in pairs(value_data) do
				for i, override in table.reverse_ipairs(override_data.overrides) do
					if override.modifier == self then
						if i == #override_data.overrides then
							if i > 1 then
								obj[value_name] = override_data.overrides[i - 1].value
							else
								obj[value_name] = override_data.original
							end
						end
						table.remove(override_data.overrides, i)
					end
				end
				if #override_data.overrides == 0 then
					value_data[value_name] = nil
				end
			end
		end
		self._overrides = nil
	end

	self._expired = true

	if Network:is_server() or self.run_as_client then
		self:stop()
	end

	if Network:is_server() and self.duration < 0 then
		NetworkHelper:SendToPeers("StopChaosModifier", self.class_name)
	end
end

function ChaosModifier:start()
end

function ChaosModifier:stop()
end

function ChaosModifier:update(t, dt)
end

function ChaosModifier:complete(peer_id)
	if not peer_id then
		self._completed = true
		NetworkHelper:SendToPeers("CompleteChaosModifier", self.class_name)
	else
		self._completed_peers[peer_id] = true
	end

	if not self:completed() then
		self._hud_modifier:complete(peer_id)
	end
end

function ChaosModifier:completed()
	return self._completed and table.size(self._completed_peers) >= table.size(managers.network:session():peers())
end

function ChaosModifier:progress(t, dt)
	return self.duration == 0 and 1 or self.duration > 0 and (t - self._activation_t) / self.duration or 0
end

function ChaosModifier:override(obj, k, v)
	self._overrides = true
	ChaosModifier._overrides[obj] = ChaosModifier._overrides[obj] or {}
	ChaosModifier._overrides[obj][k] = ChaosModifier._overrides[obj][k] or {
		original = obj[k],
		overrides = {}
	}
	table.insert(ChaosModifier._overrides[obj][k].overrides, {
		modifier = self,
		value = v
	})
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
	ChaosMod:queue(tostring(self) .. func_name, seconds, callback(self, self, func_name))
end

function ChaosModifier:unqueue(func_name)
	ChaosMod:unqueue(tostring(self) .. func_name)
end

function ChaosModifier:expired(t, dt)
	return self._expired or self:progress(t, dt) >= 1 or self:completed()
end

function ChaosModifier:show_text(text, time, large)
	if alive(ChaosModifier._show_text_panel) then
		table.insert(ChaosModifier._show_text_queue, { self, text, time, large })
		return
	end

	local panel = ChaosMod:panel(true):panel({
		layer = 100
	})

	local r = panel:rect({
		color = Color.black:with_alpha(0.65)
	})

	local t = panel:text({
		layer = 1,
		text = text,
		font = tweak_data.menu.pd2_large_font,
		font_size = large and 48 or 32,
		align = "center"
	})

	t:set_shape(t:text_rect())
	t:set_center(panel:w() * 0.5, panel:h() * 0.35)

	if not large then
		r:set_size(panel:w(), t:h() + 32)
		r:set_center(t:center())
	end

	panel:animate(function(o)
		ChaosMod:anim_over(0.25, function(p)
			o:set_alpha(p)
		end)

		local t = 0
		while t < (#ChaosModifier._show_text_queue > 0 and math.min(0.5, time - 0.5) or time - 0.5) do
			coroutine.yield()
			t = t + ChaosMod:delta_time()
		end

		ChaosMod:anim_over(0.25, function(p)
			o:set_alpha(1 - p)
		end)

		o:parent():remove(o)

		if #ChaosModifier._show_text_queue > 0 then
			local data = table.remove(ChaosModifier._show_text_queue, 1)
			data[1]:show_text(data[2], data[3], data[4])
		end
	end)

	ChaosModifier._show_text_panel = panel
end
