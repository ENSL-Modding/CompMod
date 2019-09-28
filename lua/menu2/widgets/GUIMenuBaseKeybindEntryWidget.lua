-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuBaseKeybindEntryWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Menu themeing for GUIBaseKeybindEntryWidget.
--    
--    This widget is JUST the keybind text -- it does not include any background, labels, buttons
--    or anything outside of the base functionality.
--
--  Properties:
--      Value           -- The _string_ of the current keybind for this widget (or "None" if
--                         unassigned).
--      IsConflicted    -- Whether or not this keybind has a conflict with another keybind (same
--                         group and same key).
--      IsInherited     -- Whether or not the _current value_ of the widget is inherited from the
--                         "InheritFrom" widget. (Note: must never be true if inheritFrom was
--                         nil)
--      
--  Events:
--      OnEditBegin         -- Whenever this widget begins listening for key inputs.
--      OnEditAccepted      -- Whenever this widget changes its value to the given input.
--      OnEditCancelled     -- Whenever this widget stops listening for input without changing values.
--      OnEditEnd           -- Whenever this widget is no longer listening for input.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIBaseKeybindEntryWidget.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")
Script.Load("lua/menu2/wrappers/MenuFX.lua")

---@class GUIMenuBaseKeybindEntryWidget : GUIBaseKeybindEntryWidget
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
---@field protected OnFXStateChangedOverride function @From MenuFX wrapper
local baseClass = GUIBaseKeybindEntryWidget
baseClass = GetMenuFXWrappedClass(baseClass)
assert(baseClass.UpdateFXState)
class "GUIMenuBaseKeybindEntryWidget" (baseClass)

function GUIMenuBaseKeybindEntryWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self:SetFont(MenuStyle.kOptionFont)
    
    self:HookEvent(self, "OnIsInheritedChanged", self.UpdateFXState)
    
end

-- Add support for an "inherited" FXState.
function GUIMenuBaseKeybindEntryWidget:UpdateFXStateOverride(commonStateResult)
    
    if commonStateResult == "default" and self:GetIsInherited() then
        self:SetFXState("inherited")
        return true
    end
    
    return false
    
end

-- Implement inherited fade color.
-- Implement additional behavior for "editing"
    -- pulse opacity
function GUIMenuBaseKeybindEntryWidget:OnFXStateChangedOverride(state, prevState)
    
    -- Remove editing pulse effect if it exists.
    if state ~= "editing" then
        self:ClearPropertyAnimations("Color", "pulse")
    end
    
    if state == "inherited" then
        self:AnimateProperty("Color", MenuStyle.kDarkGrey, MenuAnimations.Fade)
        return true -- override behavior was invoked, no need to run default behaviors.
    elseif state == "editing" then
        self:AnimateProperty("Color", nil, MenuAnimations.PulseColor, "pulse")
        -- Deliberately NOT returning true here.  Still want to do the default color change.
    end
    
    return false -- no override behavior invoked/want default behavior performed anyways.

end
