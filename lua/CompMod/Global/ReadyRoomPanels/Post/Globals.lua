if AddModPanel then
  local ensl_panel_URL = "https://www.ensl.org"
  local compmod_panel_URL = "https://adsfgg.github.io/CompMod"
  local ensl_panel = PrecacheAsset("materials/compmod/mod_panel_ensl.material")
  local compmod_panel = PrecacheAsset("materials/compmod/mod_panel_compmod.material")

  CompMod:PrintDebug("Adding ENSL modpanel")
  AddModPanel(ensl_panel, ensl_panel_URL)

  CompMod:PrintDebug("Adding CompMod modpanel")
  AddModPanel(compmod_panel, compmod_panel_URL)
else
  CompMod:Print("ModPanels not installed/initialised. Skipping adding ready room panel.", CompMod:GetLogLevels().warn)
end
