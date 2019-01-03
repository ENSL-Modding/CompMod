_G[kModName]:PrintDebug("Loading Client files", "Client")

for i = 1, #_G[kModName].config.modules do
	local path = _G[kModName]:FormatDir(_G[kModName].config.modules[i], "Client")

	local ClientFiles = {}
	Shared.GetMatchingFileNames(path, true, ClientFiles)

	for i = 1, #ClientFiles do
		_G[kModName]:PrintDebug("Loading client file: " .. ClientFiles[i], "Client")
	  	Script.Load(ClientFiles[i])
	end
end

_G[kModName]:PrintDebug("Client files loaded.", "Client")

_G[kModName]:PrintVersion("Client")
