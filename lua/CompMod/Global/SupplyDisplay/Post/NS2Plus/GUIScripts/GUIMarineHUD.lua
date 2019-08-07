
if GUIMarineHUD.CHUDRepositionGUI then
    local oldCHUDRepositionGUI = GUIMarineHUD.CHUDRepositionGUI
    function GUIMarineHUD:CHUDRepositionGUI()
        oldCHUDRepositionGUI(self)

        self:UpdateScale()
    end
else
    CompMod:Print("Cannot override NS2+ function GUIMarineHUD.CHUDRepositionGUI !", CompMod:GetLogLevels().warn)
end