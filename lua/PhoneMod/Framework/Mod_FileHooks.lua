-- an odd way to get the mod name
-- but this is dumb and it hurts my brain theres gotta be a better way scoob

kModName = string.match(Script.CallStack(), "lua/.*/Framework/Mod_FileHooks.lua"):gsub("lua/", ""):gsub("/Framework/Mod_FileHooks.lua", "")

Script.Load("lua/" .. kModName .. "/Framework/SharedFuncs.lua")

ModPrintDebug("Setting up file hooks", "all")

for i = 1, #Modules do
	local currentModule = Modules[i]
	local types = { "Halt", "Post", "Pre", "Replace" }

	for j = 1, #types do
		local hookType = types[j]
		local path = FormatDir(currentModule, hookType)
		local files = {}

		Shared.GetMatchingFileNames(path, true, files)

		for k = 1, #files do
			local file = files[k]
			local vpath = file:gsub(kModName .. "/.*/" .. hookType .. "/", "")

			ModPrintDebug(string.format("Hooking file: %s, Vanilla Path: %s, Method: %s", file, vpath, hookType), "all")
			ModLoader.SetupFileHook(vpath, file, hookType:lower())
		end
	end
end

ModPrintDebug("File hooks complete", "all")
