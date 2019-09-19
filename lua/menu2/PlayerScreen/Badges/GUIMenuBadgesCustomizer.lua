-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/PlayerScreen/Badges/GUIMenuBadgesCustomizer.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Small sub-screen that allows the player to choose which of their earned badges are displayed,
--    with a simple drag + drop style interface.  The interface has two modes: display, and edit.
--    When in display mode, the interface consists only of the badges/columns the player has
--    selected, but always displaying at least 4 badge slots at a minimum (uses a "missing badge"
--    texture if necessary).  If the player clicks on the display, it expands to reveal a tray full
--    of available badges, and will expand to show empty slots that can be filled by one or more
--    badges available in the tray.  For example, there is a hard-limit of 10 badge columns, but if
--    the player only has badges that are allowed in 4 of those columns, we only show those 4
--    columns when the widget is fully expanded.
--
--  Properties
--      AvailableBadges     An UnorderedSet of all the badge names available to the player to be
--                          used in this widget, including active badges.  This will typically just
--                          be the set of all badges this player owns, but will also include any
--                          extra badges added by server mods (eg Shine Epsilon Badges).
--      Open                Whether or not the widget is in its "open" state, with tray visible.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/UnorderedSet.lua")
Script.Load("lua/OrderedSet.lua")

Script.Load("lua/GUI/GUIObject.lua")

Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/widgets/GUIMenuScrollPane.lua")

Script.Load("lua/menu2/PlayerScreen/Badges/GUIMenuCustomizableBadge.lua")
Script.Load("lua/menu2/PlayerScreen/Badges/GUIMenuBadgeSlot.lua")

---@class GUIMenuBadgesCustomizer : GUIButton
---@field public GetEditing function @From Editable wrapper
---@field public SetEditing function @From Editable wrapper
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
baseClass = GetTooltipWrappedClass(baseClass)
class "GUIMenuBadgesCustomizer" (baseClass)

local badgeCustomizer
function GetBadgeCustomizer()
    return badgeCustomizer
end

-- Helper class that allows widget to be detached so as to display on top of all other gui stuff
-- when being edited.
local widgetProperBaseClass = GUIObject
widgetProperBaseClass = GetEditableWrappedClass(widgetProperBaseClass)
class "GUIMenuBadgesCustomizer_proper" (widgetProperBaseClass)

local kBadgeSize = 64
local kSpacing = 8

-- Tray of inactive/unused badges.
local kTrayColumnCount = 10
local kTrayRowCount = 4 -- number of rows displayed at once -- you'll be able to scroll.
local kTraySize = Vector((kBadgeSize + kSpacing) * kTrayColumnCount + kSpacing,
                         (kBadgeSize + kSpacing) * kTrayRowCount + kSpacing, 0)

-- Extra space around tray holder when open to prevent outer-effects from getting cropped.
local kTrayHolderMargin = 8

local kDraggingBadgeLayer = 3
local kMovingBadgeLayer = 2
local kBadgeLayer = 1

-- Mask of vanilla badge columns.  Also the minimum columns that must be shown at all times.
local kVanillaMask = 0x3C0 -- bits 7, 8, 9, 10

GUIMenuBadgesCustomizer:AddCompositeClassProperty("Editing", "widgetProper")

GUIMenuBadgesCustomizer:AddClassProperty("AvailableBadges", UnorderedSet(), true)
GUIMenuBadgesCustomizer:AddClassProperty("Open", false)

-- Used to determine where in the tray to add the next new badge object.  Also helps drive the size
-- of the tray itself.
GUIMenuBadgesCustomizer:AddClassProperty("_CurrentTrayColumn", 0)
GUIMenuBadgesCustomizer:AddClassProperty("_CurrentTrayRow", 0)

-- The 0..1 fraction of how open the tray is.
GUIMenuBadgesCustomizer:AddClassProperty("_OpenFrac", 0)

-- The badge object currently being dragged, if any... otherwise GUIObject.NoObject
GUIMenuBadgesCustomizer:AddClassProperty("_DraggingBadgeObj", GUIObject.NoObject, true)

-- The slot the dragging badge is hovering closest to, if any, otherwise GUIObject.NoObject
GUIMenuBadgesCustomizer:AddClassProperty("_ReplacingSlot", GUIObject.NoObject, true)

-- Bitmask of all slots that should be visible (expanded).
GUIMenuBadgesCustomizer:AddClassProperty("_VisibleColumns", kVanillaMask)

-- Bitmask of all slots that _could_ be occupied based on which badges the user has available to
-- them.
GUIMenuBadgesCustomizer:AddClassProperty("_AvailableColumnsMask", kVanillaMask)

-- Table of length kMaxBadgeColumns with each element being the number of badges that can be placed
-- in the corresponding slot.
GUIMenuBadgesCustomizer:AddClassProperty("_SlotEligibleCounts", {}, true)

-- Bitmask of all slots that currently have badges assigned to them.
GUIMenuBadgesCustomizer:AddClassProperty("_ActiveColumnsMask", kVanillaMask)

local function UpdateDimmerSize(dimmer, newX, newY)
    dimmer:SetSize(newX, newY)
end

local function UpdateScrollPaneWidth(self)
    
    local width = self.trayScrollPane:GetSize().x
    local contentsWidth = self.trayScrollPane:GetContentsSize().x
    local scrollBarWidth = width - contentsWidth
    local idealWidth = kTraySize.x -- width without scroll bar.
    self.trayScrollPane:SetWidth(idealWidth + scrollBarWidth)
    
end

-- Tray automatically changes its height to accommodate more badges if needed.
local function UpdateTrayHeight(self)
    
    local row = self:Get_CurrentTrayRow()
    local col = self:Get_CurrentTrayColumn()
    
    -- If there's nothing on the row yet, don't count it!
    if col == 0 and row > 0 then
        row = row - 1
    end
    
    local height = (kSpacing + kBadgeSize) * (row + 1) + kSpacing
    
    self.tray:SetHeight(math.max(height, kTraySize.y))
    
end

local function UpdateTrayOpenFrac(self)
    
    local openFrac = self:Get_OpenFrac()
    
    local openSize = self.trayBack:GetSize() + Vector(kTrayHolderMargin * 2, kTrayHolderMargin * 2, 0)
    self.trayExpansionHolder:SetSize(openSize * openFrac)
    
    if openFrac > 0.95 then
        self.trayExpansionHolder:SetCropMin(0, 0)
        self.trayExpansionHolder:SetCropMax(1, 1)
    elseif openFrac < 0.05 then
        self.trayExpansionHolder:SetCropMin(0, 0)
        self.trayExpansionHolder:SetCropMax(0, 0)
    else
        local marginX = kTrayHolderMargin / self.trayBack:GetSize().x / math.max(openFrac, 0.01)
        local marginY = kTrayHolderMargin / self.trayBack:GetSize().y / math.max(openFrac, 0.01)
        self.trayExpansionHolder:SetCropMin(marginX, marginY)
        self.trayExpansionHolder:SetCropMax(1.0 - marginX, 1.0 - marginY)
    end

end

local function OnBadgeObjectDragBegin(self, badgeObj)
    
    -- If tray isn't open, open it now.
    self:SetOpen(true)
    
    self:Set_DraggingBadgeObj(badgeObj)
    
    -- Ensure the badge isn't in any slots anymore.
    for i=1, #self.badgeSlots do
        local slot = self.badgeSlots[i]
        if slot:GetBadgeObj() == badgeObj then
            slot:SetBadgeObj(GUIObject.NoObject)
            
            -- Inform other system that we're removing this badge.
            SelectBadge(gBadges.disabled, i)
        end
    end
    
    -- Change the badge's parent to this widget, so it doesn't get cropped-out by the scroll pane.
    if badgeObj:GetParent() ~= self then
        badgeObj:SetParent(self.widgetProper)
    end
    
    -- Stop the badge from animating position (if it was).
    if badgeObj:GetIsAnimationPlaying("Position") then
        local posNow = badgeObj:GetPosition()
        badgeObj:ClearPropertyAnimations("Position")
        badgeObj:SetPosition(posNow)
    end
    
    -- Set the badge's layer so that it is on top of all the other badges.
    badgeObj:SetLayer(kDraggingBadgeLayer)

end

-- Returns the index of the slot closest to the badgeObj being dragged, or 0 if it is not being
-- dragged in-bounds, or if it is too far away from the nearest slot.
local function GetValidBadgeSlotIndexForDrag(self, badgeObj)
    
    local badgePos = badgeObj:GetPosition()
    
    -- Perform a quick out of bounds check.  If the badge isn't over the widget at all, it will not
    -- perform any replacements.
    if badgePos.x < 0 or badgePos.y < 0 or badgePos.x >= self.badgeSlotsHolder:GetSize().x or badgePos.y >= self.badgeSlotsHolder:GetSize().y then
        return 0
    end
    
    -- Figure out which badge slot is closest to the center of the badge being dragged.  Only need
    -- to check x-distance, since they're all inline with each other.  Only check slots that this
    -- badge is compatible with.
    local closestDist
    local closest = 0
    for i=1, #self.badgeSlots do
        local slot = self.badgeSlots[i]
        local slotPos = slot:GetPosition() + slot:GetSize() * slot:GetScale() * 0.5
        local dist = math.abs(badgePos.x - slotPos.x)
        
        if slot:GetExpanded() and
           bit.band(slot:GetColumnMask(), badgeObj:GetColumns()) ~= 0 and
           (closestDist == nil or dist < closestDist) then
            
            closest = i
            closestDist = dist
            
        end
    end
    
    return closest
    
end

local function OnBadgeObjectDrag(self, badgeObj)
    
    local closestSlotIndex = GetValidBadgeSlotIndexForDrag(self, badgeObj)
    local closestSlot = self.badgeSlots[closestSlotIndex] or GUIObject.NoObject
    self:Set_ReplacingSlot(closestSlot)
    
end

local function OnBadgeReturnAnimationStage2Finished(badgeObj, animationLayerName)
    
    if animationLayerName ~= "badgeReturnStage2End" then
        return
    end
    
    badgeObj:UnHookEvent(badgeObj, "OnAnimationFinished", OnBadgeReturnAnimationStage2Finished)
    badgeObj:SetLayer(kBadgeLayer)

end

local function BadgeNormalReturnAnimationStage2Check(self, badgeObj)
    
    -- Test if the center of the badge is inside the tray.  Yes, this will cut it off slightly as
    -- it enters if it has edges or corners still partially outside, but it happens so fast that I
    -- doubt it will matter.
    local ssBadgePos = badgeObj:GetParent():LocalSpaceToScreenSpace(badgeObj:GetPosition())
    local ssTrayMinCorner = self.trayScrollPane:GetContentsItem():GetScreenPosition()
    local ssTrayMaxCorner = ssTrayMinCorner + self.trayScrollPane:GetContentsItem():GetAbsoluteSize()
    
    if (ssBadgePos.x >= ssTrayMinCorner.x and
        ssBadgePos.y >= ssTrayMinCorner.y and
        ssBadgePos.x <  ssTrayMaxCorner.x and
        ssBadgePos.y <  ssTrayMaxCorner.y) or
        self.widgetProper:GetEditing() == false then
        
        -- Inside the box.  Re-parent to tray.  Remove this callback.
        self:UnHookEvent(badgeObj, "OnPositionChanged", badgeObj.animStage2Func)
        badgeObj.animStage2Func = nil
        
        badgeObj:SetParent(self.tray)
        
        local badgeLocalPos = self.tray:ScreenSpaceToLocalSpace(ssBadgePos)
        badgeObj:ClearPropertyAnimations("Position")
        badgeObj:SetPosition(badgeLocalPos)
        
        badgeObj:AnimateProperty("Position", badgeObj.positionInTray, MenuAnimations.FlyIn, "badgeReturnStage2End")
        badgeObj:HookEvent(badgeObj, "OnAnimationFinished", OnBadgeReturnAnimationStage2Finished)
    
    end

end

local function OnBadgeScaleAnimationFinished(badgeObj, animationLayerName)
    
    if animationLayerName ~= "scaleAnim" then
        return
    end
    
    -- Un hook from this callback.
    badgeObj:UnHookEvent(badgeObj, "OnAnimationFinished", OnBadgeScaleAnimationFinished)
    
    -- Make badge reappear in its slot (likely unseen), and with tray as the parent.
    local customizer = badgeObj:GetParent()
    assert(GetTypeName(customizer) == "GUIMenuBadgesCustomizer")
    badgeObj:SetParent(customizer.tray)
    badgeObj:AnimateProperty("Scale", nil, MenuAnimations.ScaleIn)
    badgeObj:ClearPropertyAnimations("Position")
    badgeObj:SetPosition(badgeObj.positionInTray)
    badgeObj:SetLayer(kBadgeLayer)

end

local function ReturnBadgeToTray(self, badgeObj)
    
    -- We need to take into account whether or not this badge's tray slot is visible or not.  If the
    -- tray slot is visible, we animate the badge to where the slot is.  Otherwise, we animate the
    -- badge to the center of the tray while scaling down to 0 so it appears to shrink down to
    -- nothing, after which it will reappear where it should, in the tray.
    
    -- For the former, we need to animate it in two sections: once until it is inside the tray, then
    -- another once it has entered the tray.
    -- For the latter, we need to do two animations in sequence: a scale down, then when that
    -- animation is finished, reposition it, and scale it back up.
    
    -- Test visibility of tray region.  We'll consider a badge slot "visible-enough" if its center
    -- is inside the crop zone of the scroll pane.
    local localTrayPos = badgeObj.positionInTray
    local ssTrayPos = self.tray:LocalSpaceToScreenSpace(localTrayPos)
    
    local ssTrayMinCorner = self.trayScrollPane:GetContentsItem():GetScreenPosition()
    local ssTrayMaxCorner = ssTrayMinCorner + self.trayScrollPane:GetContentsItem():GetAbsoluteSize()
    
    -- Ensure moving badges appear above other badges, but not above badges being dragged.
    badgeObj:SetLayer(kMovingBadgeLayer)
    
    if ssTrayPos.x >= ssTrayMinCorner.x and
    ssTrayPos.y >= ssTrayMinCorner.y and
    ssTrayPos.x <  ssTrayMaxCorner.x and
    ssTrayPos.y <  ssTrayMaxCorner.y then
        
        -- Badge spot is visible inside tray (at least for now).
        
        -- Compute where in the badge's current local space that screen space location of the tray
        -- position is.
        local badgeSpaceTrayPos = badgeObj:GetParent():ScreenSpaceToLocalSpace(ssTrayPos)
        
        -- Animate badge towards its location in the tray.
        -- If the badge is already in the right position (eg wasn't moved, just clicked on), skip
        -- this.
        if GetAreValuesTheSame(badgeSpaceTrayPos, badgeObj:GetPosition(true)) then
            BadgeNormalReturnAnimationStage2Check(self, badgeObj)
        else
            badgeObj:AnimateProperty("Position", badgeSpaceTrayPos, MenuAnimations.FlyIn)
            badgeObj.animStage2Func =
            function(self)
                BadgeNormalReturnAnimationStage2Check(self, badgeObj)
            end
            self:HookEvent(badgeObj, "OnPositionChanged", badgeObj.animStage2Func)
        end
    
    else
        
        -- Badge spot is _not_ visible inside tray at this time.
        
        local ssTrayMid = (ssTrayMinCorner + ssTrayMaxCorner) * 0.5
        local localTrayMid = badgeObj:GetParent():ScreenSpaceToLocalSpace(ssTrayMid)
        
        -- Animate badge towards the middle of the tray, since we can't see it's proper location in
        -- the tray.  Also animate the scale down to 0.
        badgeObj:AnimateProperty("Position", localTrayMid, MenuAnimations.FlyIn)
        local scaleNow = badgeObj:GetScale()
        badgeObj:ClearPropertyAnimations("Scale")
        badgeObj:SetScale(scaleNow)
        badgeObj:AnimateProperty("Scale", nil, MenuAnimations.ScaleOut, "scaleAnim")
        badgeObj:HookEvent(badgeObj, "OnAnimationFinished", OnBadgeScaleAnimationFinished)
    
    end

end

local function OnBadgeObjectDragEnd(self, badgeObj)
    
    -- Run the drag routine one more time, just to make sure it ran at all (wouldn't normally if the
    -- user just clicked on the badge without moving the mouse).
    OnBadgeObjectDrag(self, badgeObj)
    
    local slot = self:Get_ReplacingSlot()
    if slot == GUIObject.NoObject or not self.widgetProper:GetEditing() then
        
        -- Was not dropped into a valid location, or it was dropped because the widget is no longer
        -- in edit mode.
        -- Return it to the tray.
        ReturnBadgeToTray(self, badgeObj)
        
    else
    
        -- Make the badge a child of the slot.  Preserve the screen-space position.
        local ssPos = badgeObj:GetScreenPosition()
        local slotSpacePos = slot:ScreenSpaceToLocalSpace(ssPos)
        badgeObj:ClearPropertyAnimations("Position")
        badgeObj:SetPosition(slotSpacePos + badgeObj:GetSize() * badgeObj:GetScale() * 0.5)
        badgeObj:SetParent(slot)
        
        local kickedOutBadge = slot:GetBadgeObj() -- might be GUIObject.NoObject
        
        self:Set_ReplacingSlot(GUIObject.NoObject)
        slot:SetBadgeObj(badgeObj)
        
        if kickedOutBadge ~= GUIObject.NoObject then
            ReturnBadgeToTray(self, kickedOutBadge)
        end
        
        -- Apply the badge slot change for real so it shows up elsewhere.
        local badgeId = gBadges[badgeObj:GetBadgeName()]
        if badgeId then
            SelectBadge(badgeId, slot:GetSlotIndex())
        end
        
    end
    
    self:Set_DraggingBadgeObj(GUIObject.NoObject)
    
end

local inUseBadgeNames = {}
local function GetSanitizedUniqueName(name)

    local sanitizedName = name
    sanitizedName = string.gsub(sanitizedName, " ", "_sp_")
    sanitizedName = string.gsub(sanitizedName, "%.", "_dot_")
    sanitizedName = string.gsub(sanitizedName, "%:", "_col_")
    sanitizedName = string.gsub(sanitizedName, "/", "_fwd_")
    
    local sanitizedName2 = sanitizedName
    local idx = 1
    while inUseBadgeNames[sanitizedName2] do
        idx = idx + 1
        sanitizedName2 = string.format("%s_%d", sanitizedName)
    end
    
    return sanitizedName2

end

local function AddColumnCounts(self, columns)
    
    local countsTable = self:Get_SlotEligibleCounts()
    local changed = false
    for i=1, kMaxBadgeColumns do
        if bit.band(columns, bit.lshift(1, i-1)) ~= 0 then
            countsTable[i] = countsTable[i] + 1
            changed = true
        end
    end
    
    if changed then
        self:Set_SlotEligibleCounts(countsTable)
    end

end

local function RemoveColumnCounts(self, columns)
    
    local countsTable = self:Get_SlotEligibleCounts()
    local changed = false
    for i=1, kMaxBadgeColumns do
        if bit.band(columns, bit.lshift(1, i-1)) ~= 0 then
            countsTable[i] = countsTable[i] - 1
            assert(countsTable[i] >= 0)
            changed = true
        end
    end
    
    if changed then
        self:Set_SlotEligibleCounts(countsTable)
    end

end

local function OnBadgeColumnsChanged(self, columns, prevColumns)
    RemoveColumnCounts(self, prevColumns)
    AddColumnCounts(self, columns)
end

local function OnBadgeDestroy(self, badgeObj)
    RemoveColumnCounts(self, badgeObj:GetColumns())
end

-- Attempts to create a new object for the badge of a given name.  If there's no badge data found
-- for the given name, bails out with a message, returns false.  Returns true if successful.
local function CreateBadgeObject(self, badgeName)
    
    local sanitizedName = GetSanitizedUniqueName(badgeName)
    
    assert(type(badgeName) == "string")
    assert(self.badgeObjs[badgeName] == nil)
    
    local badgeData = Badges_GetBadgeDataByName(badgeName)
    if not badgeData then
        Log("No badge data found for badge named '%s'.  Omitting.", badgeName)
        return false
    end
    
    -- Use the biggest variant... why there are even variants at all... who knows...
    local badgeTexture = badgeData.unitStatusTexture
    
    local tooltip = Locale.ResolveString(badgeData.name)
    
    local row = self:Get_CurrentTrayRow()
    local col = self:Get_CurrentTrayColumn()
    
    local newBadgeObj = CreateGUIObject(sanitizedName, GUIMenuCustomizableBadge, self.tray,
    {
        constrainToParent = false,
        constrainToScreen = false,
        noAutoConnectToParent = true, -- don't send/receive FXState updates to/from parent.
        columns = badgeData.columns,
        badgeName = badgeName,
    })
    AddColumnCounts(self, badgeData.columns)
    self:HookEvent(newBadgeObj, "OnColumnsChanged", OnBadgeColumnsChanged)
    self:HookEvent(newBadgeObj, "OnDestroy", OnBadgeDestroy)
    newBadgeObj:SetSize(kBadgeSize, kBadgeSize)
    newBadgeObj:SetHotSpot(0.5, 0.5)
    newBadgeObj:SetTooltip(tooltip)
    
    local x = col * (kBadgeSize + kSpacing) + kSpacing + kBadgeSize * 0.5
    local y = row * (kBadgeSize + kSpacing) + kSpacing + kBadgeSize * 0.5
    
    newBadgeObj:SetPosition(x, y)
    newBadgeObj.positionInTray = Vector(x, y, 0)
    
    newBadgeObj:SetTexture(badgeTexture)
    newBadgeObj:SetColor(1, 1, 1, 1)
    newBadgeObj:SetOpacity(1)
    
    col = col + 1
    while col >= kTrayColumnCount do
        row = row + 1
        col = col - kTrayColumnCount
    end
    
    self:Set_CurrentTrayRow(row)
    self:Set_CurrentTrayColumn(col)
    
    self:HookEvent(newBadgeObj, "OnDragBegin", OnBadgeObjectDragBegin)
    self:HookEvent(newBadgeObj, "OnDrag", OnBadgeObjectDrag)
    self:HookEvent(newBadgeObj, "OnDragEnd", OnBadgeObjectDragEnd)
    
    self.badgeObjs[badgeName] = newBadgeObj
    
    return true

end

local function EnsureBadgeObjectExists(self, badgeName)
    if not self.badgeObjs[badgeName] then
        return (CreateBadgeObject(self, badgeName))
    end
    return true
end

local function UpdateAvailableBadges(self)
    
    local availableBadges = self:GetAvailableBadges()
    
    -- Create missing badge objects, and update our available badges' columns mask.
    for i=1, #availableBadges do
        local badgeName = availableBadges[i]
        EnsureBadgeObjectExists(self, badgeName)
        
    end

end

local function OnAvailableBadgesChanged(self)
    
    UpdateAvailableBadges(self)
    
end

local function UpdateVisibleColumns(self)
    
    if self:GetOpen() then
        self:Set_VisibleColumns(self:Get_AvailableColumnsMask())
    else
        self:Set_VisibleColumns(self:Get_ActiveColumnsMask())
    end

end

local function UpdateOpenFrac(self)
    
    local open = self:GetOpen()
    local goal = open and 1.0 or 0.0
    self:AnimateProperty("_OpenFrac", goal, MenuAnimations.FlyIn)
    
end

local function OnFXStateChanged(self, state, prevState)
    
    if state == "pressed" then
        self.badgeSlotsHolder:ClearPropertyAnimations("StrokeWidth")
        self.badgeSlotsHolder:SetStrokeWidth(MenuStyle.kStrokeWidth)
        self.badgeSlotsHolder:ClearPropertyAnimations("StrokeColor")
        self.badgeSlotsHolder:SetStrokeColor((MenuStyle.kHighlight + MenuStyle.kBasicStrokeColor)*0.5)
    elseif state == "hover" then
        if prevState == "pressed" then
            self.badgeSlotsHolder:AnimateProperty("StrokeWidth", 3, MenuAnimations.Fade)
            self.badgeSlotsHolder:AnimateProperty("StrokeColor", MenuStyle.kHighlight, MenuAnimations.Fade)
        else
            PlayMenuSound("ButtonHover")
            DoColorFlashEffect(self.badgeSlotsHolder, "StrokeColor")
            self.badgeSlotsHolder:ClearPropertyAnimations("StrokeWidth")
            self.badgeSlotsHolder:SetStrokeWidth(3)
        end
    else -- default or disabled (which isn't used).
        self.badgeSlotsHolder:AnimateProperty("StrokeWidth", MenuStyle.kStrokeWidth, MenuAnimations.Fade)
        self.badgeSlotsHolder:AnimateProperty("StrokeColor", MenuStyle.kBasicStrokeColor, MenuAnimations.Fade)
    end

end

local function OnPressed(self)
    self:SetEditing(true)
end

local function OnWidgetProperKey(self, key, down)
    if down and key == InputKey.Escape then
        self:SetEditing(false)
    end
end

local function OnWidgetProperOutsideClick(self)
    self:SetEditing(false)
end

local function CountMaskBits(mask)
    assert(type(mask) == "number")
    assert(math.floor(mask) == mask)
    local bitCount = 0
    while mask ~= 0 do
        bitCount = bitCount + bit.band(mask, 1)
        mask = bit.rshift(mask, 1)
    end
    return bitCount
end

local function UpdateClosedSize(self)
    
    local activeColumnsMask = self:Get_ActiveColumnsMask()
    local visibleSlotCount = CountMaskBits(activeColumnsMask)
    
    self:SetSize(kSpacing + (kBadgeSize + kSpacing) * visibleSlotCount, kSpacing*2 + kBadgeSize)

end

function GUIMenuBadgesCustomizer_proper:_BeginEditing()
    
    local self = self.owner -- easier to do this from the point of view of the main class.
    
    PlayMenuSound("BeginChoice")
    self:SetOpen(true)
    self.widgetProper:SetModal()
    self.widgetProper:ListenForKeyInteractions()
    self.widgetProper:AllowChildInteractions()
    self:HookEvent(self.widgetProper, "OnKey", OnWidgetProperKey)
    self:HookEvent(self.widgetProper, "OnOutsideClick", OnWidgetProperOutsideClick)
    
    self.dimmer:AnimateProperty("Opacity", 1.0, MenuAnimations.FadeFast)
    
    -- Detach the "widgetProper" from the base object so it will render on top of all other objects.
    local ssPos = self.widgetProper:GetScreenPosition()
    local absScale = self.widgetProper:GetAbsoluteScale()
    local desiredScale = GetPlayerScreen():GetScale().x -- should be uniform, so just use x.
    self.widgetProper:SetParent(nil)
    self.widgetProper:SetPosition(ssPos)
    self.widgetProper:SetScale(absScale)
    self.widgetProper:AnimateProperty("Scale", Vector(desiredScale, desiredScale, 1), MenuAnimations.FlyIn)

end

function GUIMenuBadgesCustomizer_proper:_EndEditing()
    
    local self = self.owner -- easier to do this from the point of view of the main class.
    
    PlayMenuSound("AcceptChoice")
    self:SetOpen(false)
    self.widgetProper:ClearModal()
    self.widgetProper:StopListeningForKeyInteractions()
    self.widgetProper:BlockChildInteractions()
    self:UnHookEvent(self.widgetProper, "OnKey", OnWidgetProperKey)
    self:UnHookEvent(self.widgetProper, "OnOutsideClick", OnWidgetProperOutsideClick)
    
    self.dimmer:AnimateProperty("Opacity", 0.0, MenuAnimations.FadeFast)
    
    -- Reattach the "widgetProper" to the base object.
    self.widgetProper:SetParent(self)
    self.widgetProper:SetPosition(0, 0)
    
    -- Animate the scale back to what it was.
    local desiredScale = GetPlayerScreen():GetScale().x -- should be uniform, so just use x.
    self.widgetProper:SetScale(1, 1)
    local absScale = self.widgetProper:GetAbsoluteScale()
    local invAbsScale = Vector(1, 1, 1)
    if absScale.x ~= 0 then invAbsScale.x = desiredScale / absScale.x end
    if absScale.y ~= 0 then invAbsScale.y = desiredScale / absScale.y end
    self.widgetProper:SetScale(invAbsScale, invAbsScale)
    self.widgetProper:AnimateProperty("Scale", Vector(1, 1, 1), MenuAnimations.FlyIn)
    
    -- If the user was dragging a badge, release the badge.
    local draggingBadgeObj = self:Get_DraggingBadgeObj()
    if draggingBadgeObj ~= GUIObject.NoObject then
        draggingBadgeObj:EndDragging()
    end

end

-- Called whenever the set of owned badges might have changed.
function GUIMenuBadgesCustomizer:UpdateOwnedBadges()
    
    PROFILE("GUIMenuBadgesCustomizer:UpdateOwnedBadges")
    
    local ownedBadgeNamesSet = self:GetAvailableBadges()
    local ownedBadges = Badges_GetOwnedBadges()
    local changed = false
    for i=1, #gBadges do
        
        local badgeName = gBadges[i]
        assert(type(badgeName) == "string")
        
        local owned = ownedBadges[i] ~= nil
        local prevOwned = ownedBadgeNamesSet:Contains(badgeName)
    
        if owned ~= prevOwned then
            changed = true
    
            if owned then
                ownedBadgeNamesSet:Add(badgeName)
            else
                ownedBadgeNamesSet:RemoveElement(badgeName)
            end
        end
        
    end
    
    if changed then
        self:SetAvailableBadges(ownedBadgeNamesSet)
        self:UpdateActiveBadges()
    end
    
end

-- Updates which badges are shown as being "active" (eg in the displayed slots) based on the user's
-- preferences.
function GUIMenuBadgesCustomizer:UpdateActiveBadges()
    
    PROFILE("GUIMenuBadgesCustomizer:UpdateActiveBadges")
    
    local inUseBadges = {}
    
    for i=1, #self.badgeSlots do
    
        local slot = self.badgeSlots[i]
        local savedBadge = Client.GetOptionString(string.format("Badge%d", i), "")
    
        local badgeObj
        if savedBadge == "" then
            -- Badge is not chosen.
            badgeObj = GUIObject.NoObject
        else
            badgeObj = self.badgeObjs[savedBadge] or GUIObject.NoObject
        end
    
        -- Ensure badge is allowed in this slot.
        if badgeObj ~= GUIObject.NoObject then
            local slotMask = slot:GetColumnMask()
            local badgeMask = badgeObj:GetColumns()
            if bit.band(slotMask, badgeMask) == 0 then
                badgeObj = GUIObject.NoObject
            end
        end
    
        -- Don't set the badge object of this slot if that badge object is being dragged.
        if self:Get_DraggingBadgeObj() ~= badgeObj or badgeObj == GUIObject.NoObject then
            
            -- Return badge currently in the slot to the tray.
            local prevBadge = slot:GetBadgeObj()
            if prevBadge ~= GUIObject.NoObject then
                prevBadge:SetPosition(prevBadge.positionInTray)
                prevBadge:SetParent(self.tray)
            end
            
            -- Remove this badge from any other slots it was set to (dups not allowed, but can
            -- happen sometimes).
            local existingSlotIndex = inUseBadges[badgeObj]
            if existingSlotIndex then
                local oldSlot = self.badgeSlots[existingSlotIndex]
                local badgeObj = oldSlot:GetBadgeObj()
                oldSlot:SetBadgeObj(GUIObject.NoObject)
                SelectBadge(gBadges.none, oldSlot:GetSlotIndex())
            end
            
            -- The slot will automatically set the position of the badge object.
            slot:SetBadgeObj(badgeObj)
            if badgeObj ~= GUIObject.NoObject then
                SelectBadge(gBadges[badgeObj:GetBadgeName()], slot:GetSlotIndex())
                badgeObj:SetParent(slot)
                badgeObj:SetPosition(kBadgeSize * 0.5, kBadgeSize * 0.5)
                inUseBadges[badgeObj] = i
            end
        end
        
    end

end

function GUIMenuBadgesCustomizer:GetBadgeObjByName(badgeName)
    return self.badgeObjs[badgeName]
end

local function UpdateAvailableBadgesMask(self)

    local counts = self:Get_SlotEligibleCounts()
    local mask = 0
    for i=1, kMaxBadgeColumns do
        if counts[i] > 0 then
            local currentSlotMask = bit.lshift(1, i-1)
            mask = bit.bor(mask, currentSlotMask)
        end
    end
    
    self:Set_AvailableColumnsMask(mask)

end

function GUIMenuBadgesCustomizer:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "tooltip", Locale.ResolveString("CUSTOMIZE_MENU_BADGES"))
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "tooltip")
    
    badgeCustomizer = self
    
    -- Mapping of badgeName --> badge GUIObject.
    self.badgeObjs = {}
    
    -- Mapping of slotIdx --> GUIMenuBadgeSlot.
    self.badgeSlots = {}
    
    local slotCountsTable = {}
    for i=1, kMaxBadgeColumns do
        slotCountsTable[i] = 0
    end
    self:Set_SlotEligibleCounts(slotCountsTable)
    self:HookEvent(self, "On_SlotEligibleCountsChanged", UpdateAvailableBadgesMask)
    
    -- The contents of the widget itself.  We have an extra object here so that we can detach the
    -- rest of the widget from the hierarchy during editing so it renders on top of everything else.
    -- We can do this without disturbing layouts that hold this object by having _this_ object be
    -- unchanged by the detachment.
    self.widgetProper = CreateGUIObject("widgetProper", GUIMenuBadgesCustomizer_proper, self)
    self.widgetProper:HookEvent(self, "OnSizeChanged", self.widgetProper.SetSize)
    self.widgetProper:SetLayer(GetLayerConstant("BadgesCustomizer", 9999))
    self.widgetProper.owner = self
    
    -- Setup initial state of widget to be closed.
    self.widgetProper:BlockChildInteractions()
    
    self.dimmer = CreateGUIObject("dimmer", GUIObject, self.widgetProper)
    self.dimmer:SetColor(0, 0, 0, 0.5)
    self.dimmer:SetOpacity(0)
    self.dimmer:SetInheritsParentScaling(false)
    self.dimmer:SetInheritsParentPosition(false)
    self.dimmer:HookEvent(GetGlobalEventDispatcher(), "OnResolutionChanged", UpdateDimmerSize)
    UpdateDimmerSize(self.dimmer, Client.GetScreenWidth(), Client.GetScreenHeight())
    
    self.badgeSlotsHolder = CreateGUIObject("badgeSlotsHolder", GUIMenuBasicBox, self.widgetProper)
    
    self.badgeSlotsLayout = CreateGUIObject("badgeSlotsLayout", GUIListLayout, self.badgeSlotsHolder,
    {
        orientation = "horizontal",
        spacing = kSpacing,
    })
    self.badgeSlotsLayout:SetPosition(kSpacing, kSpacing)
    self.badgeSlotsHolder:SetLayer(2)
    self.badgeSlotsHolder:HookEvent(self.badgeSlotsLayout, "OnSizeChanged", function(holder, size)
        holder:SetSize(size.x + kSpacing*2, size.y + kSpacing*2)
    end)
    
    -- Create badge slots for the maximum number of badge columns.
    for i=1, kMaxBadgeColumns do
        local newSlot = CreateGUIObject(string.format("badgeSlot%d", i), GUIMenuBadgeSlot, self.badgeSlotsLayout,
        {
            customizer = self,
            slotIndex = i,
            noCropWhenFullyVisible = true,
        })
        self.badgeSlots[i] = newSlot
    end
    
    -- Invisible helper object to hold the tray.
    self.trayExpansionHolder = CreateGUIObject("trayExpansionHolder", GUIObject, self.widgetProper)
    self.trayExpansionHolder:SetCropMin(0, 0)
    self.trayExpansionHolder:SetCropMax(1, 1) -- enable cropping
    self.trayExpansionHolder:SetSize(0, 0)
    self.trayExpansionHolder:SetX(-kTrayHolderMargin)
    self.trayExpansionHolder:SetY(kSpacing*2 + kBadgeSize - kTrayHolderMargin)
    self:HookEvent(self, "On_OpenFracChanged", UpdateTrayOpenFrac)
    
    self.trayBack = CreateGUIObject("trayBack", GUIMenuBasicBox, self.trayExpansionHolder)
    self.trayBack:AlignBottomRight()
    self.trayBack:SetPosition(-kTrayHolderMargin, -kTrayHolderMargin)
    self:HookEvent(self.trayBack, "OnSizeChanged", UpdateTrayOpenFrac)
    
    self.trayScrollPane = CreateGUIObject("trayScrollPane", GUIMenuScrollPane, self.trayBack,
    {
        horizontalScrollBarEnabled = false,
    })
    self.trayScrollPane:SetHeight(kTraySize.y)
    
    -- Sync tray background to size of scroll pane.
    self.trayBack:HookEvent(self.trayScrollPane, "OnSizeChanged", self.trayBack.SetSize)
    self.trayBack:SetSize(self.trayScrollPane:GetSize())
    
    -- Resize the tray to include extra width for the scroll bar.
    self:HookEvent(self.trayScrollPane, "OnContentsSizeChanged", UpdateScrollPaneWidth)
    UpdateScrollPaneWidth(self)
    
    -- Create tray object to hold badges.
    self.tray = CreateGUIObject("tray", GUIObject, self.trayScrollPane)
    self.tray:SetWidth(kTraySize.x)
    self:HookEvent(self, "On_CurrentTrayRowChanged", UpdateTrayHeight)
    self:HookEvent(self, "On_CurrentTrayColumnChanged", UpdateTrayHeight)
    UpdateTrayHeight(self)
    
    -- Sync size of scroll pane pane to tray.
    self.trayScrollPane:HookEvent(self.tray, "OnSizeChanged", self.trayScrollPane.SetPaneSize)
    self.trayScrollPane:SetPaneSize(self.tray:GetSize())
    
    self:HookEvent(self, "OnAvailableBadgesChanged", OnAvailableBadgesChanged)
    self:HookEvent(self, "OnOpenChanged", UpdateOpenFrac)
    
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    self:HookEvent(self, "OnPressed", OnPressed)
    
    self:HookEvent(self, "OnOpenChanged",                   UpdateVisibleColumns)
    self:HookEvent(self, "On_AvailableColumnsMaskChanged",  UpdateVisibleColumns)
    self:HookEvent(self, "On_ActiveColumnsMaskChanged",     UpdateVisibleColumns)
    UpdateVisibleColumns(self)
    
    self:HookEvent(self, "On_ActiveColumnsMaskChanged", UpdateClosedSize)
    UpdateClosedSize(self)
    
    self:UpdateOwnedBadges()
    
end
