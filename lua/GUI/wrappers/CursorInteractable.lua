-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/wrappers/CursorInteractable.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Class wrapper that makes a class interactable with the mouse cursor.
--
--  Parameters (* = required)
--      cursorController    CursorInteractable that "owns" this object, and will receive cursor
--                          events instead of this one.  This object will receive cursor events that
--                          are forwarded to it from the owner object.
--
--  Properties
--      MouseOver       Whether or not the mouse is currently over the object.
--      Pressed         Whether or not the mouse is pressed down on this object.  Does not matter if
--                      the mouse is over the object, only that it was over it when it was clicked
--                      down, and has yet to be released.
--
--  Optional Properties (will be used if present, otherwise ignored)
--      Enabled
--
--  Events
--      OnPressed       Fires whenever the object is clicked and released on, while enabled.
--
--  Added Methods
--      AddCursorInteractionReceiver        Causes this object to forward its un-consumed cursor
--                                          interactions to this object (if the cursor is over it).
--                                          Many objects can be receivers to the same object, so
--                                          they are forwarded in the order that they are added to
--                                          the list... though typically they won't be overlapping
--                                          anyways, so it shouldn't really matter.  This is done
--                                          automatically if the receiving object is created with
--                                          the owning object as the "cursorController" parameter.
--      RemoveCursorInteractionReceiver     Removes the object from the list of receivers of this
--                                          object.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

-- Annotations (copy+paste under @class where this wrapper is used).
--[===[
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
--]===]

Script.Load("lua/GUI/wrappers/WrapperUtility.lua")

DefineClassWrapper
{
    name = "CursorInteractable",
    classBuilderFunc = function(wrappedClass, baseClass)

        wrappedClass:AddClassProperty("MouseOver", false)
        wrappedClass:AddClassProperty("Pressed", false)

        wrappedClass.OnMouseEnter = GetCachedExtendedMethod("OnMouseEnter", wrappedClass, baseClass,
            function(newClass, oldClass)
                return function(self)
                    oldClass.OnMouseEnter(self)
                    self:SetMouseOver(true)
                end
            end)

        wrappedClass.OnMouseExit = GetCachedExtendedMethod("OnMouseExit", wrappedClass, baseClass,
            function(newClass, oldClass)
                return function(self)
                    oldClass.OnMouseExit(self)
                    self:SetMouseOver(false)
                end
            end)

        wrappedClass.OnMouseClick = GetCachedExtendedMethod("OnMouseClick", wrappedClass, baseClass,
            function(newClass, oldClass)
                return function(self, double)
                    oldClass.OnMouseClick(self, double)
                    if not double and (not self.GetEnabled or self:GetEnabled()) then
                        self:SetPressed(true)
                    end
                end
            end)

        wrappedClass.OnMouseCancel = GetCachedExtendedMethod("OnMouseCancel", wrappedClass, baseClass,
            function(newClass, oldClass)
                return function(self)
                    oldClass.OnMouseCancel(self)
                    self:SetPressed(false)
                end
            end)

        wrappedClass.OnMouseRelease = GetCachedExtendedMethod("OnMouseRelease", wrappedClass, baseClass,
            function(newClass, oldClass)
                return function(self)
                    oldClass.OnMouseRelease(self)
                    if self:GetPressed() then
                        local wasEnabled = not self.GetEnabled or self:GetEnabled()
                        self:SetPressed(false)
                        if wasEnabled then
                            self:FireEvent("OnPressed")
                        end
                    end
                end
            end)
        
        wrappedClass.Initialize = GetCachedExtendedMethod("Initialize", wrappedClass, baseClass,
            function(newClass, oldClass)

                -- CursorInteractable Initialize()
                return function(self, params, errorDepth)
                    errorDepth = (errorDepth or 1) + 1
    
                    if params.cursorController ~= nil then
                        RequireIsa("GUIObject", params.cursorController, "params.cursorController", errorDepth)
                        RequireHasWrapper("CursorInteractable", params.cursorController, "params.cursorController", errorDepth)
                    end
                    
                    oldClass.Initialize(self, params, errorDepth)
    
                    if params.cursorController then
                        self.cursorController = params.cursorController
                    end
    
                    if not self.cursorController then
                        -- Only listen for cursor interactions if this object has no cursorController.
                        self:ListenForCursorInteractions()
                    end

                end
            end)

    end,
}
