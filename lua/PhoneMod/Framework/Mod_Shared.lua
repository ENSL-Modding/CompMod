-- an odd way to get the mod name
-- but this is dumb and it hurts my brain theres gotta be a better way scoob

kModName = string.match(Script.CallStack(), "lua/.*/Framework/Mod_Shared.lua"):gsub("lua/", ""):gsub("/Framework/Mod_Shared.lua", "")

Script.Load("lua/Class.lua")
Script.Load("lua/" .. kModName .. "/Framework/SharedFuncs.lua")

ModPrintDebug("Loading NewTech files", "all")
for i = 1, #Modules do
	local path = FormatDir(Modules[i], "NewTech")

	local NewTechFiles = {}
	Shared.GetMatchingFileNames(path, true, NewTechFiles)

	for i = 1, #NewTechFiles do
		ModPrintDebug("Loading new tech file: " .. NewTechFiles[i], "all")
	  Script.Load(NewTechFiles[i])
	end
end

ModPrintDebug("NewTech files loaded.", "all")

ModPrintDebug("Loading Shared files", "all")

for i = 1, #Modules do
	local path = FormatDir(Modules[i], "Shared")

	local SharedFiles = {}
	Shared.GetMatchingFileNames(path, true, SharedFiles)

	for i = 1, #SharedFiles do
		ModPrintDebug("Loading shared file: " .. SharedFiles[i], "all")
	  Script.Load(SharedFiles[i])
	end
end

ModPrintDebug("Shared files loaded.", "all")
