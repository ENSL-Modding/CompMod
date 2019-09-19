-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuDividerWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Labeled divider.
--@class GUIMenuDividerWidget : GUIText
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuDividerWidget : GUIText
class "GUIMenuDividerWidget" (GUIText)

GUIMenuDividerWidget:AddClassProperty("Label", "LABEL")

function GUIMenuDividerWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    
    PushParamChange(params, "font", params.font or MenuStyle.kOptionHeadingFont)
    GUIText.Initialize(self, params, errorDepth)
    PopParamChange(params, "font")
    
    self:HookEvent(self, "OnLabelChanged", self.SetText)
    self:SetColor(MenuStyle.kLightGrey)
    
end
