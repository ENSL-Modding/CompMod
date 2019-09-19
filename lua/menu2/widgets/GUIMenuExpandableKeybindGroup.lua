-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuExpandableKeybindGroup.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    GUIMenuExpandableGroup that holds keybinds, and changes label color to red whenever any of
--    its contained keybinds are conflicted.
--@class GUIMenuExpandableKeybindGroup : GUIMenuExpandableGroup
--
--  Properties:
--      Open                -- Whether or not the groups contents are visible.
--      ContentsSize        -- The size of the object that holds the contents of this group.
--      Label               -- The text displayed in the label of this object.
--      LabelBaseColor      -- The color of the label, underneath the highlight.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/widgets/GUIMenuExpandableGroup.lua")

---@class GUIMenuExpandableKeybindGroup : GUIMenuExpandableGroup
class "GUIMenuExpandableKeybindGroup" (GUIMenuExpandableGroup)

local function LabelOnFXStateChangedOverride(self, state, prevState)
    
    if state == "conflicted" then
        self:AnimateProperty("Color", MenuStyle.kConflictedBackgroundColor, MenuAnimations.Fade)
        return true
    end
    
    return false
    
end

local function ArrowOnFXStateChangedOverride(self, state, prevState)
    
    if state == "conflicted" then
        self:AnimateProperty("ArrowColor", MenuStyle.kConflictedBackgroundColor, MenuAnimations.Fade)
        return true
    end
    
    return false
    
end

local function HeaderUpdateFXStateOverride(self, commonStateResult)
    
    -- Conflicted and default state.  (Eg don't affect highlight, etc.)
    if commonStateResult == "default" and self.group.isConflicted then
        self:SetFXState("conflicted")
        return true
    end
    
    return false
    
end

function GUIMenuExpandableKeybindGroup:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuExpandableGroup.Initialize(self, params, errorDepth)
    
    self.conflictedWidgets = UnorderedSet()
    self.isConflicted = false
    
    -- Add an extra FXState for header to change color when the group is conflicted.
    self.label.OnFXStateChangedOverride = LabelOnFXStateChangedOverride
    self.arrow.OnFXStateChangedOverride = ArrowOnFXStateChangedOverride
    self.header.UpdateFXStateOverride = HeaderUpdateFXStateOverride
    self.header.group = self
end

local function UpdateConflicted(self)
    
    local conflicted = #self.conflictedWidgets > 0
    
    if self.isConflicted == conflicted then
        return
    end
    
    self.isConflicted = conflicted
    self.header:UpdateFXState()
    
end

function GUIMenuExpandableKeybindGroup:OnKeybindWidgetDestroyed(obj)
    
    self.conflictedWidgets:RemoveElement(obj)
    self:UnHookEvent(obj, "OnDestroy", self.OnKeybindWidgetDestroyed)
    UpdateConflicted(self)
    
end

function GUIMenuExpandableKeybindGroup:AddConflictedKeybindWidget(obj)
    
    if self.conflictedWidgets:Add(obj) then
        UpdateConflicted(self)
        self:HookEvent(obj, "OnDestroy", self.OnKeybindWidgetDestroyed)
    end
end

function GUIMenuExpandableKeybindGroup:RemoveConflictedKeybindWidget(obj)
    
    if self.conflictedWidgets:RemoveElement(obj) then
        UpdateConflicted(self)
        self:UnHookEvent(obj, "OnDestroy", self.OnKeybindWidgetDestroyed)
    end
end
