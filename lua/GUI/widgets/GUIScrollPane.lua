-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/widgets/GUIScrollPane.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Creates an area for GUIObjects/GUIItems to be arranged.  Shows scrollbars when necessary, and
--    crops the contents to the area of the pane.
--  
--  Parameters (* = required)
--      horizontalScrollBarEnabled
--     *scrollBarClass                  Class to use for the scrollbars.
--      verticalScrollBarEnabled
--  
--  Properties:
--      PaneSize                        The size of the area where GUIItems and GUIObjects can be
--                                      placed.  They can be placed outside of the pane bounds, but
--                                      they won't be able to be scrolled-to.  This just sets the
--                                      size of the area that the scroll bars work with.
--      PanePosition                    The position of the pane which items and objects are placed
--                                      in.  Set by the scrollbars, should only be "Get" using this.
--      ContentsSize                    The size of the viewable area.  This is equivalent to the
--                                      size of the scroll pane minus the area that the scrollbars
--                                      cover.  Set automatically, should only get "Get" using this.
--      HorizontalScrollBarEnabled      Whether or not a horizontal scroll bar should be used.
--                                      Defaults to true.
--      VerticalScrollBarEnabled        Whether or not a vertical scroll bar should be used.
--                                      Defaults to true.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")

---@class GUIScrollPane : GUIObject
class "GUIScrollPane" (GUIObject)

local kDefaultSize = Vector(256, 256, 0)
local kDefaultPaneSize = Vector(512, 512, 0)
local kDefaultScrollBarThickness = 32

GUIScrollPane:AddCompositeClassProperty("PaneSize", "paneItem", "Size")
GUIScrollPane:AddCompositeClassProperty("PanePosition", "paneItem", "Position")
GUIScrollPane:AddCompositeClassProperty("ContentsSize", "contentsItem", "Size")
GUIScrollPane:AddClassProperty("HorizontalScrollBarEnabled", true)
GUIScrollPane:AddClassProperty("VerticalScrollBarEnabled", true)

function GUIScrollPane:GetChildHoldingItem()
    AssertIsNotDestroyed(self)
    return self.paneItem or self.rootItem
end

function GUIScrollPane:GetContentsItem()
    AssertIsNotDestroyed(self)
    return self.contentsItem
end

function GUIScrollPane:SetHorizontalScrollBarVisible(state)
    self.hBar:SetVisible(state)
end

function GUIScrollPane:SetVerticalScrollBarVisible(state)
    self.vBar:SetVisible(state)
end

function GUIScrollPane:GetScrollBarThickness()
    return kDefaultScrollBarThickness
end

local function UpdateScrolling(self)
    
    local hScroll = 0
    if self:GetHorizontalScrollBarEnabled() then
        hScroll = self.hBar:GetValue(true)
    end
    
    local vScroll = 0
    if self:GetVerticalScrollBarEnabled() then
        vScroll = self.vBar:GetValue(true)
    end
    
    self:ScrollToLocation(hScroll, vScroll)
    
end

local function UpdateScrollBarsSizes(self)
    
    -- Compute the size of the area for each scroll bar, taking into account the amount of space
    -- each scroll bar takes up.
    local hBarThickness = 0
    local vBarThickness = 0
    if self:GetHorizontalScrollBarEnabled() and self.hBar:GetTotalRange() > self.hBar:GetViewRange() then
        hBarThickness = self:GetScrollBarThickness()
        self:SetHorizontalScrollBarVisible(true)
    else
        self:SetHorizontalScrollBarVisible(false)
    end
    
    if self:GetVerticalScrollBarEnabled() and self.vBar:GetTotalRange() > self.vBar:GetViewRange() then
        vBarThickness = self:GetScrollBarThickness()
        self:SetVerticalScrollBarVisible(true)
    else
        self:SetVerticalScrollBarVisible(false)
    end
    
    local contentsWidth = self:GetSize().x - vBarThickness
    local contentsHeight = self:GetSize().y - hBarThickness
    self:SetContentsSize(contentsWidth, contentsHeight)
    
    if self:GetHorizontalScrollBarEnabled() then
        self.hBar:SetSize(contentsWidth, hBarThickness)
        self.hBar:SetTotalRange(self:GetPaneSize().x)
        self.hBar:SetViewRange(self:GetSize().x)
    end
    
    if self:GetVerticalScrollBarEnabled() then
        self.vBar:SetSize(vBarThickness, contentsHeight)
        self.vBar:SetTotalRange(self:GetPaneSize().y)
        self.vBar:SetViewRange(self:GetSize().y)
    end
    
end

local function UpdateScrollBarsValuesFromCurrentScrolling(self)
    
    if self:GetHorizontalScrollBarEnabled() then
        local hScroll = -self.paneItem:GetPosition().x
        self.hBar:SetValue(hScroll)
    end
    
    if self:GetVerticalScrollBarEnabled() then
        local vScroll = -self.paneItem:GetPosition().y
        self.vBar:SetValue(vScroll)
    end
    
end

local function OnPaneSizeChanged(self)
    UpdateScrollBarsSizes(self)
    UpdateScrollBarsValuesFromCurrentScrolling(self)
end

-- Override for animations.
function GUIScrollPane:ScrollToLocation(p1, p2, p3)
    local pos = ProcessVectorInput(p1, p2, p3)
    self:SetPanePosition(-pos)
end

function GUIScrollPane:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireClassIsa("GUIScrollBarWidget", params.scrollBarClass, "params.scrollBarClass", errorDepth)
    
    RequireType({"boolean", "nil"}, params.horizontalScrollBarEnabled, "params.horizontalScrollBarEnabled", errorDepth)
    RequireType({"boolean", "nil"}, params.verticalScrollBarEnabled, "params.verticalScrollBarEnabled", errorDepth)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self:SetSize(kDefaultSize)
    
    -- The item inside of which the contents of the pane are viewable (== size of widget minus the
    -- area taken up by the scroll bars).
    self.contentsItem = self:CreateLocatorGUIItem()
    self.contentsItem:SetCropMaxCornerNormalized(1, 1)
    
    self.paneItem = self:CreateLocatorGUIItem(self.contentsItem)
    self.paneItem:SetSize(Vector(kDefaultPaneSize))
    
    PushParamChange(params, "orientation", "horizontal")
    self.hBar = CreateGUIObject("hBar", params.scrollBarClass, self:GetRootItem(), params)
    PopParamChange(params, "orientation")
    self.hBar:AlignBottomLeft()
    
    PushParamChange(params, "orientation", "vertical")
    self.vBar = CreateGUIObject("vBar", params.scrollBarClass, self:GetRootItem(), params)
    PopParamChange(params, "orientation")
    self.vBar:AlignTopRight()
    
    self:HookEvent(self, "OnSizeChanged", UpdateScrollBarsSizes)
    self:HookEvent(self, "OnPaneSizeChanged", OnPaneSizeChanged)
    self:HookEvent(self, "OnHorizontalScrollBarEnabledChanged", UpdateScrollBarsSizes)
    self:HookEvent(self, "OnVerticalScrollBarEnabledChanged", UpdateScrollBarsSizes)
    
    self:HookEvent(self.hBar, "OnViewRangeChanged", UpdateScrollBarsSizes)
    self:HookEvent(self.hBar, "OnTotalRangeChanged", UpdateScrollBarsSizes)
    self:HookEvent(self.vBar, "OnViewRangeChanged", UpdateScrollBarsSizes)
    self:HookEvent(self.vBar, "OnTotalRangeChanged", UpdateScrollBarsSizes)
    
    self:HookEvent(self.hBar, "OnValueChanged", UpdateScrolling)
    self:HookEvent(self.vBar, "OnValueChanged", UpdateScrolling)
    
    if params.horizontalScrollBarEnabled == false then
        self:SetHorizontalScrollBarEnabled(false)
    end
    
    if params.verticalScrollBarEnabled == false then
        self:SetVerticalScrollBarEnabled(false)
    end
    
    UpdateScrollBarsSizes(self)
    UpdateScrolling(self)
    
    self:ListenForWheelInteractions()
    
end

function GUIScrollPane:IsPointOverObject(pt)
    
    local localMousePos = self:ScreenSpaceToLocalSpace(pt)
    
    -- Check if too far right (over vertical scrollbar).
    if self:GetHorizontalScrollBarEnabled() and localMousePos.x >= self:GetSize().x - self:GetScrollBarThickness() then
        return false
    end
    
    -- Check if too far down (over horizontal scrollbar).
    if self:GetVerticalScrollBarEnabled() and localMousePos.y >= self:GetSize().y - self:GetScrollBarThickness() then
        return false
    end
    
    return true
    
end

function GUIScrollPane:OnMouseWheel(up)
    
    -- Only consume event if scrolling occurred.
    if self:GetVerticalScrollBarEnabled() then
        -- Only scroll vertically
        local result = self.vBar:Scroll(up)
        return result
    else
        if self:GetHorizontalScrollBarEnabled() then
            -- Vertical disabled, Horizontal enabled.
            local result = self.hBar:Scroll(up)
            return result
        else
            -- No scroll bars enabled.
            return false
        end
    end
    
end

-- Convenience.  Calls SetPaneSize() on this object, but with the height value set to GetPaneSize().y.
function GUIScrollPane:SetPaneWidth(widthOrVector)
    
    RequireType({"number", "Vector"}, widthOrVector, "widthOrVector")
    
    local widthActual
    if type(widthOrVector) == "number" then
        widthActual = widthOrVector
    else
        widthActual = widthOrVector.x
    end
    
    return (self:SetPaneSize(widthActual, self:GetPaneSize().y))
    
end

-- Convenience.  Calls SetPaneSize() on this object, but with the width value set to GetPaneSize().x.
function GUIScrollPane:SetPaneHeight(heightOrVector)
    
    RequireType({"number", "Vector"}, heightOrVector, "heightOrVector")
    
    local heightActual
    if type(heightOrVector) == "number" then
        heightActual = heightOrVector
    else
        heightActual = heightOrVector.y
    end
    
    return (self:SetPaneSize(self:GetPaneSize().x, heightActual))

end
