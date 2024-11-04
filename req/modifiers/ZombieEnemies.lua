ChaosModifierZombieEnemies = ChaosModifier.class("ChaosModifierZombieEnemies")
ChaosModifierZombieEnemies.run_as_client = false
ChaosModifierZombieEnemies.duration = 45

function ChaosModifierZombieEnemies:start()
	self:pre_hook(CopDamage, "_on_death", function(copdamage)
		if math.random() < 0.45 then
			return
		end
		local unit_name = copdamage._unit:name()
		local pos = copdamage._unit:position()
		local rot = copdamage._unit:rotation()
		local team = copdamage._unit:movement():team()
		DelayedCalls:Add(tostring(copdamage._unit:key()) .. "respawn", math.rand(0.5, 2), function()
			self:spawn(unit_name, pos, rot, team)
		end)
	end)
end

function ChaosModifierZombieEnemies:spawn(unit_name, pos, rot, team)
	local unit = World:spawn_unit(unit_name, pos, rot)
	unit:movement():set_team(team)
	unit:brain():set_spawn_ai({
		init_state = "idle",
		stance = "cbt",
		objective = {
			type = "act",
			action = {
				align_sync = true,
				type = "act",
				body_part = 1,
				variant = "e_sp_uno_ground",
				blocks = {
					heavy_hurt = -1,
					hurt = -1,
					action = -1,
					walk = -1
				}
			}
		},
		params = {
			scan = true
		}
	})
	unit:character_damage():set_invulnerable(true)
	unit:network():send("set_unit_invulnerable", true, false)
	DelayedCalls:Add(tostring(unit:key()) .. "invulnerable", 1.5, function()
		if alive(unit) then
			unit:character_damage():set_invulnerable(false)
			unit:network():send("set_unit_invulnerable", false, false)
		end
	end)
end

return ChaosModifierZombieEnemies
