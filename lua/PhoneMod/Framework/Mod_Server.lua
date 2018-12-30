ModPrintDebug("Loading Server files", "Server")

for i = 1, #Modules do
	path = FormatDir(Modules[i], "Server")

	local ServerFiles = {}
	Shared.GetMatchingFileNames(path, true, ServerFiles)

	for i = 1, #ServerFiles do
		ModPrintDebug("Loading server file: " .. ServerFiles[i], "Server")
	    Script.Load(ServerFiles[i])
	end
end

ModPrintDebug("Server files loaded.", "Server")

ModPrintVersion("Server")