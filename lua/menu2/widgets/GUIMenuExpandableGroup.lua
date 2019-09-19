-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuExpandableGroup.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Widget that shows/hides an expandable area underneath it.
--
--  Parameters (* = required)
--      open
--
--  Properties:
--      Open                -- Whether or not the groups contents are visible.
--      ContentsSize        -- The size of the object that holds the contents of this group.
--      Label               -- The text displayed in the label of this object.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/widgets/GUIMenuExpansionArrowWidget.lua")
Script.Load("lua/menu2/MenuStyles.lua")

Script.Load("lua/menu2/wrappers/Expandable.lua")

---@class GUIMenuExpandableGroup : GUIObject
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIObject
baseClass = GetFXStateWrappedClass(baseClass)
baseClass = GetScrollToViewWrappedClass(baseClass)
class "GUIMenuExpandableGroup" (baseClass)

GUIMenuExpandableGroup:AddCompositeClassProperty("Open", "contents", "Expanded")
GUIMenuExpandableGroup:AddCompositeClassProperty("ContentsSize", "contents", "Size")
GUIMenuExpandableGroup:AddCompositeClassProperty("Label", "label", "Text")

local kLabelLeftEdge = 92

local function OnSizeUpdateNeeded(self)
    
    local headerSize = self.header:GetSize()
    local contentsSize = self.contents:GetSize(true)
    local contentsExpansion = self.contents:GetExpansion(true)
    
    local finalSize = Vector(math.max(headerSize.x, contentsSize.x), headerSize.y + contentsSize.y * contentsExpansion, 0)
    self:AnimateProperty("Size", finalSize, MenuAnimations.FlyIn)
    
end

local function OnExpansionChanged(self, expansion)
    self.contents:SetHotSpot(0, 1 - Clamp(expansion, 0, 1))
    OnSizeUpdateNeeded(self)
end

local function OnHeaderSizeUpdateNeeded(self)
    local arrowScaledSize = self.arrow:GetScale() * self.arrow:GetSize()
    local labelScaledSize = self.label:GetScale() * self.label:GetSize()
    local headerSize = Vector(labelScaledSize.x + self.label:GetPosition().x, math.max(arrowScaledSize.y, labelScaledSize.y), 0)
    self.header:SetSize(headerSize)
    self.contents:SetPosition(0, headerSize.y)
    OnSizeUpdateNeeded(self)
end

local function OnOpenChanged(self, open)
    
    -- Animate the arrow and allow/disallow user interaction with the contents.
    if open then
        self.arrow:PointUp()
    else
        self.arrow:PointDown()
    end
    
end

function GUIMenuExpandableGroup:GetChildHoldingItem()
    if self.contents then
        local result = self.contents:GetChildHoldingItem()
        return result
    else
        -- Still initializing, contents object not yet created.
        local result = self:GetRootItem()
        return result
    end
end

local contentsClass = GUIObject
contentsClass = GetExpandableWrappedClass(contentsClass)

function GUIMenuExpandableGroup:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"boolean", "nil"}, params.open, "params.open", errorDepth)
    
    PushParamChange(params, "scrollToViewPropertyList", {"Open"})
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "scrollToViewPropertyList")
    
    self.header = CreateGUIObject("header", GetFXStateWrappedClass(GUIButton), self)
    
    self.arrow = CreateGUIObject("arrow", GUIMenuExpansionArrowWidget, self.header,
    {
        defaultColor = MenuStyle.kLightGrey,
    })
    self.arrow:AlignLeft()
    
    self.label = CreateGUIObject("label", GUIMenuText, self.header)
    self.label:SetPosition(kLabelLeftEdge, 0, 0)
    self.label:AlignLeft()
    self.label:SetFont(MenuStyle.kOptionHeadingFont)
    self.label:SetColor(MenuStyle.kLightGrey)
    self.label:SetText("LABEL")
    
    local initialState = false
    if params.open ~= nil then
        initialState = params.open
        if initialState then
            self.arrow:PointUp()
        end
    end
    
    self.contents = CreateGUIObject("contents", contentsClass, self.header,
    {
        expansionMargin = params.expansionMargin, -- prevent outer stroke effect from being cropped away.
        expanded = initialState,
    })
    
    self:HookEvent(self.contents, "OnExpansionChanged", OnExpansionChanged)
    self:HookEvent(self.contents, "OnSizeChanged", OnSizeUpdateNeeded)
    
    self:HookEvent(self, "OnOpenChanged", OnOpenChanged)
    
    self:HookEvent(self, "OnLabelChanged", OnHeaderSizeUpdateNeeded)
    OnHeaderSizeUpdateNeeded(self)
    
    self:HookEvent(self.header, "OnPressed", self.ToggleOpenOnPress)
    
end

function GUIMenuExpandableGroup:ToggleOpenOnPress()
    self:SetOpen(not self:GetOpen())
    PlayMenuSound("ButtonClick")
end
