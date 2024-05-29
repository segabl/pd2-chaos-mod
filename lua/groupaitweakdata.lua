Hooks:PostHook(GroupAITweakData, "init", "init_chaos_mod", function(self)
	local FBI_suit_C45_M4 = self.unit_categories.FBI_suit_C45_M4.unit_types
	if FBI_suit_C45_M4.murkywater[2] == Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_2") then
		FBI_suit_C45_M4.murkywater[2] = FBI_suit_C45_M4.america[2]
	end
	if FBI_suit_C45_M4.federales[2] == Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_2") then
		FBI_suit_C45_M4.federales[2] = FBI_suit_C45_M4.america[2]
	end

	local FBI_suit_M4_MP5 = self.unit_categories.FBI_suit_M4_MP5.unit_types
	if FBI_suit_M4_MP5.murkywater[2] == Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_3") then
		FBI_suit_M4_MP5.murkywater[2] = FBI_suit_M4_MP5.america[2]
	end
	if FBI_suit_M4_MP5.federales[1] == Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_2") then
		FBI_suit_M4_MP5.federales[1] = FBI_suit_M4_MP5.america[1]
	end
	if FBI_suit_M4_MP5.federales[2] == Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_3") then
		FBI_suit_M4_MP5.federales[2] = FBI_suit_M4_MP5.america[2]
	end
end)
