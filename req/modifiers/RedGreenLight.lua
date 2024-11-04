ChaosModifierRedGreenLight = ChaosModifier.class("ChaosModifierRedGreenLight")
ChaosModifierRedGreenLight.register_name = "ChaosModifierPlayerMovement"
ChaosModifierRedGreenLight.light_time = 2.5
ChaosModifierRedGreenLight.pause_time = 1.5
ChaosModifierRedGreenLight.amount = 8
ChaosModifierRedGreenLight.duration = (ChaosModifierRedGreenLight.light_time + ChaosModifierRedGreenLight.pause_time) * ChaosModifierRedGreenLight.amount
ChaosModifierRedGreenLight.fixed_duration = true

function ChaosModifierRedGreenLight:start()
	self._light = World:create_light("omni|specular")
	self._light:set_near_range(0)
	self._light:set_far_range(500)
	self._light:set_color(Vector3(0, 1, 0))
	self._light:set_multiplier(0)

	math.randomseed(self._seed)

	self._light_states = {}
	for i = 1, self.amount do
		if i == 1 then
			table.insert(self._light_states, true)
		elseif math.random() < 0.5 then
			table.insert(self._light_states, not self._light_states[i - 1])
		else
			table.insert(self._light_states, math.random() < 0.5)
		end
	end

	self:start_light()

	self:show_text(managers.localization:to_upper_text("ChaosModifierRedGreenLight"), self.light_time, true)
end

function ChaosModifierRedGreenLight:end_light()
	self._blinking_t = ChaosMod:time()
	self._light_state = nil

	if #self._light_states > 0 then
		self:queue("start_light", self.pause_time)
	end
end

function ChaosModifierRedGreenLight:start_light()
	self._blinking_t = nil
	self._light_state = table.remove(self._light_states, 1)

	self._light:set_color(Vector3(self._light_state and 0 or 1, self._light_state and 1 or 0, 0))

	self:queue("end_light", self.light_time)
end

function ChaosModifierRedGreenLight:update(t, dt)
	local player_unit = managers.player:player_unit()
	if not alive(player_unit) or not alive(self._light) then
		return
	end

	if not self._light:parent() then
		self._light:link(player_unit:orientation_object())
		self._light:set_local_position(Vector3(0, 0, 100))
	end

	self._light:set_multiplier((not self._blinking_t or math.sin((t - self._blinking_t) * 1440) > 0) and 100 or 0)

	if self._light_state == false and player_unit:movement():current_state()._moving and player_unit:character_damage():can_be_tased() then
		player_unit:character_damage():on_non_lethal_electrocution(0.4)
	end
end

function ChaosModifierRedGreenLight:stop()
	self:unqueue("start_light")
	self:unqueue("end_light")

	if alive(self._light) then
		World:delete_light(self._light)
	end
end

return ChaosModifierRedGreenLight
