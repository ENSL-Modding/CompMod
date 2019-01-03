local kTechIdToMaterialOffset = _G[kModName].GetLocalVariable( GetMaterialXYOffset,   "kTechIdToMaterialOffset" )
local additions = _G[kModName].GetTechIdToMaterialOffsetAdditions()

for _,v in ipairs(additions) do
	_G[kModName]:PrintDebug("Adding kTechIdToMaterialOffset for: " .. (EnumToString(kTechId, v[1]) or v[1]), "all")
	kTechIdToMaterialOffset[v[1]] = v[2]
end
