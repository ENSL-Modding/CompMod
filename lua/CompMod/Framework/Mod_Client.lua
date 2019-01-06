Mod:PrintDebug("Loading Client files", "Client")

for i = 1, #Mod.config.modules do
	local path = Mod:FormatDir(Mod.config.modules[i], "Client")

	local ClientFiles = {}
	Shared.GetMatchingFileNames(path, true, ClientFiles)

	for i = 1, #ClientFiles do
		Mod:PrintDebug("Loading client file: " .. ClientFiles[i], "Client")
	  	Script.Load(ClientFiles[i])
	end
end

Mod:PrintDebug("Client files loaded.", "Client")

Mod:PrintVersion("Client")
