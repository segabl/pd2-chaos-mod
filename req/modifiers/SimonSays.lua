---@class ChaosModifierSimonSays : ChaosModifier
ChaosModifierSimonSays = class(ChaosModifier)
ChaosModifierSimonSays.class_name = "ChaosModifierSimonSays"
ChaosModifierSimonSays.run_as_client = true
ChaosModifierSimonSays.activity_time = 3
ChaosModifierSimonSays.pause_time = 2
ChaosModifierSimonSays.num_activities = 6
ChaosModifierSimonSays.duration = (ChaosModifierSimonSays.activity_time + ChaosModifierSimonSays.pause_time) * ChaosModifierSimonSays.num_activities
ChaosModifierSimonSays.fixed_duration = true
ChaosModifierSimonSays.activities = {
	{
		name_id = "ChaosModifierSimonSaysJump",
		inverted_name_id = "ChaosModifierSimonSaysJumpInverted",
		func = function(player)
			return player:mover():velocity().z > 0
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
		func = function(player, t)
			local playerstate = player:movement():current_state()
			return playerstate._intimidate_t and playerstate._intimidate_t >= t - tweak_data.player.movement_state.interaction_delay * 0.5
		end
	},
	{
		name_id = "ChaosModifierSimonSaysLookUp",
		inverted_name_id = "ChaosModifierSimonSaysLookUpInverted",
		func = function(player)
			return math.UP:dot(player:movement():detect_look_dir()) > 0.95
		end
	},
	{
		name_id = "ChaosModifierSimonSaysLookDown",
		inverted_name_id = "ChaosModifierSimonSaysLookDownInverted",
		func = function(player)
			return math.UP:dot(player:movement():detect_look_dir()) < -0.95
		end
	}
}

function ChaosModifierSimonSays:start()
	self._activities = {}

	math.randomseed(self._seed)

	for _ = 1, self.num_activities do
		table.insert(self._activities, {
			table.random(self.activities),
			math.random() < 0.5,
			math.random() < 0.5
		})
	end

	self:show_text(managers.localization:to_upper_text("ChaosModifierSimonSaysStart"), self.pause_time, true)

	DelayedCalls:Add(tostring(self), self.pause_time, callback(self, self, "start_activity"))
end

function ChaosModifierSimonSays:start_activity()
	self._activity, self._activity_inverted, self._activity_valid = unpack(table.remove(self._activities))
	self._activity_start_t = TimerManager:game():time()

	local activity_text = managers.localization:to_upper_text(self._activity_inverted and self._activity.inverted_name_id or self._activity.name_id)
	local text = self._activity_valid and managers.localization:to_upper_text("ChaosModifierSimonSaysActivity", { ACTIVITY = activity_text }) or activity_text

	self:show_text(text, self.activity_time)

	DelayedCalls:Add(tostring(self), self.activity_time, callback(self, self, "end_activity"))
end

function ChaosModifierSimonSays:end_activity()
	if self._activity and self._activity_valid ~= self._activity_inverted then
		self:punish()
	end

	self._activity = nil

	if #self._activities > 0 then
		DelayedCalls:Add(tostring(self), self.pause_time, callback(self, self, "start_activity"))
	end
end

function ChaosModifierSimonSays:punish()
	local player_unit = managers.player:local_player()
	if alive(player_unit) and player_unit:character_damage():can_be_tased() then
		player_unit:character_damage():on_non_lethal_electrocution(0.2)
	end
end

function ChaosModifierSimonSays:show_text(text, time, large)
	local panel = managers.hud:panel(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2):panel({
		layer = 100
	})

	local r = panel:rect({
		color = Color.black:with_alpha(0.65)
	})

	local t = panel:text({
		layer = 1,
		text = text,
		font = tweak_data.menu.pd2_large_font,
		font_size = large and 48 or 32
	})

	t:set_shape(t:text_rect())
	t:set_center(panel:w() * 0.5, panel:h() * 0.35)

	if not large then
		r:set_size(panel:w(), t:h() + 32)
		r:set_center(t:center())
	end

	panel:animate(function(o)
		over(0.25, function(p)
			o:set_alpha(p)
		end)
		wait(time - 0.5)
		over(0.25, function(p)
			o:set_alpha(1 - p)
		end)
		o:parent():remove(o)
	end)
end

function ChaosModifierSimonSays:update(t, dt)
	if not self._activity then
		return
	end

	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	if self._activity.func(player_unit, t) then
		if self._activity_valid ~= self._activity_inverted then
			self._activity = nil
		elseif t > self._activity_start_t + 1 then
			self._activity = nil
			DelayedCalls:Add(tostring(self) .. "punish", 0.2, callback(self, self, "punish"))
		end
	end
end

return ChaosModifierSimonSays
