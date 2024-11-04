ChaosModifierSimonSays = ChaosModifier.class("ChaosModifierSimonSays")
ChaosModifierSimonSays.register_name = "ChaosModifierPlayerMovement"
ChaosModifierSimonSays.activity_time = 3
ChaosModifierSimonSays.pause_time = 2
ChaosModifierSimonSays.num_activities = 6
ChaosModifierSimonSays.duration = 1 + (ChaosModifierSimonSays.activity_time + ChaosModifierSimonSays.pause_time) * ChaosModifierSimonSays.num_activities
ChaosModifierSimonSays.fixed_duration = true
ChaosModifierSimonSays.activities = {
	{
		name_id = "ChaosModifierSimonSaysJump",
		inverted_name_id = "ChaosModifierSimonSaysJumpInverted",
		func = function(player)
			return player:mover() and player:mover():velocity().z > 0
		end
	},
	{
		name_id = "ChaosModifierSimonSaysSprint",
		inverted_name_id = "ChaosModifierSimonSaysSprintInverted",
		func = function(player)
			return player:movement():running()
		end
	},
	{
		name_id = "ChaosModifierSimonSaysCrouch",
		inverted_name_id = "ChaosModifierSimonSaysCrouchInverted",
		func = function(player)
			return player:movement():crouching()
		end
	},
	{
		name_id = "ChaosModifierSimonSaysReload",
		inverted_name_id = "ChaosModifierSimonSaysReloadInverted",
		func = function(player)
			return player:movement():current_state():_is_reloading()
		end
	},
	{
		name_id = "ChaosModifierSimonSaysMelee",
		inverted_name_id = "ChaosModifierSimonSaysMeleeInverted",
		func = function(player)
			return player:movement():current_state():_is_meleeing()
		end
	},
	{
		name_id = "ChaosModifierSimonSaysInspectWeapon",
		inverted_name_id = "ChaosModifierSimonSaysInspectWeaponInverted",
		func = function(player)
			return player:movement():current_state():_is_cash_inspecting()
		end
	},
	{
		name_id = "ChaosModifierSimonSaysAimDownSights",
		inverted_name_id = "ChaosModifierSimonSaysAimDownSightsInverted",
		func = function(player)
			return player:movement():current_state():in_steelsight()
		end
	},
	{
		name_id = "ChaosModifierSimonSaysShout",
		inverted_name_id = "ChaosModifierSimonSaysShoutInverted",
		func = function(player)
			local playerstate = player:movement():current_state()
			return playerstate._intimidate_t and playerstate._intimidate_t >= TimerManager:game():time() - tweak_data.player.movement_state.interaction_delay * 0.5
		end
	},
	{
		name_id = "ChaosModifierSimonSaysLookUp",
		inverted_name_id = "ChaosModifierSimonSaysLookUpInverted",
		func = function(player)
			return math.UP:dot(player:movement():detect_look_dir()) > 0.9
		end
	},
	{
		name_id = "ChaosModifierSimonSaysLookDown",
		inverted_name_id = "ChaosModifierSimonSaysLookDownInverted",
		func = function(player)
			return math.UP:dot(player:movement():detect_look_dir()) < -0.9
		end
	}
}

function ChaosModifierSimonSays:start()
	self._activities = {}

	math.randomseed(self._seed)

	for i = 1, self.num_activities do
		table.insert(self._activities, {
			table.random(self.activities),
			math.random() < 0.5,
			i == self.num_activities or math.random() < 0.5
		})
	end

	self:show_text(managers.localization:to_upper_text("ChaosModifierSimonSaysStart"), self.pause_time, true)

	self:queue("start_activity", self.pause_time)
end

function ChaosModifierSimonSays:start_activity()
	self._activity, self._activity_inverted, self._activity_valid = unpack(table.remove(self._activities))
	self._activity_start_t = ChaosMod:time()

	local activity_text = managers.localization:to_upper_text(self._activity_inverted and self._activity.inverted_name_id or self._activity.name_id)
	local text = self._activity_valid and managers.localization:to_upper_text("ChaosModifierSimonSaysActivity", { ACTIVITY = activity_text }) or activity_text

	self:show_text(text, self.activity_time)

	self:queue("end_activity", self.activity_time)
end

function ChaosModifierSimonSays:end_activity()
	if self._activity and self._activity_valid ~= self._activity_inverted then
		self:punish()
	end

	self._activity = nil

	if #self._activities > 0 then
		self:queue("start_activity", self.pause_time)
	end
end

function ChaosModifierSimonSays:punish()
	local player_unit = managers.player:local_player()
	if alive(player_unit) and player_unit:character_damage():can_be_tased() then
		player_unit:character_damage():on_non_lethal_electrocution(0.2)
	end
end

function ChaosModifierSimonSays:update(t, dt)
	if not self._activity then
		return
	end

	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	if self._activity.func(player_unit) then
		if self._activity_valid ~= self._activity_inverted then
			self._activity = nil
		elseif t > self._activity_start_t + 0.75 then
			self._activity = nil
			self:queue("punish", 0.2)
		end
	end
end

return ChaosModifierSimonSays
