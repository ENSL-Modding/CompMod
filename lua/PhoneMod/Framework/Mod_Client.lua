ModPrintDebug("Loading Client files", "Client")

for i = 1, #Modules do
	path = FormatDir(Modules[i], "Client")

	local ClientFiles = {}
	Shared.GetMatchingFileNames(path, true, ClientFiles)

	for i = 1, #ClientFiles do
		ModPrintDebug("Loading client file: " .. ClientFiles[i], "Client")
	    Script.Load(ClientFiles[i])
	end
end

ModPrintDebug("Client files loaded.", "Client")

ModPrintVersion("Client")