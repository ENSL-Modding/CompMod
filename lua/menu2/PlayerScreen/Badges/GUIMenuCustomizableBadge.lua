-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/PlayerScreen/Badges/GUIMenuCustomizableBadge.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Badge object specifically for the badge customization widget.  Not a general purpose badge
--    object for use anywhere.
--
--  Parameters (* = required)
--      columns
--      badgeName   The name of the badge.
--
--  Properties
--      Columns     The bitset of columns that this badge is compatible with.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIDraggable.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

---@class GUIMenuCustomizableBadge : GUIDraggable
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local baseClass = GUIDraggable
baseClass = GetTooltipWrappedClass(baseClass)
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuCustomizableBadge" (baseClass)

local kFlashShader = PrecacheAsset("shaders/GUI/menu/flash.surface_shader")
local kPressedScale = Vector(0.875, 0.875, 1)

GUIMenuCustomizableBadge:AddClassProperty("Columns", 0)
GUIMenuCustomizableBadge:AddClassProperty("_Flash", 0)

local function OnFlashChanged(self, value)
    self:SetFloatParameter("multAmount", 2 * value + 1)
    self:SetFloatParameter("screenAmount", 2 * value)
end

local function OnFXStateChanged(self, state, prevState)
    
    -- Color dims when disabled.
    if state == "disabled" then
        self:AnimateProperty("Color", Color(0.5, 0.5, 0.5, 1), MenuAnimations.Fade)
    else
        self:AnimateProperty("Color", Color(1, 1, 1, 1), MenuAnimations.Fade)
    end
    
    -- Scale changes when pressed.
    if state == "pressed" then
        self:ClearPropertyAnimations("Scale")
        self:SetScale(kPressedScale)
    else
        self:AnimateProperty("Scale", Vector(1, 1, 1), MenuAnimations.Fade)
    end
    
    -- Flash when hovered over.
    if state == "hover" then
        if prevState == "pressed" then
            self:AnimateProperty("_Flash", 0.0625, MenuAnimations.FadeFast)
        else
            self:Set_Flash(1)
            self:AnimateProperty("_Flash", 0.0625, MenuAnimations.FlashColor)
            PlayMenuSound("ButtonHover")
        end
    elseif state == "pressed" then
        self:ClearPropertyAnimations("_Flash")
        self:Set_Flash(0)
    else
        self:AnimateProperty("_Flash", 0, MenuAnimations.Fade)
    end
    
end

function GUIMenuCustomizableBadge:GetBadgeName()
    return self.badgeName
end

function GUIMenuCustomizableBadge:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"number", "nil"}, params.columns, "params.columns", errorDepth)
    RequireType("string", params.badgeName, "params.badgeName", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.badgeName = params.badgeName
    
    self:SetColor(1, 1, 1, 1)
    self:SetOpacity(1)
    self:SetShader(kFlashShader)
    
    self:HookEvent(self, "On_FlashChanged", OnFlashChanged)
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    
    if params.columns then
        self:SetColumns(params.columns)
    end

end
