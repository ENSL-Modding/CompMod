-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/PlayerScreen/Badges/GUIMenuBadgeSlot.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A slot for a single badge in the BadgesCustomizer.
--
--  Parameters (* = required)
--     *customizer      The customizer that this badge slot belongs to.  Tight coupling.
--     *slotIndex       The index of this slot.
--
--  Properties
--      BadgeObj            The badge that is currently occupying this slot, or GUIObject.NoObject.
--      TentativeReplace    Whether or not the badge in the slot is about to maybe be replaced (eg
--                          the user is dragging a badge, and is currently holding it over this
--                          slot).
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/wrappers/Expandable.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

---@class GUIMenuBadgeSlot : GUIObject
---@field public GetExpanded function @From Expandable wrapper
---@field public SetExpanded function @From Expandable wrapper
---@field public GetExpansion function @From Expandable wrapper
local baseClass = GUIObject
baseClass = GetExpandableWrappedClass(baseClass)
class "GUIMenuBadgeSlot" (baseClass)

local kBadgeSize = 64
local kEmptyBadgeSlotIcon = PrecacheAsset("ui/newMenu/missing_badge_icon.dds")
local kHighlightTexture = PrecacheAsset("ui/newMenu/badgeGlowMap.dds")
local kHighlightScanlinesTexture = PrecacheAsset("models/commander_tutorial/big_arrow_scanlines.dds")
local kHighlightScaleFactor = 64 / 54
local kHighlightShader = PrecacheAsset("shaders/GUI/menu/badgeSlotGlimmer.surface_shader")
local kHighlightColor = HexToColor("43b4ff")

local kFadeTime = 0.25
local kFadeAValueMult = 1.0 / kFadeTime

local kReplaceBadgeOffsetX = 16
local kReplaceBadgeOffsetY = 48

GUIMenuBadgeSlot:AddClassProperty("BadgeObj", GUIObject.NoObject, true)

-- Whether or not the badge in the slot is about to maybe be replaced (eg the user is dragging a
-- badge, and is currently holding it over this slot).
GUIMenuBadgeSlot:AddClassProperty("_TentativeReplace", false)

-- Expansion goes from left --> right, instead of top --> bottom.
local function OnExpansionChanged(self, expansion)
    expansion = Clamp(expansion, 0, 1)
    
    if expansion == 1 and self.noCropWhenFullyVisible then
        
        self:ClearCropRectangle()
        
    else
        
        self:SetCropMin(1 - expansion, 0)
        self:SetCropMax(1, 1)
        
    end
    
end

-- Fade the missing badge icon out if the badge slot is occupied, otherwise fade it in.
local function UpdateMissingBadgeOpacity(self)
    local badgeObj = self:GetBadgeObj()
    local opacity = badgeObj == GUIObject.NoObject and 1 or 0
    self.missingBadge:AnimateProperty("Opacity", opacity, MenuAnimations.FadeFast)
end

local function OnGlimmerDoneFadingOut(self)
    self.glimmerHideCallback = nil
    self.glimmer:SetVisible(false)
end

local function SetGlimmer(self, shouldGlimmer)
    
    assert(type(shouldGlimmer) == "boolean")
    
    if shouldGlimmer == self.isGlimmering then
        return -- no change
    end
    
    -- Shader uses the following formula to calculate the opacity of the glimmer effect so we get a
    -- nice fade in and fade out when the glimmer is turned on/off, but with the ability to reverse
    -- direction in the middle of it without being jarring (eg if use clicks on a badge rapidly,
    -- turning the glimmer effect on/off very quickly doesn't result in flickering.
    --      fade = a * (time - c) + b
    -- The result of this value is clamped between 0 and 1.
    
    self.isGlimmering = shouldGlimmer
    
    local now = Shared.GetTime()
    local currentFadeValue = Clamp(self.aValue * (now - self.cValue) + self.bValue, 0, 1)
    
    self.cValue = now
    self.bValue = currentFadeValue
    
    if shouldGlimmer then
        self.aValue = kFadeAValueMult
        self.glimmer:SetVisible(true)
        
        if self.glimmerHideCallback then
            self:RemoveTimedCallback(self.glimmerHideCallback)
            self.glimmerHideCallback = nil
        end
        
    else
        self.aValue = -kFadeAValueMult
        self.glimmerHideCallback = self:AddTimedCallback(OnGlimmerDoneFadingOut, kFadeTime)
    end
    
    self.glimmer:SetFloatParameter("aValue", self.aValue)
    self.glimmer:SetFloatParameter("bValue", self.bValue)
    self.glimmer:SetFloatParameter("cValue", self.cValue)

end

local function OnDraggingBadgeObjectChanged(self)
    
    local badgeObj = self.customizer:Get_DraggingBadgeObj()
    local shouldGlimmer = false
    if badgeObj ~= GUIObject.NoObject then
        local columnsAllowed = badgeObj:GetColumns()
        shouldGlimmer = bit.band(columnsAllowed, self.columnMask) ~= 0
    end
    
    SetGlimmer(self, shouldGlimmer)
    
end

local function UpdateBadgeTentativePositioning(self)

    local badgeObj = self:GetBadgeObj()
    if badgeObj == GUIObject.NoObject then
        return
    end
    
    local tentativeReplace = self:Get_TentativeReplace()
    
    local goalPos = Vector(kBadgeSize*0.5, kBadgeSize*0.5, 0)
    if tentativeReplace then
        goalPos = goalPos + Vector(kReplaceBadgeOffsetX, kReplaceBadgeOffsetY, 0)
    end
    
    badgeObj:AnimateProperty("Position", goalPos, MenuAnimations.FlyIn)

end

local function OnBadgeObjChanged(self)
    
    UpdateBadgeTentativePositioning(self)
    UpdateMissingBadgeOpacity(self)
    
    -- Update the customizer's active badge mask (leave 7, 8, 9, 10 alone, these should always be
    -- visible, and are by default).
    if self.slotIndex < 7 then
        local customizerMask = self.customizer:Get_ActiveColumnsMask()
        local badgeObj = self:GetBadgeObj()
        if badgeObj == GUIObject.NoObject then
            customizerMask = bit.band(customizerMask, bit.bnot(self.columnMask))
        else
            customizerMask = bit.bor(customizerMask, self.columnMask)
        end
        self.customizer:Set_ActiveColumnsMask(customizerMask)
        
    end

end

local function OnCustomizerReplacingSlotChanged(self, slot)
    self:Set_TentativeReplace(slot == self)
end

local function OnCustomizerVisibleColumnsChanged(self)
    
    local visibleColumns = self.customizer:Get_VisibleColumns()
    local expand = bit.band(visibleColumns, self.columnMask) ~= 0
    
    self:SetExpanded(expand)
end

function GUIMenuBadgeSlot:GetSlotIndex()
    return self.slotIndex
end

function GUIMenuBadgeSlot:GetColumnMask()
    return self.columnMask
end

function GUIMenuBadgeSlot:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType("GUIMenuBadgesCustomizer", params.customizer, "params.customizer", errorDepth)
    RequireType("number", params.slotIndex, "params.slotIndex", errorDepth)
    
    PushParamChange(params, "noExpansionChanged", true)
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "noExpansionChanged")
    
    self.slotIndex = params.slotIndex
    self.columnMask = bit.lshift(1, self.slotIndex - 1)
    self.customizer = params.customizer
    
    -- Hook up our own expansion visuals.
    self:HookEvent(self, "OnExpansionChanged", OnExpansionChanged)
    
    self:SetSize(kBadgeSize, kBadgeSize)
    
    self.missingBadge = CreateGUIObject("missingBadge", GetTooltipWrappedClass(GUIObject), self)
    self.missingBadge:SetLayer(-1)
    self.missingBadge:SetColor(1, 1, 1, 1)
    self.missingBadge:SetTexture(kEmptyBadgeSlotIcon)
    self.missingBadge:SetSize(kBadgeSize, kBadgeSize)
    self.missingBadge:SetOpacity(1)
    self.missingBadge:SetTooltip(Locale.ResolveString("BADGE_EMPTY_SLOT"))
    
    self.glimmer = CreateGUIObject("glimmer", GUIObject, self)
    self.glimmer:SetLayer(1)
    self.glimmer:AlignCenter()
    self.glimmer:SetShader(kHighlightShader)
    self.glimmer:SetTexture(kHighlightTexture)
    self.glimmer:SetSizeFromTexture()
    self.glimmer:SetScale(kHighlightScaleFactor, kHighlightScaleFactor)
    self.glimmer:SetAdditionalTexture("scanlinesTexture", kHighlightScanlinesTexture)
    self.glimmer:SetColor(kHighlightColor)
    self.glimmer:SetVisible(false)
    self.glimmer:SetBlendTechnique(GUIItem.Add)
    self.glimmer:SetFloatParameter("timeOffset", math.random() * 10)
    
    self.isGlimmering = false
    self.aValue = 0
    self.bValue = 0
    self.cValue = 0
    
    self:HookEvent(self.customizer, "On_DraggingBadgeObjChanged", OnDraggingBadgeObjectChanged)
    self:HookEvent(self, "OnBadgeObjChanged", OnBadgeObjChanged)
    self:HookEvent(self.customizer, "On_ReplacingSlotChanged", OnCustomizerReplacingSlotChanged)
    self:HookEvent(self, "On_TentativeReplaceChanged", UpdateBadgeTentativePositioning)
    
    self:HookEvent(self.customizer, "On_VisibleColumnsChanged", OnCustomizerVisibleColumnsChanged)
    OnCustomizerVisibleColumnsChanged(self)
    
end
