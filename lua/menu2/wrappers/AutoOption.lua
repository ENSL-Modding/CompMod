-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/wrappers/AutoOption.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Class wrapper that automatically syncs a widget's value with an option from config.  This is
--    for widgets that are used _OUTSIDE_ the options menu.  For options menu widgets, see
--    wrappers/Option.lua.
--  
--  Parameters (* = required)
--      alternateGetter     Alternative setter function to use in place of Client.GetOption_____()
--                          Function will take no arguments, and will return the value to
--                          initialize the widget to.
--      alternateSetter     Alternative setter function to use in place of Client.SetOption_____()
--                          Function will take one argument, the value, and not return anything.
--     *optionPath          The path to the option, used by functions such as
--                          Client.GetOption______().
--     *optionType          The type of the option.  Can be either "bool", "int", "float", or
--                          "string".  Used to determine which of the 4 Client.Get/SetOption____()
--                          to use.
--     *default             The default value to use if the option has never been set before.  Type
--                          must match that of optionType.
--                          
--                          NOTE: If both alternate setter AND getter functions are provided, then
--                          optionPath, optionType, and default are not required.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

-- Annotations (copy+paste under @class where this wrapper is used).
--[===[
<none for this wrapper>
--]===]

Script.Load("lua/GUI/wrappers/WrapperUtility.lua")

local function OnValueChanged(self, value)
    self.setter(self.optionPath, value)
end

DefineClassWrapper
{
    name = "AutoOption",
    classBuilderFunc = function(wrappedClass, baseClass)
        wrappedClass.Initialize = GetCachedExtendedMethod("Initialize", wrappedClass, baseClass,
        function(newClass, oldClass)
            return function(self, params, errorDepth)
                errorDepth = (errorDepth or 1) + 1
                
                RequireType({"function", "nil"}, params.alternateSetter, "params.alternateSetter", errorDepth)
                RequireType({"function", "nil"}, params.alternateGetter, "params.alternateGetter", errorDepth)
                
                -- Unless both alternates are provided, the user must provide an optionPath, an optionType,
                -- and a default.
                if not params.alternateSetter or not params.alternateGetter then
                    
                    RequireType("string", params.optionPath, "params.optionPath", errorDepth)
                    RequireType("string", params.optionType, "params.optionType", errorDepth)
                    ValidateOptionType(params.optionType, errorDepth)
                    if params.optionType == "bool" then
                        RequireType("boolean", params.default, "params,default", errorDepth)
                    elseif params.optionType == "int" or params.optionType == "float" then
                        RequireType("number", params.default, "params.default", errorDepth)
                        if params.optionType == "int" and params.default ~= math.floor(params.default) then
                            error(string.format("Expected an integer for params.default, got '%s' instead", params.default), errorDepth)
                        end
                    else -- params.optionType == "string"
                        RequireType("string", params.default, "params.default", errorDepth)
                    end
                    
                end
                
                oldClass.Initialize(self, params, errorDepth)
                
                self.optionPath = params.optionPath
                self.setter = params.alternateSetter or GetOptionValueSetterFunctionForType(params.optionType)
                local getter = params.alternateGetter or GetOptionValueGetterFunctionForType(params.optionType)
                
                local initialValue = getter(self.optionPath, params.default)
                self:SetValue(initialValue)
                
                self:HookEvent(self, "OnValueChanged", OnValueChanged)
            end
        end)
    end,
}
