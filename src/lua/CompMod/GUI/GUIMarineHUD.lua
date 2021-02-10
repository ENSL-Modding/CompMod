local oldInitializeMinimap = GUIMarineHUD.InitializeMinimap
function GUIMarineHUD:InitializeMinimap()
    oldInitializeMinimap(self)

    self.minimapStencil:SetClearsStencilBuffer(true)
end
