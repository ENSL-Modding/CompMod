-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/MissionScreen/GUIMenuMissionScreenPullout.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Part of the mission screen that can be clicked on to open the screen.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")

Script.Load("lua/menu2/GUIMenuGraphic.lua")
Script.Load("lua/menu2/MenuStyles.lua")

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBTopButtonGroupBackground.lua")

---@class GUIMenuMissionScreenPullout : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuMissionScreenPullout" (baseClass)

local kArrowTexture = PrecacheAsset("ui/newMenu/pulloutArrow.dds")

local function UpdateBackgroundPoints(self)
    
    local size = self:GetSize()
    local points =
    {
        Vector(0, size.x, 0),
        Vector(0, size.y - size.x, 0),
        Vector(size.x, size.y, 0),
        Vector(size.x, 0, 0),
    }
    self.back:SetPoints(points)

end

function GUIMenuMissionScreenPullout:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.arrowHolder = CreateGUIObject("arrowHolder", GetFXStateWrappedClass(GUIObject), self)
    self.arrowHolder:SetCropMax(1, 1)
    self.arrowHolder:AlignCenter()
    
    self.arrowRight = CreateGUIObject("arrowRight", GUIMenuGraphic, self.arrowHolder)
    self.arrowRight:SetTexture(kArrowTexture)
    self.arrowRight:SetSizeFromTexture()
    self.arrowRight:SetAnchor(1, 0)
    
    self.arrowLeft = CreateGUIObject("arrowLeft", GUIMenuGraphic, self.arrowHolder)
    self.arrowLeft:SetTexture(kArrowTexture)
    self.arrowLeft:SetSizeFromTexture()
    self.arrowLeft:SetAngle(math.pi)
    self.arrowLeft:SetRotationOffset(0.5, 0.5)
    self.arrowLeft:SetAnchor(0, 0)
    
    self.arrowHolder:SetSize(self.arrowRight:GetSize())
    
    self.back = CreateGUIObject("back", GMSBTopButtonGroupBackground, self)
    self.back:SetLayer(-1)
    self.back:SetOpacity(0.9)
    self:HookEvent(self, "OnSizeChanged", UpdateBackgroundPoints)
    UpdateBackgroundPoints(self)
    
    self.label = CreateGUIObject("label", GUIMenuText, self,
    {
        text = Locale.ResolveString("MISSIONS"),
        font = MenuStyle.kOptionFont,
        angle = math.pi * 0.5,
        rotationOffset = Vector(0.5, 0.5, 0),
        anchor = Vector(0.5, 0.25, 0),
        hotSpot = Vector(0.5, 0.5, 0),
    })
    
    self.label2 = CreateGUIObject("label", GUIMenuText, self,
    {
        text = Locale.ResolveString("MISSIONS"),
        font = MenuStyle.kOptionFont,
        angle = math.pi * 0.5,
        rotationOffset = Vector(0.5, 0.5, 0),
        anchor = Vector(0.5, 0.75, 0),
        hotSpot = Vector(0.5, 0.5, 0),
    })

end

local function AnimateArrowAnchors(self, anchor)
    self.arrowRight:AnimateProperty("Anchor", Vector(anchor, 0, 0), MenuAnimations.FlyIn)
    self.arrowLeft:AnimateProperty("Anchor", Vector(anchor-1, 0, 0), MenuAnimations.FlyIn)
end

function GUIMenuMissionScreenPullout:PointRight()
    AnimateArrowAnchors(self, 0)
end

function GUIMenuMissionScreenPullout:PointLeft()
    AnimateArrowAnchors(self, 1)
end
