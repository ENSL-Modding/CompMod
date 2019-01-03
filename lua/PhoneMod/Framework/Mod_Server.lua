_G[kModName]:PrintDebug("Loading Server files", "Server")

for i = 1, #_G[kModName].config.modules do
	local path = _G[kModName]:FormatDir(_G[kModName].config.modules[i], "Server")

	local ServerFiles = {}
	Shared.GetMatchingFileNames(path, true, ServerFiles)

	for i = 1, #ServerFiles do
		_G[kModName]:PrintDebug("Loading server file: " .. ServerFiles[i], "Server")
	  	Script.Load(ServerFiles[i])
	end
end

_G[kModName]:PrintDebug("Server files loaded.", "Server")

_G[kModName]:PrintVersion("Server")
