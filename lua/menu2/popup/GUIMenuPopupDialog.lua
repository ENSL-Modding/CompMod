-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/popup/GUIMenuPopupDialog.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    GUIPopupDialog themed appropriately for the menu.
--
--  Properties:
--      Title           The text displayed for the title of this dialog box.
--  
--  Events:
--      OnClosed        The dialog was closed.  Fires _after_ button callbacks -- if any.
--      OnEscape        The dialog was closed via ESC.  Fires immediately before OnClosed, and
--                      before OnCancelled.
--      OnCancelled     The dialog was closed via a cancel button (if using default implementation)
--                      or ESC key press.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/popup/GUIPopupDialog.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/widgets/GUIMenuButton.lua")
Script.Load("lua/menu2/widgets/GUIMenuPasswordEntryWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuCheckboxWidgetLabeled.lua")
Script.Load("lua/menu2/widgets/GUIMenuScrollPane.lua")
Script.Load("lua/menu2/GUIMenuCoolBox.lua")
Script.Load("lua/menu2/GUIMenuCoolGlowBox.lua")
Script.Load("lua/GUI/GUIParagraph.lua")
Script.Load("lua/GUI/layouts/GUIListLayout.lua")

---@class GUIMenuPopupDialog : GUIPopupDialog
class "GUIMenuPopupDialog" (GUIPopupDialog)

-- Size of the outer box of the popup.
local kOuterPopupSize = Vector(1350, 750, 0)

-- Size of the region that holds the title text.
local kTitleRegionSize = Vector(kOuterPopupSize.x, 170, 0)

-- How much padding should be added to the sides of the title.
local kTitleSidesPadding = 64

-- Amount of space between outer and inner box at the bottom.
local kBottomPaddingHeight = 16

-- Amount of space between outer and inner box at both sides.
local kOuterSidesPaddingWidth = 24

-- Size of the inner box, derived from above measures.
local kInnerPopupHeight = kOuterPopupSize.y - kTitleRegionSize.y - kBottomPaddingHeight

-- Position of top edge of button holder relative to bottom edge of inner box.
local kButtonHolderYOffset = 80

-- Spacing between buttons (eg right edge of button N to left edge of button N+1)
local kButtonSpacing = 18

-- Spacing between edge of popup and edge of buttons.
local kButtonEdgePadding = 90

-- Animate button holder scale from this to 1, 1.
local kButtonHolderInitialScale = Vector(0.75, 0.75, 1)

-- Animate popup scale from this to 1, 1.
local kPopupInitialScale = Vector(0.75, 0.75, 1)

GUIMenuPopupDialog:AddCompositeClassProperty("_DarkenColor", "screenDarkener", "Color")

local function UpdateLayout(self)
    
    self.titleHolder:SetSize(self:GetSize().x, kTitleRegionSize.y)
    
    self.outerBox:SetSize(self:GetSize())
    self.outerBoxGloss:SetSize(self.outerBox:GetSize() * Vector(2, 0.5, 1))
    
    self.innerBox:SetSize(self:GetSize().x - kOuterSidesPaddingWidth * 2, kInnerPopupHeight)
    
    self.contentsHolder:SetSize(self.innerBox:GetSize().x, kInnerPopupHeight - kButtonHolderYOffset)
    
end

local function OnSizeChanged(self, size)
    UpdateLayout(self)
end

local function ComputeNeededWidthForButtons(self)
    
    local sum = kButtonEdgePadding * 2
    for i=1, #self.buttons do
        sum = sum + self.buttons[i]:GetSize().x
        if i > 1 then
            sum = sum + kButtonSpacing
        end
    end
    return sum
    
end

local function ComputeNeededWidthForTitle(self)
    return self.titleText:GetSize().x + kTitleSidesPadding * 2
end

local function UpdateSize(self)
    
    local defaultWidth = kOuterPopupSize.x
    local buttonNeededWidth = ComputeNeededWidthForButtons(self)
    
    local titleNeededWidth = ComputeNeededWidthForTitle(self)
    local neededWidth = math.max(defaultWidth, buttonNeededWidth, titleNeededWidth)
    
    local defaultHeight = kOuterPopupSize.y
    
    self:SetSize(neededWidth, defaultHeight)
    
end

local function OnButtonSizeChanged(self)
    UpdateSize(self)
end

function GUIMenuPopupDialog:CreateButton(config)
    
    local newButton = GUIPopupDialog.CreateButton(self, config)
    self:HookEvent(newButton, "OnSizeChanged", OnButtonSizeChanged)
    return newButton
    
end

local function OnTitleSizeChanged(self)
    UpdateSize(self)
end

function GUIMenuPopupDialog:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIPopupDialog.Initialize(self, params, errorDepth)
    
    -- Make screen darkening fade in rather than being instantaneous.
    self:Set_DarkenColor(self.kDarkenColor * Color(1, 1, 1, 0))
    self:AnimateProperty("_DarkenColor", self.kDarkenColor, MenuAnimations.FadeFast)
    
    -- Setup title
    self.titleHolder:SetSize(kTitleRegionSize)
    self.titleText:SetFont(MenuStyle.kDialogTitleFont)
    self.titleText:SetColor(MenuStyle.kPopupTitleColor)
    self:HookEvent(self.titleText, "OnSizeChanged", OnTitleSizeChanged)
    
    -- Setup contents
    self.contentsHolder:SetPosition(0, kTitleRegionSize.y)
    
    -- Animate buttons
    self.buttonHolder:SetPosition(0, -kButtonHolderYOffset - kBottomPaddingHeight)
    self.buttonHolder:SetAnchor(0.5, 1)
    self.buttonHolder:SetSpacing(0)
    self.buttonHolder:AnimateProperty("Spacing", kButtonSpacing, MenuAnimations.FlyIn)
    self.buttonHolder:SetHotSpot(0.5, 0.5)
    self.buttonHolder:AnimateProperty("HotSpot", Vector(0.5, 0, 0), MenuAnimations.FlyIn)
    self.buttonHolder:SetScale(kButtonHolderInitialScale)
    self.buttonHolder:AnimateProperty("Scale", Vector(1, 1, 1), MenuAnimations.FlyIn)
    
    -- Setup background
    self.outerBox = CreateGUIObject("outerBox", GUIMenuCoolBox, self)
    self.outerBox:SetLayer(-2)
    
    self.outerBoxGloss = self.outerBox:CreateGUIItem()
    self.outerBoxGloss:SetLayer(1)
    self.outerBoxGloss:SetTexture(kGlossTexture)
    self.outerBoxGloss:SetColor(MenuStyle.kGlossColor)
    self.outerBoxGloss:SetBlendTechnique(GUIItem.Add)
    self.outerBoxGloss:SetAnchor(0.5, 0.5)
    self.outerBoxGloss:SetHotSpot(0.5, 1)
    self.outerBoxGloss:SetMinCrop(0.25, 0)
    self.outerBoxGloss:SetMaxCrop(0.75, 1)
    
    self.innerBox = CreateGUIObject("innerBox", GUIMenuCoolGlowBox, self)
    self.innerBox:SetLayer(-1)
    self.innerBox:AlignTop()
    self.innerBox:SetPosition(0, kTitleRegionSize.y)
    
    -- Animate popup scale.
    local endingScale = self:GetScale() -- already adjusted for screen resolution.
    local startingScale = endingScale * kPopupInitialScale
    self:SetScale(startingScale)
    self:AnimateProperty("Scale", endingScale, MenuAnimations.FlyIn)
    
    self:HookEvent(self, "OnSizeChanged", OnSizeChanged)
    
    self:AlignCenter()
    
    UpdateSize(self)
    UpdateLayout(self)
    
end

function GUIMenuPopupDialog:GetDefaultButtonClass()
    return GUIMenuButton
end
