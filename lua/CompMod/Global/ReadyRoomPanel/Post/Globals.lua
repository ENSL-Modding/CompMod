if AddModPanel then
  local changelogURL = "https://github.com/adsfgg/CompMod/wiki"
  local compmod_panel = PrecacheAsset("materials/compmod/rr_panel.material")

  CompMod:PrintDebug("Adding modpanel")
  AddModPanel(compmod_panel, changelogURL)
else
  CompMod:Print("ModPanels not installed/initialised. Skipping adding ready room panel.", CompMod:GetLogLevels().warn)
end
