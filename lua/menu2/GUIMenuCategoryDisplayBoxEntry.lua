-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/GUIMenuCategoryDisplayBoxEntry.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A single entry in the categories list (left side list).
--
--  Parameters (* = required)
--      label
--
--  Properties:
--      Label               Text to display for this entry.
--      IndexEven           Whether or not this is an even-numbered entry in the list (determines
--                          color).
--      Selected            Whether or not this entry is selected (determines color).
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIButton.lua")

Script.Load("lua/GUI/wrappers/FXState.lua")

Script.Load("lua/menu2/GUIMenuTruncatedText.lua")
Script.Load("lua/menu2/GUIMenuText.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")

Script.Load("lua/menu2/wrappers/MenuFX.lua")

---@class GUIMenuCategoryDisplayBoxEntry : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuCategoryDisplayBoxEntry" (baseClass)

local kHeight = 166
local kLabelSpacing = 48
local kArrowWidth = 48
local kArrowTexture = PrecacheAsset("ui/newMenu/arrow_sideways_big.dds")

local kOddColor = HexToColor("181b21", 0.4)
local kEvenColor = HexToColor("14141b", 0.3)

GUIMenuCategoryDisplayBoxEntry:AddCompositeClassProperty("Label", "label", "Text")
GUIMenuCategoryDisplayBoxEntry:AddClassProperty("IndexEven", false)
GUIMenuCategoryDisplayBoxEntry:AddClassProperty("Selected", false)
GUIMenuCategoryDisplayBoxEntry:AddCompositeClassProperty("_ArrowColor", "arrowGraphic", "Color")

local function UpdateLabelSize(self)
    
    local labelSize = self.label:GetTextSize()
    local entryWidth = self:GetSize().x
    
    local spaceForLabel = entryWidth - kLabelSpacing*3 - kArrowWidth
    
    local labelWidth = math.min(spaceForLabel, labelSize.x)
    self.label:SetSize(labelWidth, labelSize.y)

end
GUIMenuCategoryDisplayBoxEntry._UpdateLabelSizeCallbackFunc = UpdateLabelSize

local function AnimateBackgroundColor(self, color, strokeColor)
    self.back:AnimateProperty("FillColor", color, MenuAnimations.FadeFast)
    self.back:AnimateProperty("StrokeColor", strokeColor, MenuAnimations.FadeFast)
end

local function UpdateColors(self)
    local selected = self:GetSelected()
    local indexEven = self:GetIndexEven()
    
    if selected then
        self.back:ClearPropertyAnimations("FillColor")
        self.back:ClearPropertyAnimations("StrokeColor")
        self.back:SetFillColor(MenuStyle.kHighlightBackground)
        self.back:SetStrokeColor(MenuStyle.kHighlightStrokeColor)
    elseif indexEven then
        AnimateBackgroundColor(self, kEvenColor, MenuStyle.kBasicStrokeColor)
    else
        AnimateBackgroundColor(self, kOddColor, MenuStyle.kBasicStrokeColor)
    end
    
    local opacity = selected and 1 or 0
    local goalColor = MenuStyle.kHighlight * Color(1, 1, 1, opacity)
    if selected then
        self:ClearPropertyAnimations("_ArrowColor")
        self:Set_ArrowColor(goalColor)
    else
        self:AnimateProperty("_ArrowColor", goalColor, MenuAnimations.FadeFast)
    end

end

function GUIMenuCategoryDisplayBoxEntry:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.label = CreateGUIObject("label", GUIMenuTruncatedText, self,
    {
        cls = GUIMenuText,
        defaultColor = MenuStyle.kOptionHeadingColor,
    })
    self.label:AlignLeft()
    self.label:SetPosition(kLabelSpacing, 0)
    self.label:SetFont(MenuStyle.kOptionHeadingFont)
    self:AddFXReceiver(self.label:GetObject())
    self:HookEvent(self.label, "OnTextSizeChanged", UpdateLabelSize)
    self:HookEvent(self, "OnSizeChanged", UpdateLabelSize)
    
    self.arrowGraphic = self:CreateGUIItem()
    self.arrowGraphic:SetTexture(kArrowTexture)
    self.arrowGraphic:SetSizeFromTexture()
    self.arrowGraphic:SetAnchor(1, 0.5)
    self.arrowGraphic:SetHotSpot(0.5, 0.5)
    self.arrowGraphic:SetPosition(-kArrowWidth*0.5, 0)
    self:Set_ArrowColor(MenuStyle.kHighlight * Color(1, 1, 1, 0))
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:SetLayer(-1)
    self.back:HookEvent(self, "OnSizeChanged", self.back.SetSize)
    
    self:HookEvent(self, "OnSelectedChanged", UpdateColors)
    self:HookEvent(self, "OnIndexEvenChanged", UpdateColors)
    UpdateColors(self)
    
    self:SetSize(self:GetSize().x, kHeight)
    
    if params.label then
        self:SetLabel(params.label)
    end

end
