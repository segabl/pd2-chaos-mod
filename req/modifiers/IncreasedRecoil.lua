ChaosModifierIncreasedRecoil = ChaosModifier.class("ChaosModifierIncreasedRecoil")
ChaosModifierIncreasedRecoil.run_as_client = true
ChaosModifierIncreasedRecoil.duration = 30

function ChaosModifierIncreasedRecoil:start()
	self:post_hook(FPCameraPlayerBase, "stop_shooting", function(fpcamerabase)
		fpcamerabase._recoil_kick.to_reduce = fpcamerabase._recoil_kick.last
		fpcamerabase._recoil_kick.h.to_reduce = fpcamerabase._recoil_kick.h.last
	end)

	self:override(FPCameraPlayerBase, "recoil_kick", function(fpcamerabase, up, down, left, right)
		local v = math.lerp(up, down, math.random()) * 5
		fpcamerabase._recoil_kick.accumulated = (fpcamerabase._recoil_kick.accumulated or 0) + v
		fpcamerabase._recoil_kick.last = v
		local h = math.lerp(left, right, math.random()) * 5
		fpcamerabase._recoil_kick.h.accumulated = (fpcamerabase._recoil_kick.h.accumulated or 0) + h
		fpcamerabase._recoil_kick.h.last = h
	end)

	self:override(FPCameraPlayerBase, "_vertical_recoil_kick", function(fpcamerabase, t, dt)
		if managers.player:current_state() == "bipod" then
			fpcamerabase:break_recoil()
			return 0
		end

		local r_value = 0
		if fpcamerabase._recoil_kick.current and fpcamerabase._episilon < fpcamerabase._recoil_kick.accumulated - fpcamerabase._recoil_kick.current then
			local n = math.min(fpcamerabase._recoil_kick.accumulated, math.step(fpcamerabase._recoil_kick.current, fpcamerabase._recoil_kick.accumulated, 200 * dt))
			r_value = n - fpcamerabase._recoil_kick.current
			fpcamerabase._recoil_kick.current = n
		elseif fpcamerabase._recoil_kick.to_reduce then
			fpcamerabase._recoil_kick.current = nil
			local n = math.lerp(fpcamerabase._recoil_kick.to_reduce, 0, 3 * dt)
			r_value = -(fpcamerabase._recoil_kick.to_reduce - n)
			fpcamerabase._recoil_kick.to_reduce = n
			if fpcamerabase._recoil_kick.to_reduce == 0 then
				fpcamerabase._recoil_kick.to_reduce = nil
			end
		end

		return r_value
	end)

	self:override(FPCameraPlayerBase, "_horizonatal_recoil_kick", function(fpcamerabase, t, dt)
		if managers.player:current_state() == "bipod" then
			return 0
		end

		local r_value = 0
		if fpcamerabase._recoil_kick.h.current and fpcamerabase._episilon < math.abs(fpcamerabase._recoil_kick.h.accumulated - fpcamerabase._recoil_kick.h.current) then
			local n = math.min(fpcamerabase._recoil_kick.h.accumulated, math.step(fpcamerabase._recoil_kick.h.current, fpcamerabase._recoil_kick.h.accumulated, 200 * dt))
			r_value = n - fpcamerabase._recoil_kick.h.current
			fpcamerabase._recoil_kick.h.current = n
		elseif fpcamerabase._recoil_kick.h.to_reduce then
			fpcamerabase._recoil_kick.h.current = nil
			local n = math.lerp(fpcamerabase._recoil_kick.h.to_reduce, 0, 2 * dt)
			r_value = -(fpcamerabase._recoil_kick.h.to_reduce - n)
			fpcamerabase._recoil_kick.h.to_reduce = n
			if fpcamerabase._recoil_kick.h.to_reduce == 0 then
				fpcamerabase._recoil_kick.h.to_reduce = nil
			end
		end

		return r_value
	end)
end

return ChaosModifierIncreasedRecoil
