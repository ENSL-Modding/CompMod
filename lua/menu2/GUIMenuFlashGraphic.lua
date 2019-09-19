-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/GUIMenuFlashGraphic.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Similar to GUIMenuGraphic, but designed to allow full-color graphics to be used.  Uses a
--    special shader to add a flash effect, rather than changing the color of the graphic.
--
--  Parameters (* = required)
--      defaultTexture      The texture to use when the icon is idle. (Eg not being hovered over).
--                          The default size of this object is derived from the size of this object.
--      hoverTexture        The texture to use when the icon is being hovered over.  This is also
--                          the texture that the flash effect is applied to.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")

---@class GUIMenuFlashGraphic : GUIObject
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper

local baseClass = GUIObject
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuFlashGraphic" (baseClass)

GUIMenuFlashGraphic:AddClassProperty("_DimOpacity", 1)
GUIMenuFlashGraphic:AddClassProperty("_DimGray", 1)
GUIMenuFlashGraphic:AddClassProperty("_LitOpacity", 0)
GUIMenuFlashGraphic:AddClassProperty("_Flash", 0)

local function OnFXStateChanged(self, state, prevState)
    
    -- Dim when disabled.*
    if state == "disabled" then
        self:AnimateProperty("_DimOpacity", 0.75, MenuAnimations.Fade)
        self:AnimateProperty("_DimGray", 0.5, MenuAnimations.Fade)
        self:AnimateProperty("_LitOpacity", 0, MenuAnimations.Fade)
    else
        self:AnimateProperty("_DimOpacity", 1, MenuAnimations.Fade)
        self:AnimateProperty("_DimGray", 1, MenuAnimations.Fade)
    
        if state == "pressed" then
            self:ClearPropertyAnimations("_Flash")
            self:Set_Flash(0)
            self:ClearPropertyAnimations("_LitOpacity")
            self:Set_LitOpacity(0.5)
        elseif state == "hover" then
            if prevState == "pressed" then
                self:AnimateProperty("_LitOpacity", 1, MenuAnimations.Fade)
            else
                self:ClearPropertyAnimations("_LitOpacity")
                self:Set_LitOpacity(1)
                DoFlashEffect(self, "_Flash")
                PlayMenuSound("ButtonHover")
            end
        else
            self:AnimateProperty("_Flash", 0, MenuAnimations.Fade)
            self:AnimateProperty("_LitOpacity", 0, MenuAnimations.Fade)
        end
        
    end

end

local function UpdateDimColor(self)
    local grayLevel = self:Get_DimGray()
    local opacity = self:Get_DimOpacity()
    self.dimGraphic:SetColor(grayLevel, grayLevel, grayLevel, opacity)
end

local function UpdateLitOpacity(self)
    self.litGraphic:SetColor(1, 1, 1, self:Get_LitOpacity())
end

function GUIMenuFlashGraphic:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType("string", params.defaultTexture, "params.defaultTexture", errorDepth)
    RequireType("string", params.hoverTexture, "params.hoverTexture", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.dimGraphic = self:CreateGUIItem()
    self.dimGraphic:AlignCenter()
    self.dimGraphic:SetTexture(params.defaultTexture)
    self.dimGraphic:SetSizeFromTexture()
    
    self.litGraphic = self:CreateGUIItem()
    self.litGraphic:AlignCenter()
    self.litGraphic:SetTexture(params.hoverTexture)
    self.litGraphic:SetSizeFromTexture()
    self.litGraphic:SetLayer(1)
    self.litGraphic:SetColor(1, 1, 1, 0)
    SetupFlashEffect(self, "_Flash", self.litGraphic)
    
    self:SetSize(self.dimGraphic:GetSize())
    
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    self:HookEvent(self, "On_DimOpacityChanged", UpdateDimColor)
    self:HookEvent(self, "On_DimGrayChanged", UpdateDimColor)
    self:HookEvent(self, "On_LitOpacityChanged", UpdateLitOpacity)
    
end
