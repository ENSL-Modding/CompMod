-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuTooltip.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Singleton GUIObject that appears when the users mouse cursor is hovering over something.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/GUIParagraph.lua")
Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")

Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")

---@class GUIMenuTooltip : GUIObject
class "GUIMenuTooltip" (GUIObject)

GUIMenuTooltip.kMaxWidth = 600
GUIMenuTooltip.kMargin = 16
GUIMenuTooltip.kMinScale = 0.5

GUIMenuTooltip.kBackgroundOpacityFactor = 1.0

local tooltip
function GetTooltip()
    if not tooltip then
        tooltip = CreateGUIObject("tooltipObj", GUIMenuTooltip)
    end
    return tooltip
end

local function UpdateResolutionScaling(self, newX, newY, oldX, oldY)
    
    local mockupRes = Vector(3840, 2160, 0)
    local res = Vector(newX, newY, 0)
    local scale = res / mockupRes
    scale = math.min(scale.x, scale.y)
    scale = math.max(scale, GUIMenuTooltip.kMinScale)
    
    self:SetScale(scale, scale)
    
end

local function UpdateHotspot(self)
    
    local position = self:GetPosition()
    local localSize = self:GetSize() * self:GetScale()
    
    -- Default to bottom-left corner.
    local desiredHotSpotX = 0
    local desiredHotSpotY = 1
    
    -- Move tooltip to left of cursor to keep it from going off the right side of the screen.
    if position.x + localSize.x > Client.GetScreenWidth() then
        desiredHotSpotX = 1
    end
    
    -- Move tooltip to below the cursor to keep it from going off the top of the screen.
    if position.y - localSize.y < 0 then
        desiredHotSpotY = 0
    end
    
    local currentHotSpotGoal = self:GetHotSpot(true) -- static get.
    if currentHotSpotGoal.x ~= desiredHotSpotX or currentHotSpotGoal.y ~= desiredHotSpotY then
        self:AnimateProperty("HotSpot", Vector(desiredHotSpotX, desiredHotSpotY, 0), MenuAnimations.FlyIn)
    end
    
end

local function UpdateIconTextureSize(self)
    
    if not self.icon:GetVisible() then
        return -- not visible, don't care.
    end
    
    if self.icon:GetTexture() == "" then
        return -- no texture, don't care.
    end
    
    local textureSize = self.icon:GetTextureSize()
    if textureSize.x <= 0 or textureSize.y <= 0 then
        return -- texture size invalid, don't care.
    end
    
    local tooltipInvScale = 1.0 / self:GetScale()
    tooltipInvScale = math.min(tooltipInvScale.x, tooltipInvScale.y)
    
    local scaleToFitWidth = self.kMaxWidth / textureSize.x
    local scale = math.min(tooltipInvScale, scaleToFitWidth)
    
    self.icon:SetSizeFromTexture()
    self.icon:SetScale(scale, scale)
    
end

function GUIMenuTooltip:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self:SetLayer(GetLayerConstant("Tooltip", 9999))
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:SetLayer(-1)
    self.back:SetOpacity(0)
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self,
    {
        orientation = "vertical",
        spacing = self.kMargin,
        align = "center",
    })
    
    self.text = CreateGUIObject("text", GUIParagraph, self.layout)
    self.text:SetLayer(1)
    self.text:AlignTop()
    self.text:SetParagraphSize(self.kMaxWidth, -1)
    self.text:SetFont(MenuStyle.kTooltipFont)
    self.text:SetColor(MenuStyle.kTooltipText)
    
    self.icon = CreateGUIObject("icon", GUIObject, self.layout)
    self.icon:SetLayer(1)
    self.icon:AlignTop()
    self.icon:SetColor(1, 1, 1, 1)
    self.icon:SetVisible(false) -- invisible until we've assigned a texture to it.
    -- Icon will scale uniformly up to 100% scale to fit within the width of the tooltip (max width
    -- of paragraph text).
    self:HookEvent(self.icon, "OnTextureChanged", UpdateIconTextureSize)
    self:HookEvent(self.icon, "OnVisibleChanged", UpdateIconTextureSize)
    self:HookEvent(self, "OnScaleChanged", UpdateIconTextureSize)
    
    -- Update scaling with screen resolution
    self:HookEvent(GetGlobalEventDispatcher(), "OnResolutionChanged", UpdateResolutionScaling)
    UpdateResolutionScaling(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
    -- Position the tooltip on the mouse cursor
    self:HookEvent(GetGlobalEventDispatcher(), "OnMousePositionChanged", self.SetPosition)
    
    -- Alter the hotspot of the tooltip to keep it from going off the edge of the screen.
    self:HookEvent(self, "OnPositionChanged", UpdateHotspot)
    self:HookEvent(self, "OnSizeChanged", UpdateHotspot)
    self:HookEvent(self, "OnScaleChanged", UpdateHotspot)
    
    -- Sync background size to tooltip size.
    self.back:HookEvent(self, "OnSizeChanged", self.back.SetSize)
    
    -- Sync size to layout size.
    self:HookEvent(self.layout, "OnSizeChanged",
        function(self, size, oldSize)
            self:SetSize(size.x + self.kMargin * 2, size.y + self.kMargin * 2)
        end)
    
    self:HookEvent(self, "OnOpacityChanged",
        function(self, opacity, prevOpacity)
            self.back:SetOpacity(opacity * GUIMenuTooltip.kBackgroundOpacityFactor)
            self.text:SetOpacity(opacity)
            self.icon:SetOpacity(opacity)
        end)
    
    -- Start faded out.
    self:SetOpacity(0)
    
end

local function GetCurrentHoverObject(self)
    
    return self.currentHoverObject
    
end

local function UpdateTooltipOpacityAnimation(self)
    
    local desiredOpacity = 0.0
    if self.currentHoverObject then
        local text = self.currentHoverObject:GetTooltip()
        local icon = self.currentHoverObject:GetTooltipIcon()
        if text ~= "" or icon ~= "" then
            desiredOpacity = 1.0
        end
    end
    
    local currentOpacity = self:GetOpacity(true)
    if currentOpacity ~= desiredOpacity then
        self:AnimateProperty("Opacity", desiredOpacity, MenuAnimations.Fade)
    end

end

local function UpdateTooltipText(self, text)
    
    if text == "" then
        self:AnimateProperty("Opacity", 0.0, MenuAnimations.Fade)
    else
        self.text:SetText(text)
    end
    UpdateTooltipOpacityAnimation(self)
    
end

local function UpdateTooltipIcon(self, icon)
    
    if icon == "" then
        self:AnimateProperty("Opacity", 0.0, MenuAnimations.Fade)
    else
        self.icon:SetTexture(icon)
    end
    UpdateTooltipOpacityAnimation(self)
    
end

local function OnHoverObjectChanged(self)
    
    if self.currentHoverObject then
        
        local text = self.currentHoverObject:GetTooltip()
        if text == "" then
            self.text:SetVisible(false)
        else
            self.text:SetText(text)
            self.text:SetVisible(true)
        end
        
        local icon = self.currentHoverObject:GetTooltipIcon()
        if icon == "" then
            self.icon:SetVisible(false)
        else
            self.icon:SetTexture(icon)
            self.icon:SetVisible(true)
        end
        
        -- Allow tooltip objects to change text and icon at any time.  First, unhook previous event.
        self:UnHookEvent(nil, "OnTooltipChanged", UpdateTooltipText)
        self:UnHookEvent(nil, "OnTooltipIconChanged", UpdateTooltipIcon)
        self:HookEvent(self.currentHoverObject, "OnTooltipChanged", UpdateTooltipText)
        self:HookEvent(self.currentHoverObject, "OnTooltipIconChanged", UpdateTooltipIcon)
        
    end
    
    UpdateTooltipOpacityAnimation(self)
    
end

local function ClearCurrentHoverObject(self)
    
    local currentObj = GetCurrentHoverObject(self)
    if currentObj == nil then
        return
    end
    
    self.currentHoverObject = nil
    OnHoverObjectChanged(self)
    
end

function GUIMenuTooltip:SetCurrentHoverObject(obj)
    
    if obj ~= nil then
        AssertIsaGUIObject(obj)
    end
    
    local currentObj = GetCurrentHoverObject(self)
    if obj == currentObj then
        return -- already the current object
    elseif currentObj ~= nil then
        ClearCurrentHoverObject(self)
    end
    
    self.currentHoverObject = obj
    OnHoverObjectChanged(self)
    
end

function GUIMenuTooltip:OnTooltipObjectDestroyed(obj)
    
    local self = GetTooltip()
    local currentObj = GetCurrentHoverObject(self)
    if obj == currentObj then
        ClearCurrentHoverObject(self, obj)
    end
    
end


