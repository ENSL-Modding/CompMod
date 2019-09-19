-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/PlayerScreen/GUIMenuXPBar.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Widget that displays a fraction of the player's XP.
--
--  Properties
--      BarFrac     Fraction of the XP to display, from 0 to 1.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")

Script.Load("lua/menu2/GUIMenuNineBox.lua")

local kInnerBarInset = 6

local kGradientTexture = PrecacheAsset("ui/newMenu/xpBarGradient.dds")
local kGradientInset = 2

local kPatternTexture = PrecacheAsset("ui/newMenu/xpBarPattern.dds")
local kPatternColor = Color(0, 0, 0, 0.25)

local kStrokeColor = HexToColor("469db2")

local kGlowColor = HexToColor("1d3db3", 0.73)
local kGlowParams =
{
    texture = PrecacheAsset("ui/newMenu/nine_box_7.dds"),
    
    col0Width = 24,
    col1Width = 41,
    col2Width = 24,
    
    row0Height = 24,
    row1Height = 41,
    row2Height = 24,
    
    topLeftOffset = Vector(-17, -17, 0),
    bottomRightOffset = Vector(17, 17, 0),
    middleMinimumSize = Vector(1, 1, 0),
}

local kOuterFrameParams =
{
    texture = PrecacheAsset("ui/newMenu/nine_box_8.dds"),
    
    col0Width = 5,
    col1Width = 19,
    col2Width = 5,
    
    row0Height = 5,
    row1Height = 32,
    row2Height = 5,
    
    topLeftOffset = Vector(-6, -4, 0),
    bottomRightOffset = Vector(6, 10, 0),
    middleMinimumSize = Vector(1, 1, 0),
}

---@class GUIMenuXPBar : GUIObject
local baseClass = GUIObject
class "GUIMenuXPBar" (GUIObject)

GUIMenuXPBar:AddClassProperty("BarFrac", 0)

local function UpdateSize(self)

    local size = self:GetSize()
    local barFraction = self:GetBarFrac()
    
    local innerSize = size - Vector(kInnerBarInset*2, kInnerBarInset*2, 0)
    innerSize.x = innerSize.x * barFraction
    
    self.gradient:SetSize(innerSize.x - kGradientInset*2, innerSize.y - kGradientInset*2)
    self.gradient:SetTextureCoordinates(0, 0, barFraction, 1)
    
    self.pattern:SetSize(innerSize.x - kGradientInset*2, innerSize.y - kGradientInset*2)
    self.pattern:SetTexturePixelCoordinates(0, 0, self.pattern:GetSize().x, self.pattern:GetSize().y)
    
    self.stroke:SetSize(innerSize)
    
    self.glow:SetSize(innerSize)
    
end

function GUIMenuXPBar:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.gradient = self:CreateGUIItem()
    self.gradient:SetTexture(kGradientTexture)
    self.gradient:SetLayer(1)
    self.gradient:AlignLeft()
    self.gradient:SetPosition(kGradientInset + kInnerBarInset, 0)
    
    self.pattern = self:CreateGUIItem()
    self.pattern:SetTexture(kPatternTexture)
    self.pattern:SetColor(kPatternColor)
    self.pattern:SetLayer(2)
    self.pattern:AlignLeft()
    self.pattern:SetPosition(kGradientInset + kInnerBarInset, 0)
    
    self.stroke = self:CreateGUIItem()
    self.stroke:SetColor(kStrokeColor)
    self.stroke:AlignLeft()
    self.stroke:SetPosition(kInnerBarInset, 0)
    
    self.glow = CreateGUIObject("glow", GUIMenuNineBox, self, kGlowParams)
    self.glow:SetBlendTechnique(GUIItem.Add)
    self.glow:SetColor(kGlowColor)
    self.glow:AlignLeft()
    self.glow:SetLayer(3)
    self.glow:SetPosition(kInnerBarInset, 0)
    
    self.outerFrame = CreateGUIObject("outerFrame", GUIMenuNineBox, self, kOuterFrameParams)
    self.outerFrame:HookEvent(self, "OnSizeChanged", self.outerFrame.SetSize)
    self.outerFrame:SetLayer(-1)
    
    self:HookEvent(self, "OnSizeChanged", UpdateSize)
    self:HookEvent(self, "OnBarFracChanged", UpdateSize)
    
end
