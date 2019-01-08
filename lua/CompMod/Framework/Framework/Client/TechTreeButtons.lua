local kModName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")
local Mod = _G[kModName]

local kTechIdToMaterialOffset = Mod:GetLocalVariable( GetMaterialXYOffset,   "kTechIdToMaterialOffset" )
local additions = Mod:GetTechIdToMaterialOffsetAdditions()

for _,v in ipairs(additions) do
	Mod:PrintDebug("Adding kTechIdToMaterialOffset for: " .. (EnumToString(kTechId, v[1]) or v[1]), "all")
	kTechIdToMaterialOffset[v[1]] = v[2]
end
