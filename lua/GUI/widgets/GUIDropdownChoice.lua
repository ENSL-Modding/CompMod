-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/widgets/GUIDropdownChoice.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A choice included in a GUIDropdownWidget.
--
--  Parameters (* = required)
--      displayString       The string to display for this choice.  Defaults to "CHOICE".
--      value               
--  
--  Properties:
--      Value               The value this choice represents.  Defaults to 0, but can be any
--                          type (except nil).
--  
--  Events:
--      OnChosen            This value was clicked.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIText.lua")

---@class GUIDropdownChoice : GUIText
class "GUIDropdownChoice" (GUIText)

GUIDropdownChoice:AddClassProperty("Value", 0)

function GUIDropdownChoice:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIText.Initialize(self, params, errorDepth)
    
    if params.value ~= nil then
        self:SetValue(params.value)
    end
    
    RequireType({"string", "nil"}, params.displayString, "params.displayString", errorDepth)
    
    self:SetText(type(params.displayString) == "string" and params.displayString or "CHOICE")
    
    self:ListenForCursorInteractions()
    
end

function GUIDropdownChoice:OnMouseRelease()
    self:FireEvent("OnChosen", self:GetValue())
end