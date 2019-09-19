-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBListLayout.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A special vertical list layout that animates the motion of its items as it arranges them.
--    Also updates the "IndexEven" property of the objects it arranges.  This property is used to
--    alternate the colors of adjacent entries.  The index only changes for entries.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/layouts/GUILayout.lua")

---@class GMSBListLayout : GUILayout
class "GMSBListLayout" (GUILayout)

-- Server browser will inform the list layout of where the viewable area starts and ends, that way
-- the list entries' animations can be improved.
GMSBListLayout:AddClassProperty("ViewRegionMin", 0)
GMSBListLayout:AddClassProperty("ViewRegionMax", 100)

local function GetExpansion(item)
    local itemOwner = GetOwningGUIObject(item)
    if itemOwner and itemOwner:GetPropertyExists("Expansion") then
        local result = itemOwner:GetExpansion()
        return result
    end
    return 1.0
end

function GMSBListLayout.GetRelevantChildPropertyNames(nameTable)
    table.insert(nameTable, "FilteredOut")
end

function GMSBListLayout:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "deferredArrange", true)
    GUILayout.Initialize(self, params, errorDepth)
    PopParamChange(params, "deferredArrange")
    
end

local function GetIsEntryVisible(self, y, height)
    
    local viewMin = self:GetViewRegionMin()
    local viewMax = self:GetViewRegionMax()
    
    return y < viewMax and y > viewMin - height
    
end

local function GetEntryYOutsideView(self, y, height)
    
    local viewMin = self:GetViewRegionMin()
    local viewMax = self:GetViewRegionMax()
    
    if y >= viewMax then
        return viewMax
    else
        return viewMin - height
    end
    
end

function GMSBListLayout:_Arrange(items)
    
    PROFILE("GMSBListLayout:_Arrange")
    
    local frontPadding = self:GetFrontPadding()
    local backPadding = self:GetBackPadding()
    local currentY = frontPadding
    local maxWidth = 0
    
    local indexEven = false
    
    for i=1, #items do
        
        local item = items[i]
        local obj = GetOwningGUIObject(item)
        local itemLocalSize = obj:GetSize() * obj:GetScale()
        
        if not obj:GetFilteredOut() then
            obj:SetIndexEven(indexEven)
            indexEven = not indexEven
        end
        
        obj:SetHotSpot(obj:GetHotSpot().x, 0)
        obj:SetAnchor(obj:GetAnchor().x, 0)
        
        local expansion = GetExpansion(item)
        local heightSansExpansion = itemLocalSize.y
        local height = heightSansExpansion * expansion
        
        local position = Vector(obj:GetPosition().x, currentY - (1.0 - expansion) * heightSansExpansion, 0)
        
        local currentlyVisible = GetIsEntryVisible(self, obj:GetPosition().y, obj:GetSize().y)
        local willBeVisible = GetIsEntryVisible(self, position.y, obj:GetSize().y)
        
        if not currentlyVisible and not willBeVisible then
            -- Don't animate object, just set position, since it's not currently visible, and won't
            -- be visible in its final position (and we don't really care to see it flying across
            -- the player's view).
            obj:ClearPropertyAnimations("Position")
            obj:SetPosition(position)
            
        else
            
            if not currentlyVisible then
                -- The object isn't visible right this second, but will be if the player continues to
                -- look where they are now.  Move the item first to juuuust outside the viewable area
                -- before animating so that it has less distance to travel
                
                local newY = GetEntryYOutsideView(self, obj:GetPosition().y, obj:GetSize().y)
                obj:ClearPropertyAnimations("Position")
                obj:SetPosition(obj:GetPosition().x, newY)
                
            end
            
            -- The object is visible, so animate it like normal.
            obj:AnimateProperty("Position", position, MenuAnimations.FlyIn)
            
        end
        
        currentY = currentY + height
        maxWidth = math.max(maxWidth, itemLocalSize.x)
        
    end
    
    currentY = currentY + backPadding
    currentY = math.max(0, currentY)
    
    local newSize = Vector(maxWidth, currentY, 0)
    self:AnimateProperty("Size", newSize, MenuAnimations.FlyIn)
    
end
