-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/PlayerScreen/Badges/GUIMenuBadgesLayout.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A horizontal list layout for the badge selection menu that animates positions of its items,
--    and has spacing between items.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/layouts/GUILayout.lua")

---@class GUIMenuBadgesLayout : GUILayout
class "GUIMenuBadgesLayout" (GUILayout)

GUIMenuBadgesLayout:AddClassProperty("Spacing", 0)

function GUIMenuBadgesLayout:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "deferredArrange", true)
    GUILayout.Initialize(self, params, errorDepth)
    PopParamChange(params, "deferredArrange")

end

function GUIMenuBadgesLayout.GetRelevantPropertyNames(nameTable)
    table.insert(nameTable, "Spacing")
end

function GUIMenuBadgesLayout:_Arrange(items)
    
    PROFILE("GUIMenuBadgesLayout:_Arrange")
    
    local frontPadding = self:GetFrontPadding()
    local backPadding = self:GetBackPadding()
    local spacing = self:GetSpacing()
    local currentX = frontPadding
    local maxWidth = 0
    
    for i=1, #items do
        
        local item = items[i]
        local obj = GetOwningGUIObject(item)
        local itemLocalSize = obj:GetSize() * obj:GetScale()
        
        obj:SetHotSpot(0, obj:GetHotSpot().y)
        obj:SetAnchor(0, obj:GetAnchor().y)
        
        local width = itemLocalSize.x + spacing
        
        local position = Vector(currentX, obj:GetPosition().y, 0)
        
        obj:AnimateProperty("Position", position, MenuAnimations.FlyIn)
        
        currentX = currentX + width
        maxWidth = math.max(maxWidth, itemLocalSize.x)
    
    end
    
    currentX = currentX + backPadding
    currentX = math.max(currentX, 0)
    
    local newSize = Vector(currentX, self:GetSize().y, 0)
    self:AnimateProperty("Size", newSize, MenuAnimations.FlyIn)

end
