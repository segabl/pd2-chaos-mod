ChaosModifierHealthArmorLink = ChaosModifier.class("ChaosModifierHealthArmorLink")
ChaosModifierHealthArmorLink.loud_only = true
ChaosModifierHealthArmorLink.duration = 90

function ChaosModifierHealthArmorLink:can_trigger()
	return table.size(managers.groupai:state():all_player_criminals()) > 1
end

function ChaosModifierHealthArmorLink:start()
	self._override_colors = {}

	local function send_data(playerdamage)
		if playerdamage._unit ~= managers.player:local_player() or playerdamage:is_downed() or self._is_synced_change then
			return
		end
		local data = (playerdamage:_max_armor() > 0 and playerdamage:armor_ratio() or -1) .. "|" .. (playerdamage:health_ratio() / playerdamage._max_health_reduction)
		NetworkHelper:SendToPeers(self.class_name, data)
	end

	self:override(PlayerDamage, "set_health", function(playerdamage, health, ...)
		local prev_ratio = playerdamage:health_ratio()
		local result = self:get_override(PlayerDamage, "set_health")(playerdamage, health, ...)
		if prev_ratio ~= playerdamage:health_ratio() then
			send_data(playerdamage)
		end
		return result
	end)

	self:override(PlayerDamage, "set_armor", function(playerdamage, armor, ...)
		local prev_ratio = playerdamage:armor_ratio()
		local result = self:get_override(PlayerDamage, "set_armor")(playerdamage, armor, ...)
		if prev_ratio ~= playerdamage:armor_ratio() then
			send_data(playerdamage)
		end
		return result
	end)

	self:override(HUDHitDirection, "_get_indicator_color", function(hitdirection, damage_type, ...)
		if self._override_colors[damage_type] then
			return self._override_colors[damage_type]
		end
		return self:get_override(HUDHitDirection, "_get_indicator_color")(hitdirection, damage_type, ...)
	end)

	NetworkHelper:AddReceiveHook(self.class_name, self.class_name, callback(self, self, "on_data_received"))
end

function ChaosModifierHealthArmorLink:stop()
	NetworkHelper:RemoveReceiveHook(self.class_name)
end

function ChaosModifierHealthArmorLink:on_data_received(data, sender)
	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		return
	end

	local char_dmg = player_unit:character_damage()
	local my_armor_ratio, my_health_ratio = char_dmg:armor_ratio(), char_dmg:health_ratio()
	local armor_ratio, health_ratio = unpack(data:split("|"))

	armor_ratio = tonumber(armor_ratio)
	health_ratio = tonumber(health_ratio)

	if not armor_ratio or not health_ratio then
		return
	end

	health_ratio = health_ratio * char_dmg._max_health_reduction
	if health_ratio <= 0 then
		char_dmg._can_take_dmg_timer = math.max(char_dmg._can_take_dmg_timer, 4)
	end

	self._is_synced_change = true

	local show_hit = false

	if armor_ratio >= 0 and char_dmg:_max_armor() > 0 and math.abs(my_armor_ratio - armor_ratio) > 0.01 then
		if my_armor_ratio > armor_ratio then
			char_dmg._unit:sound():play("player_hit")
			char_dmg._listener_holder:call("on_damage")
			show_hit = true
		end

		char_dmg:set_armor(char_dmg:_max_armor() * armor_ratio)
		char_dmg:_send_set_armor()
	end

	if health_ratio >= 0 and math.abs(my_health_ratio - health_ratio) > 0.01 then
		if my_health_ratio > health_ratio then
			player_unit:sound():play("player_hit_permadamage")
			show_hit = true
		end

		char_dmg:set_health(char_dmg:_max_health() * health_ratio)
	end

	if show_hit then
		local color_index = 1000 + sender
		self._override_colors[color_index] = tweak_data.chat_colors[sender]

		local peer = managers.network:session():peer(sender)
		local peer_unit = peer and peer:unit()
		if alive(peer_unit) then
			managers.hud:on_hit_direction(peer_unit:position(), color_index)
		end
	end

	self._is_synced_change = false
end

return ChaosModifierHealthArmorLink
