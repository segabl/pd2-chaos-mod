ChaosModifierBostonBasher = ChaosModifier.class("ChaosModifierBostonBasher")
ChaosModifierBostonBasher.duration = 30

function ChaosModifierBostonBasher:start()
	self._brush = Draw:brush(Color(1, 0.1, 0), 0.05, "VertexColor")
	self._brush:set_blend_mode("add")

	self:show_text(managers.localization:to_upper_text("ChaosModifierBostonBasher"), 2, true)
	self:queue("setup", 2)
end

function ChaosModifierBostonBasher:setup()
	self:post_hook(RaycastWeaponBase, "fire", function(weaponbase, from_pos, direction, dmg_mul)
		if not weaponbase._setup.user_unit or weaponbase._setup.user_unit ~= managers.player:player_unit() or weaponbase._projectile_type then
			return
		end

		local ray_res = Hooks:GetReturn()
		local missed = true
		local rays = ray_res and ray_res.rays or {}
		for _, ray in pairs(rays) do
			if alive(ray.unit) and ray.unit:character_damage() then
				missed = false
				break
			end
		end

		if missed then
			self:damage_player(weaponbase:_get_current_damage(dmg_mul), rays[1] and rays[1].hit_position)
		end
	end)
end

function ChaosModifierBostonBasher:damage_player(damage, from_pos)
	local unit = managers.player:player_unit()
	if not alive(unit) then
		return
	end

	local pos = unit:camera():position()
	local rot = unit:camera():rotation()
	local from = from_pos or pos + rot:y() * 10000
	local to = pos + rot:x() * math.rand(-40, 40) + rot:z() * math.rand(-20, 20) + rot:y() * 30
	self._brush:cylinder(from, to, 1)

	unit:character_damage():delay_damage((damage ^ 0.75) * 0.5, 4)
	unit:character_damage():_hit_direction(to, from - to)
end

return ChaosModifierBostonBasher
