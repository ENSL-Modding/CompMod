-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/widgets/GUICheckboxWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Simple widget that contains a value that can be switched on/off with a click.
--
--  Parameters (* = required)
--      default             Starting value for this widget.
--
--  Properties:
--      Value               True/false state of the checkbox.
--      MouseOver           Whether or not the mouse is currently over the object.
--      Pressed             Whether or not the mouse is pressed down on this object.  Does not
--                          matter if the mouse is over the object, only that it was over it when it
--                          was clicked down, and has yet to be released.
--
--  Optional Properties (will be used if present, otherwise ignored)
--      Enabled
--
--  Events:
--      OnPressed           Fires whenever the object is clicked and released on, while enabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIButton.lua")

---@class GUICheckboxWidget : GUIButton
class "GUICheckboxWidget" (GUIButton)

local kDefaultSize = Vector(32, 32, 0)

GUICheckboxWidget:AddClassProperty("Value", false)

function GUICheckboxWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"boolean", "nil"}, params.default, "params.default", errorDepth)
    
    GUIButton.Initialize(self, params, errorDepth)
    
    self:SetSize(kDefaultSize)
    
    self:HookEvent(self, "OnPressed", self.ToggleValue)
    
    if params.default ~= nil then
        self:SetValue(params.default)
    end
    
end

function GUICheckboxWidget:ToggleValue()
    self:SetValue(not self:GetValue())
end

-- Returns the given value formatted as though it were a value of this widget.
-- Returns "NO" for unchecked, and "YES" for checked.
function GUICheckboxWidget:GetValueString(value)
    return value and Locale.ResolveString("YES") or Locale.ResolveString("NO")
end
