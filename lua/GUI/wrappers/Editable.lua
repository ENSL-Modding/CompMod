-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/GUI/wrappers/Editable.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Class wrapper that makes a widget "Editable".  Only one widget can be edited at a time. This
--    wrapper coordinates the editing between its instances.  Eg doing SetEditing(true) while
--    another widget is being edited will first call SetEditing(false) for the other widget.
--
--  Parameters (* = required)
--      editController      Editable that "owns" this object, and will be set to editing instead of
--                          this object.  Useful for objects that are composed of smaller objects
--                          that can be used on their own.
--
--  Properties
--      Editing     Whether or not the widget is currently being edited by the user.
--
--  Optional Methods
--      _BeginEditing       What to do when editing starts.
--      _EndEditing         What to do when editing ends.
--      GetIsTextInput      Whether or not this widget, if being edited, is accepting text input.
--                          This is used to determine if the manager should block console keybinds
--                          from firing (otherwise hitting the key you have bound to "kill" for
--                          some reason will kill you when you're typing in some text).
--
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

-- Annotations (copy+paste under @class where this wrapper is used).
--[===[
---@field public GetEditing function @From Editable wrapper
---@field public SetEditing function @From Editable wrapper
---@field protected _BeginEditing function @From Editable wrapper
---@field protected _EndEditing function @From Editable wrapper
--]===]

Script.Load("lua/GUI/wrappers/WrapperUtility.lua")
Script.Load("lua/GUI/wrappers/ScrollToView.lua")
Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")

local gEditingWidget = nil
local function OnEditableDestroyedWhileBeingEdited(editableObj)
    assert(gEditingWidget == editableObj)
    
    -- DON'T set its editing to false!  Just let it be destroyed thinking it is still being edited.
    -- Otherwise what will happen is it will try to update all the visuals associated with ending
    -- the editing (eg updating the text and cursor graphics), but those are child items, and thus
    -- have already been destroyed.
    gEditingWidget = nil
    
end

local function OnGUIObjectClicked(self, otherObj)
    
    -- Only stop editing if the clicked object is not a descendant of this object.
    if self == otherObj or self:GetIsAncestorOf(otherObj) then
        return
    end
    
    self:SetEditing(false)
    
end

-- Can be called from anywhere, at any time, to determine if there is some text being entered
-- somewhere, or not.
function GetIsTextBeingEntered()
    
    if gEditingWidget == nil then
        return false
    end
    
    return (gEditingWidget:GetIsTextInput())
    
end

-- Can be called from anywhere, at any time.  Ends editing on any and all widgets.
function EndAllGUIEditing()
    if gEditingWidget ~= nil then
        gEditingWidget:SetEditing(false)
    end
end

local function DefaultGetIsTextInput()
    return false
end

DefineClassWrapper
{
    name = "Editable",
    requiredWrappers = "ScrollToView",
    classBuilderFunc = function(wrappedClass, baseClass)
    
        if not wrappedClass.GetIsTextInput then
            wrappedClass.GetIsTextInput = DefaultGetIsTextInput
        end
        
        wrappedClass:AddClassProperty("Editing", false)
        
        wrappedClass.Initialize = GetCachedExtendedMethod("Initialize", wrappedClass, baseClass,
        function(newClass, oldClass)
            
            -- Editable Initialize()
            return function(self, params, errorDepth)
                errorDepth = (errorDepth or 1) + 1
                
                if params.editController ~= nil then
                    RequireIsa("GUIObject", params.editController, "params.editController", errorDepth)
                    RequireHasWrapper("Editable", params.editController, "params.editController", errorDepth)
                end
                
                if params.scrollToViewPropertyList then
                    RequireType("table", params.scrollToViewPropertyList, "params.scrollToViewPropertyList", errorDepth)
                    local newPropertyList = {"Editing"}
                    for i=1, #params.scrollToViewPropertyList do
                        table.insert(newPropertyList, params.scrollToViewPropertyList[i])
                    end
                    PushParamChange(params, "scrollToViewPropertyList", newPropertyList)
                else
                    PushParamChange(params, "scrollToViewPropertyList", {"Editing"})
                end
                
                oldClass.Initialize(self, params, errorDepth)
                PopParamChange(params, "scrollToViewPropertyList")
    
                if params.editController then
                    self.editController = params.editController
                    
                    -- Make sure to forward the "OnEditingChanged" event, otherwise some FX might
                    -- not update correctly.
                    self:ForwardEvent(self.editController, "OnEditingChanged")
                    
                end
                
            end
        end)
        
        -- Override GetEditing to use the controller's Editing property, if provided.
        local old_GetEditing = wrappedClass.GetEditing
        wrappedClass.GetEditing = function(self)
            if self.editController then
                return (self.editController:GetEditing())
            else
                return (old_GetEditing(self))
            end
        end
        
        -- Override SetEditing to notify the GUIEditFocusManager.
        local old_SetEditing = wrappedClass.SetEditing
        wrappedClass.SetEditing = function(self, state)
            
            -- Clean the input.
            state = state == true
            
            -- If a controller was specified, use that instead.
            if self.editController then
                self.editController:SetEditing(state)
                return
            end
            
            -- Skip if no change.
            if state == self:GetEditing() then
                return
            end
            
            if state then
                -- Starting to edit this widget.
                
                -- If another widget was being edited, stop it's editing first before activating
                -- ours.
                if gEditingWidget then
                    gEditingWidget:SetEditing(false)
                end
                
                assert(gEditingWidget == nil) -- should be cleared by the above.
                
                gEditingWidget = self
                self:HookEvent(self, "OnDestroy", OnEditableDestroyedWhileBeingEdited)
                
                self:PauseEvents()
                    
                    old_SetEditing(self, true)
                    
                    -- Call the optional method, if it exists.
                    if self._BeginEditing then
                        self:_BeginEditing()
                    end
                    
                    self:HookEvent(GetGlobalEventDispatcher(), "OnGUIObjectClicked", OnGUIObjectClicked)
                    
                self:ResumeEvents()
                
            else
                -- Ending the editing of this widget.
                if gEditingWidget ~= nil then
                    assert(gEditingWidget == self) -- How were we being edited if we weren't "the one"?
                    gEditingWidget = nil
                end
                
                self:UnHookEvent(self, "OnDestroy", OnEditableDestroyedWhileBeingEdited)
                
                self:PauseEvents()
                    
                    old_SetEditing(self, false)
                    
                    -- Call the optional method, if it exists.
                    if self._EndEditing then
                        self:_EndEditing()
                    end
                    
                    self:UnHookEvent(GetGlobalEventDispatcher(), "OnGUIObjectClicked", OnGUIObjectClicked)
                    
                self:ResumeEvents()
                
            end
            
        end
        
    end,
}
