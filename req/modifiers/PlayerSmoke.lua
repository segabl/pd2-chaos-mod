ChaosModifierPlayerSmoke = ChaosModifier.class("ChaosModifierPlayerSmoke")
ChaosModifierPlayerSmoke.duration = 45

function ChaosModifierPlayerSmoke:can_trigger()
	return table.size(managers.groupai:state():all_player_criminals()) > 0
end

function ChaosModifierPlayerSmoke:update(t, dt)
	local player_unit = managers.player:local_player()
	if not alive(player_unit) then
		if self._effect then
			World:effect_manager():fade_kill(self._effect)
			self._effect = nil
		end
	elseif not self._effect then
		self._effect = World:effect_manager():spawn({
			effect = Idstring("effects/particles/explosions/smoke_grenade_smoke"),
			parent = player_unit:orientation_object()
		})
	end
end

function ChaosModifierPlayerSmoke:stop()
	if self._effect then
		World:effect_manager():fade_kill(self._effect)
	end
end

return ChaosModifierPlayerSmoke
