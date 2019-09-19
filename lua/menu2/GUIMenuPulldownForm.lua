-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuPulldownForm.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Base class for a generic pulldown menu.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/GUIMenuNavBarScreen.lua")
Script.Load("lua/menu2/GUIMenuTabbedBox.lua")
Script.Load("lua/menu2/widgets/GUIMenuTabButtonsWidget.lua")

---@class GUIMenuPulldownForm : GUIMenuNavBarScreen
class "GUIMenuPulldownForm" (GUIMenuNavBarScreen)

local kTabMinWidth = 900
local kTabHeight = 94
local kContentsTopPadding = 32
local kBackgroundExtraTop = 50

local function UpdateSize(self)
    
    local contentsSize = self.contents:GetSize()
    local tabSize = self.back:GetTabSize()
    
    self:SetSize(math.max(contentsSize.x, tabSize.x + tabSize.y * 2), contentsSize.y + tabSize.y + kContentsTopPadding)
    
end

local function UpdateBackgroundSize(back, size)
    back:SetSize(size.x, size.y + kBackgroundExtraTop)
end

function GUIMenuPulldownForm:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuNavBarScreen.Initialize(self, params, errorDepth)
    
    self:SetPosition(GUIMenuNavBar.kPulldownXPosition, self:GetPosition().y)
    
    self.back = CreateGUIObject("back", GUIMenuTabbedBox, self)
    self.back:SetLayer(-1)
    self.back:AlignBottom()
    self.back:HookEvent(self, "OnSizeChanged", UpdateBackgroundSize)
    
    self.buttons = CreateGUIObject("buttons", GUIMenuTabButtonsWidget, self)
    self.buttons:SetTabHeight(kTabHeight)
    self.buttons:SetTabMinWidth(kTabMinWidth)
    self.buttons:AlignBottom()
    self.buttons:SetFont(MenuStyle.kButtonFont)
    self.buttons:SetLeftLabel(Locale.ResolveString("BACK"))
    self:HookEvent(self.buttons, "OnLeftPressed", self.OnBack)
    self.back:HookEvent(self.buttons, "OnTabSizeChanged", self.back.SetTabSize)
    
    self.contents = CreateGUIObject("contents", GUIObject, self)
    self.contents:AlignTop()
    self.contents:SetPosition(0, kContentsTopPadding, 0)
    
    self:HookEvent(self.contents, "OnSizeChanged", UpdateSize)
    self:HookEvent(self.back, "OnTabSizeChanged", UpdateSize)
    
end
