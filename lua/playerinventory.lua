if StreamHeist then
	return
end

function PlayerInventory:_place_selection(selection_index, is_equip, ...)
	local next_update_funcs_index = #_next_update_funcs

	_place_selection_original(self, selection_index, is_equip, ...)

	if is_equip and #_next_update_funcs > next_update_funcs_index then
		local update_func = _next_update_funcs[next_update_funcs_index + 1]
		_next_update_funcs[#_next_update_funcs] = function()
			if self._equipped_selection == selection_index then
				update_func()
			end
		end
	end
end
