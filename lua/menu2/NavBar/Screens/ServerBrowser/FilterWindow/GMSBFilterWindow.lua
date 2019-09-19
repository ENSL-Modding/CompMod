-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFilterWindow.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Window displaying a list of filters to use to narrow down list of servers in the server
--    browser.  Extends GUIDraggable so that the window can be relocated wherever the user desires.
--  
--  Events
--      OnClosed        Fires when the window begins closing.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIDraggable.lua")
Script.Load("lua/menu2/GUIMenuNineBox.lua")
Script.Load("lua/menu2/widgets/GUIMenuScrollPane.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/FilterSetup.lua")
Script.Load("lua/menu2/widgets/GUIMenuSimpleTextButton.lua")
Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")

Script.Load("lua/menu2/wrappers/Expandable.lua")

---@class GMSBFilterWindow : GUIDraggable
class "GMSBFilterWindow" (GUIDraggable)

local kKnurlingTexture = PrecacheAsset("ui/newMenu/knurlingPattern.dds")
local kKnurlingHeight = 64

local kOutsidePadding = 36
local kSpacing = 36

local kWidth = 700
local kWidgetWidth = kWidth - kOutsidePadding * 2

local kBackgroundParams =
{
    texture = PrecacheAsset("ui/newMenu/nine_box_5.dds"),
    
    col0Width = 18,
    col1Width = 18,
    col2Width = 18,
    
    row0Height = 9,
    row1Height = 36,
    row2Height = 9,
    
    topLeftOffset = Vector(-5, -5, 0),
    bottomRightOffset = Vector(5, 5, 0),
}

-- Filter window will never scale lower than this.
local kMinimumScale = 0.41666667

-- Filter window will never be taller than this.
local kMaximumHeight = 1600

local kScrollBarExtraWidth = 30
local kCloseButtonFont = {family="Microgramma", size=30}

local function UpdateGrabbyBitTextureCoordinates(grabbyBit)
    
    local size = grabbyBit:GetSize()
    grabbyBit:SetTexturePixelCoordinates(0, 0,
        math.floor(grabbyBit:GetSize().x + 0.5),
        math.floor(grabbyBit:GetSize().y + 0.5))
    
end

local function UpdateGrabbyBitSize(grabbyBit, size)
    grabbyBit:SetSize(size.x, grabbyBit:GetSize().y)
end

local function OnLayoutSizeChanged(self, size)
    
    self:SetSize(size.x + kOutsidePadding * 2, math.min(size.y + kKnurlingHeight + kOutsidePadding * 2, kMaximumHeight))
    
    self.contents:SetPaneSize(size.x, size.y)
    self.contents:SetSize(size.x, math.min(size.y, kMaximumHeight - kKnurlingHeight - kOutsidePadding * 2))
    
    if self.contents:GetPaneSize().y > self.contents:GetSize().y then
        -- Vertical scroll bar is visible, need to make extra room for it.
        
        self.contents:SetVerticalScrollBarEnabled(true)
        local extraWidth = self.contents:GetScrollBarThickness() + kScrollBarExtraWidth
        self.contents:SetSize(self.contents:GetSize().x + extraWidth, self.contents:GetSize().y)
        self:SetSize(self:GetSize().x + extraWidth, self:GetSize().y)
        self.contentsLayout:SetPosition(0, 0)
    else
        -- Vertical scroll bar is not visible.  Still need to make extra room at the edges so they
        -- don't get cropped away.
        self.contents:SetVerticalScrollBarEnabled(false)
        self.contents:SetSize(self:GetSize().x, self.contents:GetSize().y)
        self.contentsLayout:SetPosition(kOutsidePadding, 0)
    end
    
    self.blocker:SetSize(self:GetSize().x, self:GetSize().y - kKnurlingHeight)
end

local function OnWidgetValueChanged(widget, value, prevValue)
    GetServerBrowser():SetFilterValue(widget.name, value)
end

local function AddFilterContents(self)
    
    local filterConfig = GetServerBrowserFilterConfiguration()
    for i=1, #filterConfig do
        local newWidget = CreateGUIObjectFromConfig(filterConfig[i], self.contentsLayout)
        newWidget:SetSize(kWidgetWidth, newWidget:GetSize().y)
        newWidget:AlignTop()
        
        newWidget:HookEvent(newWidget, "OnValueChanged", OnWidgetValueChanged)
        
        self.filterWidgets[filterConfig[i].name] = newWidget
        self.filterWidgets[#self.filterWidgets + 1] = filterConfig[i].name
    end
    
end

local function UpdateResolutionScaling(self, x, y)
    
    local mockupRes = Vector(3840, 2160, 0)
    local res = Vector(x, y, 0)
    local scale = res / mockupRes
    scale = math.min(scale.x, scale.y)
    
    scale = math.max(kMinimumScale, scale)
    self:SetScale(scale, scale)
    
end

local function OnExpansionChangedForDestruction(self, expansion)
    if expansion == 0.0 then
        self:Destroy()
    end
end

function GMSBFilterWindow:GetFilterWidgetByName(name)
    return self.filterWidgets[name]
end

local function UpdateExpandableHotSpot(expandable, expansion)
    expandable:SetHotSpot(expandable:GetHotSpot().x, 1.0 - expansion)
end

function GMSBFilterWindow:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIDraggable.Initialize(self, params, errorDepth)
    
    self:SetLayer(200) -- well above anything else in the main menu.
    
    -- Mapping of name -> widget.  Also mapping of index -> name.
    self.filterWidgets = {}
    
    self.expandableObj = CreateGUIObject("expandableObj", GetExpandableWrappedClass(GUIObject), self,
    {
        expansionMargin = 20,
    })
    self.expandableObj:HookEvent(self, "OnSizeChanged", self.expandableObj.SetSize)
    self.expandableObj:HookEvent(self.expandableObj, "OnExpansionChanged", UpdateExpandableHotSpot)
    
    -- Animate expansion in.
    self.expandableObj:SetExpanded(false)
    self.expandableObj:SetExpansion(0.0)
    self.expandableObj:ClearPropertyAnimations("Expansion")
    self.expandableObj:SetExpanded(true)
    
    self.back = CreateGUIObject("back", GUIMenuNineBox, self.expandableObj, kBackgroundParams)
    self.back:SetLayer(-1)
    self.back:HookEvent(self, "OnSizeChanged", self.back.SetSize)
    
    self.backShadow = CreateGUIObject("backShadow", GUIMenuDropShadow, self.expandableObj,
    {
        offset = Vector(-2.92, 9.56, 0), -- angle = 73 degrees, distance = 10 px.
    })
    self.backShadow:HookEvent(self, "OnSizeChanged", self.backShadow.SetSize)
    
    self.grabbyBit = CreateGUIObject("grabbyBit", GUIObject, self.expandableObj)
    self.grabbyBit:SetLayer(1)
    self.grabbyBit:SetTexture(kKnurlingTexture)
    self.grabbyBit:SetColor(1, 1, 1, 0.5)
    self.grabbyBit:HookEvent(self.grabbyBit, "OnSizeChanged", UpdateGrabbyBitTextureCoordinates)
    self.grabbyBit:HookEvent(self, "OnSizeChanged", UpdateGrabbyBitSize)
    self.grabbyBit:SetSize(self:GetSize().x, kKnurlingHeight)
    
    self.closeButton = CreateGUIObject("closeButton", GUIMenuSimpleTextButton, self.expandableObj)
    self.closeButton:SetLayer(2)
    self.closeButton:AlignTopRight()
    self.closeButton:SetText("X")
    self.closeButton:SetFont(kCloseButtonFont)
    self.closeButton:SetPosition(-16, 6)
    self:HookEvent(self.closeButton, "OnPressed", self.Close)
    
    -- Prevent clicking and dragging everywhere except on the grabby bit.
    self.blocker = CreateGUIObject("blocker", GUIObject, self.expandableObj)
    self.blocker:AlignBottom()
    self.blocker:SetLayer(1)
    self.blocker:ListenForCursorInteractions()
    
    self.contents = CreateGUIObject("contents", GUIMenuScrollPane, self.expandableObj,
    {
        horizontalScrollBarEnabled = false,
    })
    self.contents:AlignBottom()
    self.contents:SetLayer(2)
    self.contents:SetPosition(0, -kOutsidePadding)
    
    self.contentsLayout = CreateGUIObject("contentsLayout", GUIListLayout, self.contents,
    {
        orientation = "vertical",
        spacing = kSpacing,
    })
    self:HookEvent(self.contentsLayout, "OnSizeChanged", OnLayoutSizeChanged)
    
    AddFilterContents(self)
    
    -- Consume wheel events so they don't penetrate through the window.
    self:ListenForWheelInteractions()
    
    -- Listen for the escape key to close the window.
    self:ListenForKeyInteractions()
    
    self:HookEvent(GetGlobalEventDispatcher(), "OnResolutionChanged", UpdateResolutionScaling)
    UpdateResolutionScaling(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
    -- Center on screen.
    local screenSpaceSize = self:GetSize() * self:GetScale()
    local screenSize = Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0)
    local center = (screenSize - screenSpaceSize) * 0.5
    self:SetPosition(center)
    
    GetGUIMenuTooltipManager():SetBlocksTooltips(self)
    
end

-- Attempt to close the window.  Returns true if the window is now closing but wasn't before.
function GMSBFilterWindow:Close()
    
    if self.closing then
        return false -- already closing.
    end
    
    self.expandableObj:SetExpanded(false)
    self:HookEvent(self.expandableObj, "OnExpansionChanged", OnExpansionChangedForDestruction)
    self:FireEvent("OnClosed")
    
    self.closing = true
    
    return true
    
end

function GMSBFilterWindow:OnKey(key, down)
    
    -- Ignore if we're in-game.  This allows the call to fall through to GUIMainMenu, and thus
    -- close the menu immediately.  We don't want to get players killed by making the menu hard to
    -- close, now do we? :)
    if GetMainMenu():GetIsInGame() then
        return false
    end
    
    if key ~= InputKey.Escape or not down then
        return false -- we only care if the escape key is pressed down.
    end
    
    local result = self:Close()
    return result
    
end

