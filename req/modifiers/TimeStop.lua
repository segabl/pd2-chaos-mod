ChaosModifierTimeStop = ChaosModifier.class("ChaosModifierTimeStop")
ChaosModifierTimeStop.register_name = "ChaosModifierTimeSpeed"
ChaosModifierTimeStop.duration = 15
ChaosModifierTimeStop.weight_mul = 0.75

function ChaosModifierTimeStop:start()
	TimerManager:game():set_multiplier(0)
	TimerManager:game_animation():set_multiplier(0)

	local player_timer = managers.player:player_timer()
	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if data.unit ~= managers.player:local_player() then
			data.unit:set_timer(player_timer)
			data.unit:set_animation_timer(player_timer)
		end
	end

	for _, data in pairs(managers.enemy:all_enemies()) do
		if alive(data.unit:inventory():equipped_unit()) then
			data.unit:inventory():equipped_unit():base():stop_autofire()
		end
		local upper_action = data.unit:movement():get_action(3)
		if upper_action then
			upper_action._autofiring = nil
		end
		local full_action = data.unit:movement():get_action(1)
		if full_action then
			full_action._shooting_hurt = nil
		end
	end

	self._damage_queue = {}

	local function on_collision(bullet, col_ray, ...)
		table.insert(self._damage_queue, {
			unit = col_ray.unit,
			obj = bullet,
			func = "on_collision",
			params = { col_ray, ... }
		})
	end
	self:override(DOTBulletBase, "on_collision", on_collision)
	self:override(FlameBulletBase, "on_collision", on_collision)
	self:override(InstantBulletBase, "on_collision", on_collision)
	self:override(InstantExplosiveBulletBase, "on_collision", on_collision)
	self:override(ProjectilesPoisonBulletBase, "on_collision", on_collision)

	local function damage_melee(dmg, ...)
		table.insert(self._damage_queue, {
			unit = dmg._unit,
			obj = dmg,
			func = "damage_melee",
			params = { ... }
		})
	end
	self:override(CopDamage, "damage_melee", damage_melee)
	self:override(CivilianDamage, "damage_melee", damage_melee)

	local function empty() end
	self:override(CopMovement, "update", empty)
	self:override(GrenadeBase, "update", empty)
	self:override(M79GrenadeBase, "update", empty)
	self:override(PoisonGasGrenade, "update", empty)
	self:override(ProjectileBase, "update", empty)
	self:override(QuickCsGrenade, "update", empty)
	self:override(QuickFlashGrenade, "update", empty)
	self:override(QuickSmokeGrenade, "update", empty)
	self:override(ShieldFlashBase, "update", empty)
	self:override(SmokeGrenade, "update", empty)
	self:override(SmokeScreenGrenade, "update", empty)
	self:override(TearGasGrenade, "update", empty)

	self:override(PlayerStandard, "_start_action_intimidate", empty)

	self:override(ProjectileBase, "check_time_cheat", function() return true end)

	self:override(tweak_data.network.camera, "network_sync_delta_t", 0)
end

function ChaosModifierTimeStop:stop()
	TimerManager:game():set_multiplier(1)
	TimerManager:game_animation():set_multiplier(1)

	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if data.unit ~= managers.player:local_player() then
			data.unit:set_timer(TimerManager:game())
			data.unit:set_animation_timer(TimerManager:game_animation())
		end
	end

	for _, v in pairs(self._damage_queue) do
		if alive(v.unit) then
			v.obj[v.func](v.obj, unpack(v.params))
		end
	end
end

return ChaosModifierTimeStop
