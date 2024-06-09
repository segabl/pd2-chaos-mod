ChaosModifierTimeOut = ChaosModifier.class("ChaosModifierTimeOut")
ChaosModifierTimeOut.duration = 25

function ChaosModifierTimeOut:can_trigger()
	return table.size(managers.groupai:state():all_player_criminals()) > 0
end

function ChaosModifierTimeOut:pick_player()
	local units = {}
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if alive(data.unit) then
			table.insert(units, data.unit)
		end
	end

	table.sort(units, function(a, b)
		return a:network():peer():id() > b:network():peer():id()
	end)

	math.randomseed(self._seed)
	local unit = table.random(units)

	self:show_text(managers.localization:to_upper_text("ChaosModifierTimeOutPicked", { PLAYER = unit:base():nick_name() }), 3)

	if unit == managers.player:local_player() then
		self._unit = unit
	end
end

function ChaosModifierTimeOut:start()
	self:show_text(managers.localization:to_upper_text("ChaosModifierTimeOutStart"), 2, true)
	self:queue("pick_player", 2)
end

function ChaosModifierTimeOut:update(t, dt)
	if not alive(self._unit) then
		return
	end

	local state_name = self._unit:movement():current_state_name()
	if state_name == "civilian" then
		return
	end

	local allowed_states = {
		standard = true,
		mask_off = true,
		clean = true,
		carry = true,
		bipod = true,
		driving = true,
		player_turret = true
	}

	if allowed_states[state_name] and not self._unit:movement():on_zipline() then
		managers.player._current_state = "clean"
		managers.player:set_player_state("civilian")
	end
end

function ChaosModifierTimeOut:stop()
	if alive(self._unit) and self._unit:movement():current_state_name() == "civilian" then
		managers.player:set_player_state("standard")
	end
end

return ChaosModifierTimeOut
