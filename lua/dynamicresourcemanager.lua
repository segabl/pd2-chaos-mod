Hooks:PostHook(DynamicResourceManager, "preload_units", "preload_units_chaos", function (self)
	local unit_ids = Idstring("unit")
	for _, unit_name in pairs(tweak_data.character.weap_unit_names) do
		if not PackageManager:has(unit_ids, unit_name) then
			self:load(unit_ids, unit_name, self.DYN_RESOURCES_PACKAGE)
		end
	end
end)
