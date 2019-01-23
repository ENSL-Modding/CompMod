local Mod = GetMod()

Shared.RegisterNetworkMessage(Mod.config.kModName .. "_EntryCheck", {
  count = "integer",
})
