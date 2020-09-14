--[[
    Temporary for now.

    The debug speed meter is really low and hides behind the health bar
]]

local offset = 60

local gMomentumBarHeight = 150
local kFontName = Fonts.kArial_17

function GUISpeedDebug:Initialize()

    self.momentumBackGround = GetGUIManager():CreateGraphicItem()
    self.momentumBackGround:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    -- self.momentumBackGround:SetPosition(Vector(60, -235, 0))
    self.momentumBackGround:SetPosition(Vector(60, -235 - offset, 0))
    self.momentumBackGround:SetSize(Vector(gMomentumBarHeight, 30, 0))    
    self.momentumBackGround:SetColor(Color(1, 0.2, 0.2, 0.4))
    
    self.momentumFraction = GetGUIManager():CreateGraphicItem()
    self.momentumFraction:SetSize(Vector(0, 30, 0))
    self.momentumFraction:SetColor(Color(1, 0.2, 0.2, 0.6))
    
    self.debugText = GetGUIManager():CreateTextItem()
    self.debugText:SetScale(GetScaledVector())
    self.debugText:SetFontName(kFontName)
    GUIMakeFontScale(self.debugText)
    -- self.debugText:SetPosition(Vector(0, -65, 0))
    self.debugText:SetPosition(Vector(0, -65 - offset, 0))
    
    self.airAccel = GetGUIManager():CreateTextItem()
    self.airAccel:SetScale(GetScaledVector())
    self.airAccel:SetFontName(kFontName)
    GUIMakeFontScale(self.airAccel)
    -- self.airAccel:SetPosition(Vector(0, -45, 0))
    self.airAccel:SetPosition(Vector(0, -45 - offset, 0))
    
    self.xzSpeed = GetGUIManager():CreateTextItem()
    self.xzSpeed:SetScale(GetScaledVector())
    self.xzSpeed:SetFontName(kFontName)
    GUIMakeFontScale(self.xzSpeed)
    -- self.xzSpeed:SetPosition(Vector(0, -25, 0))
    self.xzSpeed:SetPosition(Vector(0, -25 - offset, 0))
    
    self.momentumBackGround:AddChild(self.debugText)
    self.momentumBackGround:AddChild(self.momentumFraction)
    self.momentumBackGround:AddChild(self.xzSpeed)
    self.momentumBackGround:AddChild(self.airAccel)
    
    Shared.Message("Enabled speed meter!")

end