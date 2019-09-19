-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuTooltipManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Singleton class that manages tooltip interactions for the new menu system.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/BaseGUIManager.lua")

---@class GUIMenuTooltipManager : BaseGUIManager
class "GUIMenuTooltipManager" (BaseGUIManager)

GUIMenuTooltipManager.Interaction_Tooltip = GUIItem.Interaction_4

-- Used to receive sorted list of eligible GUIItem event receivers.  Local b/c this should never be
-- used outside of this class.
local guiItemArray = GUIItemArray()

function GUIMenuTooltipManager:Initialize()
    
    -- Mapping of GUIItem --> owning GUIObject that is setup for tooltips.
    self.tooltipListenerItems = {}
    
end

function GUIMenuTooltipManager:OnObjectDestroyed(guiObject)
    
    if guiObject:GetRootItem():IsOptionFlagSet(GUIMenuTooltipManager.Interaction_Tooltip) then
        GetTooltip():OnTooltipObjectDestroyed(guiObject)
    end
    
end

function GUIMenuTooltipManager:Update(deltaTime, now)
    
    local mousePos = GetGlobalEventDispatcher():GetMousePosition()
    GUI.GetInteractionsUnderPoint(guiItemArray, mousePos.x, mousePos.y, GUIMenuTooltipManager.Interaction_Tooltip, GetGUIInteractionManager():GetModalItem())
    
    local newTooltipHoverObj
    for i=0, guiItemArray:GetSize() - 1 do
        
        local triggeringItem = guiItemArray:Get(i)
        
        local guiObject = GetOwningGUIObject(triggeringItem)
        if guiObject == nil then
            error("triggeringItem for tooltip manager Update() did not have an owning GUIObject!  Was GUIMenuTooltipManager.Interaction_Tooltip flag set on an item outside this manager? (wags finger)")
        end
        
        if guiObject:IsPointOverObject(mousePos) and guiObject:GetOpacity(true) > 0.5 then
            newTooltipHoverObj = guiObject
            break
        end
        
    end
    
    -- Some items are part of this interaction layer just to block (eg the back of a window).
    if newTooltipHoverObj == nil or newTooltipHoverObj.GetTooltip == nil then
        GetTooltip():SetCurrentHoverObject(nil)
    else
        GetTooltip():SetCurrentHoverObject(newTooltipHoverObj)
    end
    
end

-- Make a non tooltip object interact with tooltips (so it blocks ones underneath it).
function GUIMenuTooltipManager:SetBlocksTooltips(objOrItem)

    local item
    if GetIsaGUIObject(objOrItem) then
        item = objOrItem:GetRootItem()
    elseif GetIsaGUIItem(objOrItem) then
        item = objOrItem
    else
        error(string.format("Expected a GUIItem or GUIObject-based type.  Got %s-type instead.", GetTypeName(objOrItem)), 2)
    end

    item:SetOptionFlag(GUIMenuTooltipManager.Interaction_Tooltip)

end

-- Hooks up events to register this object as having a tooltip.
function GUIMenuTooltipManager:RegisterTooltipObject(obj)
    
    AssertIsaGUIObject(obj)
    
    if type(obj.GetTooltip) ~= "function" then
        error("Attempted to call GUIMenuTooltipManager:RegisterTooltipObject() with object that does not have method 'GetTooltip()'.  (This method is automatically added by having a property called 'Tooltip'.)", 2)
    end
    
    obj:GetRootItem():SetOptionFlag(GUIMenuTooltipManager.Interaction_Tooltip)
    self.tooltipListenerItems[obj:GetRootItem()] = obj
    
end

SetupGUIManager("GUIMenuTooltipManager")
