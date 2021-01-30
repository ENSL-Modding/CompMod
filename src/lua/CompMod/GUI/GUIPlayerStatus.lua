local oldInit = GUIPlayerStatus.Initialize
function GUIPlayerStatus:Initialize()
    oldInit(self)
    for _, bar in ipairs(self.statusIcons) do
        bar.Settings.ShowWithLowHUDDetails = true
        bar.Settings.ShowWithHintsOnly = false
    end
end
