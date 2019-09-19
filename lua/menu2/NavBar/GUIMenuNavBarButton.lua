-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/GUIMenuNavBarButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Button for the main menu's nav bar.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIShapedButton.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/GUI/utilities/Polygon.lua")
Script.Load("lua/GUI/style/GUIStyledText.lua")
Script.Load("lua/menu2/widgets/GUIMenuGlowyText.lua")

---@class GUIMenuNavBarButton : GUIMenuShapedButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIShapedButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuNavBarButton" (baseClass)

GUIMenuNavBarButton:AddCompositeClassProperty("GlowColor", "glow", "Color")

GUIMenuNavBarButton.kHoverLightTexture = PrecacheAsset("ui/newMenu/mainNavBarButtonLight.dds")

local function PlayPressedSound()
    PlayMenuSound("ButtonClick")
end

function GUIMenuNavBarButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.nonHoverText = CreateGUIObject("nonHoverText", GUIStyledText, self)
    self.nonHoverText:SetFont(MenuStyle.kNavBarFont.family, MenuStyle.kNavBarFont.size)
    self.nonHoverText:SetStyle(MenuStyle.kMainBarButtonText)
    self.nonHoverText:AlignCenter()
    self.nonHoverText:SetLayer(-1)
    
    self.hoverText = CreateGUIObject("hoverText", GUIMenuGlowyText, self)
    self.hoverText:AlignCenter()
    self.hoverText:SetLayer(1)
    self.hoverText:SetFont(MenuStyle.kNavBarFont)
    self.hoverText:SetStyle(MenuStyle.kMainBarButtonGlow)
    
    self.glow = self:CreateGUIItem()
    self.glow:SetTexture(self.kHoverLightTexture)
    self.glow:SetSizeFromTexture()
    self.glow:AlignCenter()
    self.glow:SetOpacity(0)
    self.glowing = false
    
    self:HookEvent(self, "OnPressed", PlayPressedSound)
    self:HookEvent(self, "OnTextChanged", self.OnTextChanged)
    
end

function GUIMenuNavBarButton:SetTextOffset(offset)
    self.nonHoverText:SetPosition(offset)
    self.hoverText:SetPosition(offset)
end

function GUIMenuNavBarButton:SetGlowOffset(offset)
    self.glow:SetPosition(offset)
end

function GUIMenuNavBarButton:SetGlowing(state)
    
    if state == self.glowing then
        return
    end
    
    self.glowing = state
    local goal = state and 1 or 0
    self:AnimateProperty("GlowColor", Color(1, 1, 1, goal), MenuAnimations.Fade)
    
end

function GUIMenuNavBarButton:GetGlowing()
    return self.glowing
end

function GUIMenuNavBarButton:OnTextChanged(value)
    
    self.nonHoverText:SetText(value)
    self.hoverText:SetText(value)
    
end
