-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuTabbedListButtonsWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    List of buttons designed to be top or bottom aligned of its parent
--@class GUIMenuTabbedListButtonsWidget : GUIObject
--
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =====================


Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/widgets/GUIMenuShapedButton.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/widgets/GUIMenuCustomizeTabButton.lua")
Script.Load("lua/GUI/layouts/GUIListLayout.lua")


---@class GUIMenuTabbedListButtonsWidget : GUIObject
class "GUIMenuTabbedListButtonsWidget" (GUIObject)

--TODO Load Top/Bottom tab images
--local kDividerGraphic = PrecacheAsset("ui/newMenu/splitter.dds") --TODO Load TOp/Bottom versions?
local kButtonTextPadding = 20 -- empty space on either side of the button.
local kLabelOffsetY = -8

GUIMenuTabbedListButtonsWidget:AddClassProperty("ButtonListMinWidth", 400)
GUIMenuTabbedListButtonsWidget:AddClassProperty("ButtonListHeight", 100)

function GUIMenuTabbedListButtonsWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    self.tabSize = Vector(-1, -1, 0)
    
    GUIObject.Initialize(self, params, errorDepth)

    self.buttons = {}
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self,
    {
        orientation = "horizontal",
    })
    self:HookEvent(self.layout, "OnSizeChanged", self.SetSize)

end

--TODO Add "End Cap" images (optional)

function GUIMenuTabbedListButtonsWidget:AddButton(name, label, optionalPressedCallback, optStyle)  --FIXME Need "style" and "size-limits?"
    
    RequireType("string", name, "name", 2)
    RequireType("string", label, "label", 2)
    RequireType({"function", "nil"}, optionalPressedCallback, "optionalPressedCallback", 2)
    
    if self.buttons[name] then
        error(string.format("Button named '%s' already exists!", name), 2)
    end
    
    local newButton = CreateGUIObject(name, GUIMenuCustomizeTabButton, self.layout, 
    {
        label = label,
        font = optStyle.font,
        fontColor = optStyle.fontColor,
        fontGlow = optStyle.fontGlow,
        fontGlowStyle = optStyle.fontGlowStyle,
    })
    if optionalPressedCallback then
        newButton:HookEvent(newButton, "OnPressed", optionalPressedCallback)
    end

    self.buttons[name] = newButton
    
    return newButton
end

function GUIMenuTabbedListButtonsWidget:RemoveButton(name)
    RequireType("string", name, "name", 2)
    
    if not self.buttons[name] then
        return false
    end
    
    local button = self.buttons[name]
    self.buttons[name] = nil
    button:Destroy()
    
    return true
end

function GUIMenuTabbedListButtonsWidget:GetTabSize()
    local result = Vector(self:GetSize().x - self:GetTabHeight() * 2, self:GetTabHeight(), 0)
    return result
end


