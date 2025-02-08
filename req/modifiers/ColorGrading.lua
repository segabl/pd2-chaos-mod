ChaosModifierColorGrading = ChaosModifier.class("ChaosModifierColorGrading")
ChaosModifierColorGrading.register_name = "ChaosModifierScreenEffect"
ChaosModifierColorGrading.duration = 60

function ChaosModifierColorGrading:start()
	self:override(MenuCallbackHandler, "choice_choose_color_grading", function()end)
	self:change()
end

function ChaosModifierColorGrading:change()
	if not managers.environment_controller then
		self:queue("change", 1)
		return
	end

	local old_index = self._index
	repeat
		self._index = math.random(3, #tweak_data.color_grading)
	until self._index ~= old_index or #tweak_data.color_grading < 4

	local color_grading = tweak_data.color_grading[self._index].value
	managers.environment_controller._vp:vp():set_post_processor_effect("World", Idstring("color_grading_post"), Idstring(color_grading))

	self:queue("change", 10)
end

function ChaosModifierColorGrading:stop()
	self:unqueue("change")

	if managers.environment_controller then
		managers.environment_controller:refresh_render_settings()
	end
end

return ChaosModifierColorGrading
