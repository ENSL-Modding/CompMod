-- an odd way to get the mod name
-- but this is dumb and it hurts my brain theres gotta be a better way scoob

kModName = string.match(Script.CallStack(), "lua/.*/Framework/Mod_Shared.lua"):gsub("lua/", ""):gsub("/Framework/Mod_Shared.lua", "")

Script.Load("lua/Class.lua")
Script.Load("lua/" .. kModName .. "/Framework/Framework.lua")

_G[kModName]:PrintDebug("Loading NewTech files", "all")
for i = 1, #_G[kModName].config.modules do
	local path = _G[kModName]:FormatDir(_G[kModName].config.modules[i], "NewTech")

	local NewTechFiles = {}
	Shared.GetMatchingFileNames(path, true, NewTechFiles)

	for i = 1, #NewTechFiles do
		_G[kModName]:PrintDebug("Loading new tech file: " .. NewTechFiles[i], "all")
	  	Script.Load(NewTechFiles[i])
	end
end

_G[kModName]:PrintDebug("NewTech files loaded.", "all")

_G[kModName]:PrintDebug("Loading Shared files", "all")

for i = 1, #_G[kModName].config.modules do
	local path = _G[kModName]:FormatDir(_G[kModName].config.modules[i], "Shared")

	local SharedFiles = {}
	Shared.GetMatchingFileNames(path, true, SharedFiles)

	for i = 1, #SharedFiles do
		_G[kModName]:PrintDebug("Loading shared file: " .. SharedFiles[i], "all")
	  	Script.Load(SharedFiles[i])
	end
end

_G[kModName]:PrintDebug("Shared files loaded.", "all")
