local kModName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")

Script.Load("lua/" .. kModName .. "/Framework/Framework.lua")

local Mod = _G[kModName]

Mod:PrintDebug("Setting up file hooks", "all")

for i = 1, #Mod.config.modules do
	local currentModule = Mod.config.modules[i]
	local types = { "Halt", "Post", "Pre", "Replace" }

	for j = 1, #types do
		local hookType = types[j]
		local path = Mod:FormatDir(currentModule, hookType)
		local files = {}

		Shared.GetMatchingFileNames(path, true, files)

		for k = 1, #files do
			local file = files[k]
			local vpath = file:gsub(kModName .. "/.*/" .. hookType .. "/", "")

			Mod:PrintDebug(string.format("Hooking file: %s, Vanilla Path: %s, Method: %s", file, vpath, hookType), "all")
			ModLoader.SetupFileHook(vpath, file, hookType:lower())
		end
	end
end

Mod:PrintDebug("File hooks complete", "all")
