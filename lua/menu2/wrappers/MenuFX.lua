-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/wrappers/MenuFX.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Wrapper that applies menu themeing effects to simple objects.  Requires the FXState wrapper.
--
--  Parameters (* = required)
--      defaultColor    The color of the graphic when not highlighted or disabled.  Defaults to
--                      MenuStyle.kLightGrey.
--      disabledColor   The color of the graphic when disabled.  Defaults to MenuStyle.kDarkGrey.
--      highlightColor  The color of the graphic when highlighted.  Defaults to
--                      MenuStyle.kHighlight.
--      editingColor    The color of the graphic when being edited.  Defaults to
--                      MenuStyle.kHighlight
--
--  Optional Methods (may be implemented for additional functionality).
--      OnFXStateChangedOverride(self, state, prevState)    Will be called whenever the FXState has
--          changed in order to trigger animations, color changes, sounds, etc.  This override
--          provides a means to override or extend the default menu-theme behavior.  To signal that
--          override behavior has been performed, return true so that none of the other changes take
--          place (unless that's what you want, of course).
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

-- Annotations (copy+paste under @class where this wrapper is used).
--[===[
---@field protected OnFXStateChangedOverride function @From MenuFX wrapper
--]===]

Script.Load("lua/GUI/wrappers/WrapperUtility.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")
Script.Load("lua/menu2/MenuStyles.lua")

local function OnFXStateChanged(self, state, prevState)
    
    if self.OnFXStateChangedOverride and self:OnFXStateChangedOverride(state, prevState) then
        return
    end
    
    if prevState == "editing" then
        PlayMenuSound("AcceptChoice")
    end
    
    if state == "editing" then
        PlayMenuSound("BeginChoice")
        self:AnimateProperty("Color", self.editingColor, MenuAnimations.FadeFast)
    elseif state == "disabled" then
        self:AnimateProperty("Color", self.disabledColor, MenuAnimations.Fade)
    elseif state == "pressed" then
        self:ClearPropertyAnimations("Color")
        self:SetColor((self.defaultColor + self.highlightColor) * 0.5)
    elseif state == "hover" then
        if prevState == "pressed" or prevState == "editing" then
            self:ClearPropertyAnimations("Color")
            self:SetColor(self.highlightColor)
        else
            PlayMenuSound("ButtonHover")
            self:SetColor(self.highlightColor)
            self:AnimateProperty("Color", nil, MenuAnimations.HighlightFlashColor)
        end
    elseif state == "default" then
        self:AnimateProperty("Color", self.defaultColor, MenuAnimations.Fade)
    end
    
end

local function OnEditAccepted(self)
    PlayMenuSound("AcceptChoice")
end

local function OnEditCancelled(self)
    PlayMenuSound("CancelChoice")
end

DefineClassWrapper
{
    name = "MenuFX",
    requiredWrappers = "FXState",
    classBuilderFunc = function(wrappedClass, baseClass)
        
        wrappedClass.Initialize = GetCachedExtendedMethod("Initialize", wrappedClass, baseClass,
        function(newClass, oldClass)
            
            -- MenuFX Initialize()
            return function(self, params, errorDepth)
                errorDepth = (errorDepth or 1) + 1
    
                RequireType({"Color", "nil"}, params.defaultColor, "params.defaultColor", errorDepth)
                RequireType({"Color", "nil"}, params.disabledColor, "params.disabledColor", errorDepth)
                RequireType({"Color", "nil"}, params.highlightColor, "params.highlightColor", errorDepth)
                RequireType({"Color", "nil"}, params.editingColor, "params.editingColor", errorDepth)
                
                oldClass.Initialize(self, params, errorDepth)
                
                self.defaultColor = params.defaultColor or MenuStyle.kLightGrey
                self.disabledColor = params.disabledColor or MenuStyle.kDarkGrey
                self.highlightColor = params.highlightColor or MenuStyle.kHighlight
                self.editingColor = params.editingColor or MenuStyle.kHighlight
                
                self:SetColor(self.defaultColor) -- init
                
                self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
                
                self:HookEvent(self, "OnEditAccepted", OnEditAccepted)
                self:HookEvent(self, "OnEditCancelled", OnEditCancelled)
                
            end
            
        end)
        
    end
}
