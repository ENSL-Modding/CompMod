-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/wrappers/ScrollToView.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Class wrapper that, upon a property change of some property within a given set, will search
--    for a GUIScrollPane-type object, and if found, attempt to set the scroll to bring this object
--    into view.  This wrapper is applied automatically for some wrapper types (eg Editable).
--
--  Parameters (* = required)
--     *scrollToViewPropertyList    List of property names that, when changed, will trigger a search
--                                  and scroll.
--
--  Optional Methods (may be implemented for additional functionality)
--      GetShouldScrollToView       Called to ensure scroll-to-view should happen.  Eg if "Editing"
--                                  is a property that triggers scroll-to-view, we may want it to
--                                  only trigger when editing is true.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

-- Annotations (copy+paste under @class where this wrapper is used).
--[===[
---@field public ScrollToView function @From ScrollToView wrapper
--]===]

Script.Load("lua/GUI/wrappers/WrapperUtility.lua")

local function ScrollToViewInternal(self)
    
    -- Allow object to veto the scroll-to-view procedure.
    if self.GetShouldScrollToView then
        if not self:GetShouldScrollToView() then
            return
        end
    end
    
    -- Find a GUIScrollPane to scroll with.
    local currentObj = self
    while currentObj and not currentObj:isa("GUIScrollPane") do
        currentObj = currentObj:GetParent()
    end
    
    if not currentObj then
        -- Couldn't find an ancestor GUIScrollPane.
        return
    end
    local scrollPane = currentObj
    
    -- Only scroll if the object isn't fully visible.
    local ssSelfPos = GetStaticScreenPosition(self)
    local ssSelfSize = GetStaticAbsoluteSize(self)
    local ssSelfMax = ssSelfPos + ssSelfSize
    
    local ssScrollPos = GetStaticScreenPosition(scrollPane:GetContentsItem())
    local ssScrollSize = GetStaticAbsoluteSize(scrollPane:GetContentsItem())
    local ssScrollMax = ssScrollPos + ssScrollSize
    
    if ssSelfPos.x >= ssScrollPos.x and
       ssSelfPos.y >= ssScrollPos.y and
       ssSelfMax.x <= ssScrollMax.x and
       ssSelfMax.y <= ssScrollMax.y then
       
        -- Fully in-view.  No scrolling necessary.
        return
    end
    
    local pane = scrollPane:GetChildHoldingItem()
    local ssPanePos = GetStaticScreenPosition(pane)
    local paneAbsScale = GetStaticAbsoluteScale(pane)
    local posInScrollPane = (ssSelfPos - ssPanePos) / paneAbsScale
    
    if scrollPane:GetHorizontalScrollBarEnabled() then
        scrollPane.hBar:SetValue(posInScrollPane.x)
    end
    
    if scrollPane:GetVerticalScrollBarEnabled() then
        scrollPane.vBar:SetValue(posInScrollPane.y)
    end

end

local function ScrollToView(self)
    -- DISABLED for now... just too many issues.
    --ScrollToViewInternal(self)
    --self:AddTimedCallback(ScrollToViewInternal, 0) -- bit of a hack... :(
end

DefineClassWrapper
{
    name = "ScrollToView",
    classBuilderFunc = function(wrappedClass, baseClass)
        wrappedClass.Initialize = GetCachedExtendedMethod("Initialize", wrappedClass, baseClass,
        function(newClass, oldClass)
            
            newClass.ScrollToView = ScrollToView
            
            -- ScrollToView wrapper Initialize
            return function(self, params, errorDepth)
                errorDepth = (errorDepth or 1) + 1
                
                RequireType("table", params.scrollToViewPropertyList, "params.scrollToViewPropertyList", errorDepth)
                if #params.scrollToViewPropertyList == 0 then
                    error("params.scrollToViewPropertyList table has length 0.  (Did you accidentally make a set instead?)", 2)
                end
                
                oldClass.Initialize(self, params, errorDepth)
    
                -- Hook all the on-changed events for these properties, to scroll-to-view.
                local hookedSet = {} -- Catch duplicates, which are allowed.
                for i=1, #params.scrollToViewPropertyList do
                    local propertyName = params.scrollToViewPropertyList[i]
                    if not hookedSet[propertyName] then
                        hookedSet[propertyName] = true
                        self:HookEvent(self, self._GetChangedEventNameForProperty(propertyName), ScrollToView)
                    end
                end
                
            end
            
        end)
    end
}
