ChaosModifierSlowOnHit = ChaosModifier.class("ChaosModifierSlowOnHit")
ChaosModifierSlowOnHit.loud_only = true
ChaosModifierSlowOnHit.duration = 60

function ChaosModifierSlowOnHit:start()
	local slows = {}
	local dmg_ref = tweak_data.character.fbi_swat.weapon.is_rifle.FALLOFF[1].dmg_mul * tweak_data.weapon.m4_npc.DAMAGE

	self:post_hook(PlayerDamage, "_calc_armor_damage", function(playerdamage, attack_data)
		local strength = attack_data.damage ^ 0.35
		table.insert(slows, 1, {
			start_t = managers.player:player_timer():time(),
			expire_t = managers.player:player_timer():time() + math.map_range_clamped(strength, 0, dmg_ref * 4, 0, 0.5)
		})
	end)

	self:post_hook(PlayerStandard, "_get_max_walk_speed", function()
		local t = managers.player:player_timer():time()
		local speed_mul = 1
		for i, slow in table.reverse_ipairs(slows) do
			if t > slow.expire_t then
				table.remove(slows, i)
			else
				speed_mul = speed_mul * math.map_range(t, slow.start_t, slow.expire_t, 0, 1)
			end
		end
		return Hooks:GetReturn() * speed_mul
	end)
end

return ChaosModifierSlowOnHit
