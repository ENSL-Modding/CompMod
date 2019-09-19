-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/wrappers/FXState.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Class wrapper that defines an "FXState" property, which is used as an interface for most
--    graphical and audio FX.  The class will also attempt to share FXState with the parent object
--    if the parent also has the FXState wrapper.  This ensures their effects sync up.
--
--  Parameters (* = required)
--      noAutoConnectToParent   If true, causes this object to _not_ attempt to automatically
--                              connect to the parent.
--
--  Properties
--      FXState     The current state of the object's FX.  A string, so it can be just about
--                  anything, but common states are:
--                      -- default
--                      -- hover
--                      -- pressed
--                      -- disabled
--                      -- editing
--                  This value generally shouldn't be set directly, but should only be updated by
--                  UpdateFXStateOverride (see below).
--                  Use self:HookEvent(<sender>, "On_____Changed", self.UpdateFXState) to trigger
--                  an FXState update.
--
--  Optional Properties (will be used if present, otherwise ignored)
--      MouseOver
--      Pressed
--      Enabled
--      Editing
--
--  Added Methods
--      AddFXReceiver       Makes self object send FXState to another object.  Calling this is not
--                          necessary when creating a child object that also uses this wrapper.
--      RemoveFXReceiver    Self object will no longer send FXState updates to the other object.
--
--  Optional Methods (may be implemented for additional functionality).
--      UpdateFXStateOverride(commonStateResult)    Will be called whenever the FXState variable is
--          being reevaluated.  This method should either A) call SetFXState and return true, or B)
--          return false and not set the state.  This is a means to support uncommon fx states.  See
--          GUIMenuBaseKeybindEntryWidget.lua for an example.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

-- Annotations (copy+paste under @class where this wrapper is used).
--[===[
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
--]===]

Script.Load("lua/GUI/wrappers/WrapperUtility.lua")

-- Pre-define some common states.
local kStateMap =
{
    -- State name      Getter method name      invert getter result
    { "editing",         "GetEditing",           false   },
    { "disabled",        "GetEnabled",           true    },
    { "pressed",         "GetPressed",           false   },
    { "hover",           "GetMouseOver",         false   },
}

local function EvaluateCommonFXStates(self)
    
    for i=1, #kStateMap do
        local stateData = kStateMap[i]
        local stateName = stateData[1]
        local getterMethodName = stateData[2]
        local invertLogic = stateData[3]
        
        if self[getterMethodName] then
            local result = self[getterMethodName](self)
            if invertLogic then
                result = not result
            end
            if result then
                return stateName
            end
        end
    end
    
    return "default"

end

local function UpdateFXState(self)
    
    local commonStateResult = EvaluateCommonFXStates(self)
    
    -- Allow derived classes the opportunity to evaluate their own state
    if self.UpdateFXStateOverride and self:UpdateFXStateOverride(commonStateResult) then
        return
    end
    
    self:SetFXState(commonStateResult)

end

local function AddFXReceiver(self, receiver)
    receiver:UnHookEvent(self, "OnFXStateChanged", receiver.SetFXState) -- ensure no duplicates.
    receiver:HookEvent(self, "OnFXStateChanged", receiver.SetFXState)
    receiver:SetFXState(self:GetFXState())
end

local function RemoveFXReceiver(self, receiver)
    receiver:UnHookEvent(self, "OnFXStateChanged", receiver.SetFXState)
end

local function UpdateAutoFXStateLink(self, newParent, oldParent)
    
    -- Unlink from old parent.
    if oldParent and GetHasWrapper(oldParent, "FXState") then
        RemoveFXReceiver(self, oldParent)
        RemoveFXReceiver(oldParent, self)
    end
    
    -- Link to new parent.
    if newParent and GetHasWrapper(newParent, "FXState") then
        AddFXReceiver(self, newParent)
        AddFXReceiver(newParent, self)
        self:SetFXState(newParent:GetFXState())
    end
    
end

DefineClassWrapper
{
    name = "FXState",
    classBuilderFunc = function(wrappedClass, baseClass)

        wrappedClass:AddClassProperty("FXState", "default")

        wrappedClass.AddFXReceiver = AddFXReceiver
        wrappedClass.RemoveFXReceiver = RemoveFXReceiver
        wrappedClass.UpdateFXState = UpdateFXState
        
        wrappedClass.Initialize = GetCachedExtendedMethod("Initialize", wrappedClass, baseClass,
        function(newClass, oldClass)

            -- FXInitialize()
            return function(self, params, errorDepth)
                errorDepth = (errorDepth or 1) + 1
                
                RequireType({"boolean", "nil"}, params.noAutoConnectToParent, "params.noAutoConnectToParent", errorDepth)
                
                oldClass.Initialize(self, params, errorDepth)

                self:HookEvent(self, "OnMouseOverChanged", self.UpdateFXState)
                self:HookEvent(self, "OnEnabledChanged",   self.UpdateFXState)
                self:HookEvent(self, "OnPressedChanged",   self.UpdateFXState)
                self:HookEvent(self, "OnEditingChanged",   self.UpdateFXState)
    
                if not params.noAutoConnectToParent then
                    self:HookEvent(self, "OnParentChanged",    UpdateAutoFXStateLink)
                end

            end

        end)

    end,
}