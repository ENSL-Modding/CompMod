-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuCheckboxWidgetLabeled.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    GUIMenuCheckboxWidget that includes a label.
--
--  Properties:
--      Value               -- State of the checkbox, expressed as a number to support partial
--                             states.  0 = unchecked, 1 = checked, anything else is partial.
--      Label               -- Label of this widget.
--  
--  Events:
--      OnPressed           Fires whenever the object is clicked and released on, while enabled.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/widgets/GUIMenuCheckboxWidget.lua")
Script.Load("lua/menu2/GUIMenuTruncatedText.lua")

---@class GUIMenuCheckboxWidgetLabeled : GUIObject
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIObject
baseClass = GetCursorInteractableWrappedClass(baseClass)
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuCheckboxWidgetLabeled" (baseClass)

local kMaxLabelWidth = 700

GUIMenuCheckboxWidgetLabeled:AddCompositeClassProperty("Label", "label", "Text")
GUIMenuCheckboxWidgetLabeled:AddCompositeClassProperty("Value", "checkbox")

local function UpdateWidgetSize(self)
    
    -- Update label size
    self.label:SetSize(math.min(self.label:GetTextSize().x, kMaxLabelWidth), self.label:GetTextSize().y)
    
    self:SetSize(GUIMenuCheckboxWidget.kPlainBoxSize.x + MenuStyle.kWidgetPadding * 2 + MenuStyle.kLabelSpacing + self.label:GetSize().x * self.label:GetScale().x, math.max(GUIMenuCheckboxWidget.kPlainBoxSize.y, self.label:GetSize().y * self.label:GetScale().y) + MenuStyle.kWidgetPadding * 2)
end

function GUIMenuCheckboxWidgetLabeled:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.checkbox = CreateGUIObject("checkbox", GUIMenuCheckboxWidget, self,
    {
        cursorController = self,
    })
    self.checkbox:AlignLeft()
    self.checkbox:SetPosition(MenuStyle.kWidgetPadding, 0)
    self.checkbox:StopListeningForCursorInteractions() -- will be forwarded from this object instead.
    
    self.label = CreateGUIObject("label", GUIMenuTruncatedText, self,
    {
        cls = GUIMenuText,
    })
    self:AddFXReceiver(self.label:GetObject())
    
    self.label:SetText("LABEL")
    self.label:SetFont(MenuStyle.kOptionFont)
    self.label:SetColor(MenuStyle.kLightGrey)
    self:HookEvent(self, "OnLabelChanged", UpdateWidgetSize)
    self:HookEvent(self.label, "OnTextSizeChanged", UpdateWidgetSize)
    self.label:AlignRight()
    self.label:SetPosition(-MenuStyle.kWidgetPadding, 0)
    
    if params.label then
        self:SetLabel(params.label)
    end
    
    UpdateWidgetSize(self)
    
end

function GUIMenuCheckboxWidgetLabeled:OnMouseRelease()
    baseClass.OnMouseRelease(self)
    self.checkbox:FireEvent("OnPressed")
end

function GUIMenuCheckboxWidgetLabeled:ToggleValue()
    self:SetValue(not self:GetValue())
end

function GUIMenuCheckboxWidgetLabeled:GetValueString(value)
    local result = self.checkbox:GetValueString(value)
    return result
end
