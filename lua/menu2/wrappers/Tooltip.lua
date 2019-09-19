-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/wrappers/Tooltip.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Class wrapper that adds a tooltip to a widget.
--  
--  Parameters (* = required)
--      tooltip
--      tooltipIcon
--  
--  Properties
--      Tooltip         Text that is displayed for the tooltip, or "" if disabled.
--      TooltipIcon     Path to an texture to be displayed underneath the tooltip text, or "" if
--                      disabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

-- Annotations (copy+paste under @class where this wrapper is used).
--[===[
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
--]===]

Script.Load("lua/GUI/wrappers/WrapperUtility.lua")
Script.Load("lua/menu2/GUIMenuTooltip.lua")

DefineClassWrapper
{
    name = "Tooltip",
    classBuilderFunc = function(wrappedClass, baseClass)
        wrappedClass:AddClassProperty("Tooltip", "")
        wrappedClass:AddClassProperty("TooltipIcon", "")
        wrappedClass.Initialize = GetCachedExtendedMethod("Initialize", wrappedClass, baseClass,
        function(newClass, oldClass)
            return function(self, params, errorDepth)
                errorDepth = (errorDepth or 1) + 1
                
                if type(params) ~= "table" then
                    error(string.format("TooltipWrapped Initialize method expects first parameter to be table of option parameters, got %s-type instead.", GetTypeName(params)), errorDepth)
                end
                
                RequireType({"string", "nil"}, params.tooltip, "params.tooltip", errorDepth)
                RequireType({"string", "nil"}, params.tooltipIcon, "params.tooltipIcon", errorDepth)
                
                oldClass.Initialize(self, params, errorDepth)
                
                if params.tooltip then
                    self:SetTooltip(params.tooltip)
                end
    
                if params.tooltipIcon then
                    self:SetTooltipIcon(params.tooltipIcon)
                end
                
                GetGUIMenuTooltipManager():RegisterTooltipObject(self)
            end
        end)
    end,
}
