-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/wrappers/Expandable.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Class wrapper that makes a widget "Expandable".  This means the widget can be shown/hidden,
--    and it does so with a slick sliding/cropping animation.  Widgets that are un-expanded cannot
--    be interacted with.
--  
--  Parameters (* = required)
--      expansionMargin     Extra margin (in local-space pixels) added to expansion crop values to
--                          help prevent item from being cropped too tightly.  This value is
--                          interpolated with expansion, so it has no effect when expansion is at
--                          0.
--                          For example, if an item has a drop shadow effect, we need to crop it a
--                          little more generously than the object's actual bounds.  In this case,
--                          we should set expansionMargin to the radius of the drop shadow effect.
--      expanded
--      noExpansionChanged  Skip setting up the hook for the default OnExpansionChanged function.
--      noCropWhenFullyVisible  Whether or not to disable cropping when expansion is at 1.0.
--  
--  Properties
--      Expanded    Whether or not the widget is in (or at least transitioning to) its "Expanded"
--                  (ie visible) state.
--      Expansion   The current fraction of the expansion being shown.  This animates between 0
--                  and 1.  When Expanded is false, this value is equal to -- or animating towards
--                  0.  Likewise when expanded is true, this value is moving towards 1.  This
--                  should not be set manually.  To show/hide a widget, use SetExpanded(), not
--                  SetExpansion().
--
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

-- Annotations (copy+paste under @class where this wrapper is used).
--[===[
---@field public GetExpanded function @From Expandable wrapper
---@field public SetExpanded function @From Expandable wrapper
---@field public GetExpansion function @From Expandable wrapper
--]===]

Script.Load("lua/GUI/wrappers/WrapperUtility.lua")
Script.Load("lua/menu2/MenuStyles.lua")

local function OnExpansionChanged(self, expansion)
    expansion = Clamp(expansion, 0, 1)
    
    if expansion == 1 and self.noCropWhenFullyVisible then
        
        self:ClearCropRectangle()
        
    elseif self.expansionMargin then
        
        -- Add some extra margin to the expansion fraction.
        local size = self:GetSize()
        local maxExtraX = self.expansionMargin / math.abs(size.x)
        local maxExtraY = self.expansionMargin / math.abs(size.y)
        
        local left = -maxExtraX * expansion
        local right = maxExtraX * expansion + 1
        local top = (1 - expansion) + -maxExtraY * expansion
        local bottom = maxExtraY * expansion + 1
        
        self:SetCropMin(left, top)
        self:SetCropMax(right, bottom)
        
    else
        
        self:SetCropMin(0, 1 - expansion)
        self:SetCropMax(1, 1)
        
    end
    
end

local function OnExpandedChanged(self, expanded)
    
    local goal = expanded and 1 or 0
    self:AnimateProperty("Expansion", goal, MenuAnimations.FlyIn)
    
    if expanded then
        self:AllowChildInteractions()
    else
        self:BlockChildInteractions()
    end
    
end

DefineClassWrapper
{
    name = "Expandable",
    classBuilderFunc = function(wrappedClass, baseClass)
        wrappedClass:AddClassProperty("Expansion", 1.0)
        wrappedClass:AddClassProperty("Expanded", true)
        wrappedClass.Initialize = GetCachedExtendedMethod("Initialize", wrappedClass, baseClass,
        function(newClass, oldClass)
            return function(self, params, errorDepth)
                errorDepth = (errorDepth or 1) + 1
                
                RequireType({"number", "nil"}, params.expansionMargin, "params.expansionMargin", errorDepth)
                RequireType({"boolean", "nil"}, params.expanded, "params.expanded", errorDepth)
                RequireType({"boolean", "nil"}, params.noCropWhenFullyVisible, "params.noCropWhenFullyVisible", errorDepth)
                
                oldClass.Initialize(self, params, errorDepth)
                
                -- Allow a margin to be specified to add some extra room around expanded items'
                -- crop zone, to prevent stuff like outer-strokes from getting cropped away.
                self.expansionMargin = params.expansionMargin
                
                self.noCropWhenFullyVisible = params.noCropWhenFullyVisible
                
                self:HookEvent(self, "OnExpansionChanged", OnExpansionChanged)
                self:HookEvent(self, "OnExpandedChanged", OnExpandedChanged)
    
                if params.expanded ~= nil then
                    self:SetExpanded(params.expanded)
                    self:ClearPropertyAnimations("Expansion")
                end
            end
            
        end)
    end,
}
