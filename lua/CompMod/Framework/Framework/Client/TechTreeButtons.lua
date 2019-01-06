local kTechIdToMaterialOffset = Mod:GetLocalVariable( GetMaterialXYOffset,   "kTechIdToMaterialOffset" )
local additions = Mod:GetTechIdToMaterialOffsetAdditions()

for _,v in ipairs(additions) do
	Mod:PrintDebug("Adding kTechIdToMaterialOffset for: " .. (EnumToString(kTechId, v[1]) or v[1]), "all")
	kTechIdToMaterialOffset[v[1]] = v[2]
end
