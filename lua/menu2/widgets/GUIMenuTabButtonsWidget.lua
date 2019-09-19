-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuTabbedBox.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Two buttons designed to fit inside the tab part at the bottom of a GUIMenuTabbedBox.
--@class GUIMenuTabbedBox : GUIObject
--
--  Properties:
--      TabMinWidth         -- The minimum width of the whole tab.
--      TabHeight           -- The height of the tab.  The width is calculated based on the button
--                             labels' sizes.
--      LeftLabel           -- The text to display on the left button.
--      LeftEnabled         -- Whether or not the left button is enabled.
--      RightLabel          -- The text to display on the right button.
--      RightEnabled        -- Whether or not the right button is enabled.
--  
--  Events:
--      OnLeftPressed       -- Whenver the left button is pressed and released while enabled.
--      OnRightPressed      -- Whenver the right button is pressed and released while enabled.
--      OnTabSizeChanged    -- Whenever the derived TabSize has changed.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/widgets/GUIMenuShapedButton.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuTabButtonsWidget : GUIObject
class "GUIMenuTabButtonsWidget" (GUIObject)

local kDividerGraphic = PrecacheAsset("ui/newMenu/splitter.dds")
local kButtonTextPadding = 50 -- empty space on either side of the button.
local kLabelOffsetY = -8

GUIMenuTabButtonsWidget:AddClassProperty("TabMinWidth", 400)
GUIMenuTabButtonsWidget:AddClassProperty("TabHeight", 100)

GUIMenuTabButtonsWidget:AddCompositeClassProperty("LeftLabel", "leftButton", "Label")
GUIMenuTabButtonsWidget:AddCompositeClassProperty("LeftEnabled", "leftButton", "Enabled")

GUIMenuTabButtonsWidget:AddCompositeClassProperty("RightLabel", "rightButton", "Label")
GUIMenuTabButtonsWidget:AddCompositeClassProperty("RightEnabled", "rightButton", "Enabled")

local function RecalculateSize(self)
    
    local leftButtonTextWidth = self.leftButton.text:GetSize().x
    local rightButtonTextWidth = self.rightButton.text:GetSize().x
    local tabHeight = self:GetTabHeight()
    local minWidth = self:GetTabMinWidth()
    
    local combinedWidth = leftButtonTextWidth + rightButtonTextWidth + kButtonTextPadding*4
    local newTotalWidth = math.max(minWidth, combinedWidth)
    local actualPadding = (newTotalWidth - leftButtonTextWidth - rightButtonTextWidth) * 0.25
    
    self:SetSize(newTotalWidth + tabHeight * 2, tabHeight)
    
    local leftSideWidth = leftButtonTextWidth + actualPadding * 2
    local rightSideWidth = rightButtonTextWidth + actualPadding * 2
    
    self.leftButton:SetPoints(
    {
        Vector(0, 0, 0),
        Vector(tabHeight, tabHeight, 0),
        Vector(tabHeight + leftSideWidth, tabHeight, 0),
        Vector(tabHeight + leftSideWidth, 0, 0),
    })
    
    self.rightButton:SetPoints(
    {
        Vector(leftSideWidth + tabHeight, 0, 0),
        Vector(leftSideWidth + tabHeight, tabHeight, 0),
        Vector(leftSideWidth + tabHeight + rightSideWidth, tabHeight, 0),
        Vector(leftSideWidth + tabHeight + rightSideWidth + tabHeight, 0, 0),
    })
    
    self.dividerGraphic:SetPosition(tabHeight + leftSideWidth, 0)
    
    self.leftButton:SetLabelOffset(tabHeight * 0.5, kLabelOffsetY)
    self.rightButton:SetLabelOffset(-tabHeight * 0.5, kLabelOffsetY)
    
    local prevTabSize = self.tabSize
    local newTabSize = self:GetTabSize()
    if prevTabSize.x ~= newTabSize.x or prevTabSize.y ~= newTabSize.y then
        self.tabSize = newTabSize
        self:FireEvent("OnTabSizeChanged", Vector(self.tabSize), prevTabSize)
    end
    
end

function GUIMenuTabButtonsWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    self.tabSize = Vector(-1, -1, 0)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    -- Create little divider graphic that visually separates the buttons.
    self.dividerGraphic = self:CreateGUIItem()
    self.dividerGraphic:SetTexture(kDividerGraphic)
    self.dividerGraphic:SetSizeFromTexture()
    self.dividerGraphic:AlignLeft()
    
    self.leftButton = CreateGUIObject("leftButton", GUIMenuShapedButton, self)
    self.rightButton = CreateGUIObject("rightButton", GUIMenuShapedButton, self)
    
    self:ForwardEvent(self.leftButton, "OnPressed", "OnLeftPressed")
    self:ForwardEvent(self.rightButton, "OnPressed", "OnRightPressed")
    
    self:HookEvent(self, "OnTabHeightChanged", RecalculateSize)
    self:HookEvent(self, "OnTabMinWidthChanged", RecalculateSize)
    self:HookEvent(self.leftButton.text, "OnSizeChanged", RecalculateSize)
    self:HookEvent(self.rightButton.text, "OnSizeChanged", RecalculateSize)
    
end

function GUIMenuTabButtonsWidget:SetFont(font)
    self.leftButton:SetFont(font)
    self.rightButton:SetFont(font)
end

function GUIMenuTabButtonsWidget:GetTabSize()
    local result = Vector(self:GetSize().x - self:GetTabHeight() * 2, self:GetTabHeight(), 0)
    return result
end
