local Mod = GetMod()
local sent = false

local function CheckClientEntry()
	if sent then return end

	local clientEntry = {}

	Shared.GetMatchingFileNames("lua/entry/*", true, clientEntry)

	Client.SendNetworkMessage(Mod.config.kModName .. "_EntryCheck", {count = #clientEntry}, true)

	sent = true
end

-- using clientconnected makes the engine implode, so lets check every tick :D
Event.Hook("UpdateClient", CheckClientEntry)
