local Mod = GetMod()
local serverEntryCount = 0
local clientEntryCount = 0

local function CompareEntries(client)
  assert(Server)
  assert(serverEntryCount > 0)
  
  if clientEntryCount <= 0 then
    Server.DisconnectClient(client, "Malformed entry count")
  elseif serverEntryCount ~= clientEntryCount then
    Server.DisconnectClient(client, "Entry file count mismatch")
  end
end

local function CheckServerEntry(client)
  local serverEntry = {}
  Shared.GetMatchingFileNames("lua/entry/*", true, serverEntry)
  serverEntryCount = #serverEntry
end

local function OnReceiveClientEntryCheck(client, message)
  clientEntryCount = message.count
  CompareEntries(client)
end

Event.Hook("ClientConnect", CheckServerEntry)
Server.HookNetworkMessage(Mod.config.kModName .. "_EntryCheck", OnReceiveClientEntryCheck)
