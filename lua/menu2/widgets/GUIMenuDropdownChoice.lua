-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuDropdownChoice.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A choice included in a GUIDropdownWidget.
--@class GUIMenuDropdownChoice : GUIDropdownChoice
--
--  Properties:
--      Value               -- The value this choice represents.
--  
--  Events:
--      OnChosen            -- This value was clicked.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--Script.Load("lua/GUI/widgets/GUIDropdownChoice.lua")
Script.Load("lua/menu2/GUIMenuTruncatedText.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuDropdownChoice : GUIMenuTruncatedText
class "GUIMenuDropdownChoice" (GUIMenuTruncatedText)

GUIMenuDropdownChoice:AddClassProperty("Value", 0)

local function UpdateTextSize(self)
    self:SetSize(math.min(self.maxWidth or self:GetTextSize().x, self:GetTextSize().x), self:GetTextSize().y)
end

function GUIMenuDropdownChoice:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.displayString, "params.displayString", errorDepth)
    
    GUIMenuTruncatedText.Initialize(self, params, errorDepth)
    
    if params.value ~= nil then
        self:SetValue(params.value)
    end
    
    self:SetText(type(params.displayString) == "string" and params.displayString or "CHOICE")
    
    self:ListenForCursorInteractions()
    
    self:SetFont(MenuStyle.kOptionFont)
    self:SetColor(MenuStyle.kLightGrey)
    
    self:HookEvent(self, "OnTextSizeChanged", UpdateTextSize)
    
end

function GUIMenuDropdownChoice:OnMouseEnter()
    
    GUIDropdownChoice.OnMouseEnter(self)
    
    PlayMenuSound("ButtonHover")
    DoColorFlashEffect(self)
end

function GUIMenuDropdownChoice:OnMouseExit()
    
    GUIDropdownChoice.OnMouseExit(self)
    
    self:AnimateProperty("Color", MenuStyle.kLightGrey, MenuAnimations.Fade)
end

function GUIMenuDropdownChoice:OnMouseRelease()
    self:FireEvent("OnChosen", self:GetValue())
end

function GUIMenuDropdownChoice:SetMaxWidth(maxWidth)
    
    self.maxWidth = maxWidth
    UpdateTextSize(self)
    
end
