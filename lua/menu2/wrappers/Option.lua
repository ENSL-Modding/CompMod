-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/wrappers/Option.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Class wrapper that couples a widget with the options menu.  This shouldn't be used for non-
--    options-menu widgets.  For non options-menu widgets whose values we want to sync to a config
--    option, use the AutoOption wrapper.
--  
--  Parameters (* = required)
--      optionPath              Path to the option, used by the engine to save the value.
--      optionType              Can be "bool", "int", "float", or "string".
--      default                 Default value to use if the option has not been set before.
--      immediateUpdate         function to call whenever the option changes (eg to preview a
--                              graphics option).
--      reloadGraphicsOptions   Whether this option requires a reload of the graphics options by
--                              the engine whenever it is applied.
--      revertGraphicsOptions   Whether this option requires a reload of the graphics options by
--                              the engine whenever it is reverted.
--      fullRestart             The game client requires a full restart in order to apply this
--                              option -- and not just a restart that can be applied automatically.
--      autoRestart             The game client requires a restart to apply this option, but it can
--                              be applied automatically so long as the user is not in-game.
--      alternateSetter         An alternate function to use to set the option from the widget.
--      alternateGetter         An alternate function to use to set the widget from the option.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

-- Annotations (copy+paste under @class where this wrapper is used).
--[===[
<none for this wrapper>
--]===]

Script.Load("lua/GUI/wrappers/WrapperUtility.lua")

local function OptionWrapped_OnValueChanged(self, value, prevValue)
    GetOptionsMenu():OnOptionChanged(self, value, prevValue)
end

local function KeybindImmediateUpdateFunc(self)
    local oldValue = Client.GetOptionString(self.optionPath, self.default)
    local value = self:GetValue()
    Client.SetOptionString(self.optionPath, value)
    Input_SyncInputOptions()
    Client.SetOptionString(self.optionPath, oldValue)
end

DefineClassWrapper
{
    name = "Option",
    classBuilderFunc = function(wrappedClass, baseClass)
        wrappedClass.Initialize = GetCachedExtendedMethod("Initialize", wrappedClass, baseClass,
        function(newClass, oldClass)
            return function(self, params, errorDepth)
                errorDepth = (errorDepth or 1) + 1
                
                if type(params) ~= "table" then
                    error(string.format("OptionWrapped Initialize method expects first parameter to be table of option parameters, got %s-type instead.", GetTypeName(params)), errorDepth)
                end
                
                RequireType({"function", "nil"}, params.immediateUpdate, "params.immediateUpdate", errorDepth)
                
                oldClass.Initialize(self, params, errorDepth)
                GetOptionsMenu():RegisterOptionWidget(self, params)
                self:HookEvent(self, "OnValueChanged", OptionWrapped_OnValueChanged)
                
                -- Load initial values from option.
                self.optionPath = params.optionPath
                self.optionType = params.optionType
                self.default = params.default
                self.immediateUpdate = params.immediateUpdate
                self.reloadGraphicsOptions = params.reloadGraphicsOptions
                self.revertGraphicsOptions = params.revertGraphicsOptions
                self.fullRestart = params.fullRestart
                self.autoRestart = params.autoRestart
                self.alternateSetter = params.alternateSetter
                self.alternateGetter = params.alternateGetter
                
                SetWidgetValueFromOption(self)
                
                -- Keybinds should always update immediately.  Provide an immediateUpdate function
                -- if one is not already provided.
                if self.GetKeybindWidget and not self.immediateUpdate then
                    self.immediateUpdate = KeybindImmediateUpdateFunc
                end
                
                -- Keybinds also have an extra option value to keep track of whether or not they
                -- are "inheriting" another keybind's value.  Setup the extra callback for this.
                if self.GetKeybindWidget and (self.keybind.inheritFromName or self.keybind.inheritFrom) then
                    self:HookEvent(self.keybind, "OnIsInheritedChanged",
                        function(self, value, prevValue)
                            GetOptionsMenu():OnSubOptionChanged(self, "inherited", value, prevValue)
                        end)
                end
                
                -- Setup immediate update for options that specify it.
                if self.immediateUpdate then
                    self:HookEvent(self, "OnValueChanged", self.immediateUpdate)
                end
                
            end
        end)
    end,
}
