ChaosModifierDozerSpecials = ChaosModifier.class("ChaosModifierDozerSpecials")
ChaosModifierDozerSpecials.tags = { "UnitCategories" }
ChaosModifierDozerSpecials.conflict_tags = { "UnitCategories" }
ChaosModifierDozerSpecials.loud_only = true
ChaosModifierDozerSpecials.color = "enemy_change"
ChaosModifierDozerSpecials.duration = 45

function ChaosModifierDozerSpecials:start()
	for _, enemy_name in pairs(tweak_data.character._enemy_list) do
		local enemy = tweak_data.character[enemy_name]
		if enemy and enemy.tags and table.contains(enemy.tags, "special") then
			self:override(enemy, "modify_health_on_tweak_change", nil)
			self:override(enemy, "tmp_invulnerable_on_tweak_change", nil)
			self:override(enemy, "allowed_poses", { stand = true })
		end
	end

	self:post_hook(CopSound, "init", function(copsound)
		if copsound._unit:base().add_tweak_data_changed_listener then
			copsound._unit:base():add_tweak_data_changed_listener("CopSoundTweakDataChange" .. tostring(copsound._unit:key()), function()
				copsound:set_voice_prefix()
			end)
		end
	end)

	self:post_hook(ElementSpawnEnemyDummy, "produce", function(element, params, ...)
		local unit = Hooks:GetReturn()
		if self._replacing_unit or not unit or unit:base():has_tag("tank") or not unit:base():has_tag("special") then
			return
		end

		local weapon_name = unit:base():default_weapon_name()
		local tweak_table = unit:base()._tweak_table

		unit:set_slot(0)

		local enemy_name = element._enemy_name
		local new_enemy_name = "units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"
		if unit:base():has_tag("taser") then
			new_enemy_name = "units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"
		elseif unit:base():has_tag("spooc") then
			new_enemy_name = "units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"
		elseif unit:base():has_tag("medic") then
			new_enemy_name = "units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"
		elseif unit:base():has_tag("shield") then
			new_enemy_name = "units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun"
		end

		if params and params.name then
			params.name = new_enemy_name
		else
			element._enemy_name = Idstring(new_enemy_name)
		end
		element._replacing_unit = true

		unit = element:produce(params, ...)

		element._enemy_name = enemy_name
		element._replacing_unit = false

		unit:base():change_char_tweak(tweak_table)
		unit:network():send("sync_change_char_tweak", tweak_table)
		unit:inventory():add_unit_by_name(weapon_name, true)

		return unit
	end)
end

return ChaosModifierDozerSpecials
