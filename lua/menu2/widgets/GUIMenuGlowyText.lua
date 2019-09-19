-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuGlowyText.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Fancy glowing text that is used in important buttons.  Can flash and fade away.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/style/GUIStyledText.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")

---@class GUIMenuGlowyText : GUIStyledText
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIStyledText
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuGlowyText" (baseClass)

GUIMenuGlowyText:AddClassProperty("_Flash", 0.0)

local kFlashShader = PrecacheAsset("shaders/GUI/menu/flash.surface_shader")

local function OnFlashChanged(self, value)
    self:SetFloatParameter("multAmount", 2 * value + 1)
    self:SetFloatParameter("screenAmount", 2 * value)
end

local function OnFXStateChanged(self, state, prevState)
    if state == "disabled" then
        self:AnimateProperty("Opacity", 0, MenuAnimations.Fade)
    elseif state == "pressed" then
        self:ClearPropertyAnimations("Opacity")
        self:SetOpacity(0.5)
    elseif state == "hover" then
        if prevState == "pressed" then
            self:AnimateProperty("Opacity", 1, MenuAnimations.FadeFast)
        else
            self:Set_Flash(1)
            self:AnimateProperty("_Flash", 0, MenuAnimations.FlashColor)
            self:ClearPropertyAnimations("Opacity")
            self:SetOpacity(1)
            PlayMenuSound("ButtonHover")
        end
    elseif state == "default" then
        self:ClearPropertyAnimations("Opacity")
        self:AnimateProperty("Opacity", 0, MenuAnimations.Fade)
    end
end

function GUIMenuGlowyText:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self:SetShader(kFlashShader)
    self:SetColor(1, 1, 1, 1)
    self:SetOpacity(0)
    
    self:HookEvent(self, "On_FlashChanged", OnFlashChanged)
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    
end
