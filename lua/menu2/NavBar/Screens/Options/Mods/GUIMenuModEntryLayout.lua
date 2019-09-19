-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModEntryLayout.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A special vertical list layout that animates the motion of its items as it arranges them.
--
--  Parameters (* = required)
--      fixedMinorSize
--
--  Properties
--      FixedMinorSize      Whether or not the minor size (ie width) is fixed to the size it's set
--                          to, or if it adjusts to the size of the contents.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/layouts/GUILayout.lua")

---@class GUIMenuModEntryLayout : GUILayout
class "GUIMenuModEntryLayout" (GUILayout)

GUIMenuModEntryLayout:AddClassProperty("FixedMinorSize", false)

local function GetExpansion(item)
    local itemOwner = GetOwningGUIObject(item)
    if itemOwner and itemOwner:GetPropertyExists("Expansion") then
        local result = itemOwner:GetExpansion()
        return result
    end
    return 1.0
end

function GUIMenuModEntryLayout.GetRelevantPropertyNames(nameTable)
    table.insert(nameTable, "FixedMinorSize")
end

function GUIMenuModEntryLayout:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"boolean", "nil"}, params.fixedMinorSize, "params.fixedMinorSize", errorDepth)
    
    PushParamChange(params, "deferredArrange", true)
    GUILayout.Initialize(self, params, errorDepth)
    PopParamChange(params, "deferredArrange")
    
    if params.fixedMinorSize ~= nil then
        self:SetFixedMinorSize(params.fixedMinorSize)
    end

end

function GUIMenuModEntryLayout:_Arrange(items)

    PROFILE("GUIMenuModEntryLayout:_Arrange")

    local frontPadding = self:GetFrontPadding()
    local backPadding = self:GetBackPadding()
    local fixedMinorSize = self:GetFixedMinorSize()
    local currentY = frontPadding
    local maxWidth = 0
    
    for i=1, #items do

        local item = items[i]
        local obj = GetOwningGUIObject(item)
        local itemLocalSize = obj:GetSize() * obj:GetScale()

        obj:SetHotSpot(obj:GetHotSpot().x, 0)
        obj:SetAnchor(obj:GetAnchor().x, 0)

        local expansion = GetExpansion(item)
        local heightSansExpansion = itemLocalSize.y
        local height = heightSansExpansion * expansion

        local position = Vector(obj:GetPosition().x, currentY - (1.0 - expansion) * heightSansExpansion, 0)

        obj:AnimateProperty("Position", position, MenuAnimations.FlyIn)

        currentY = currentY + height
        maxWidth = math.max(maxWidth, itemLocalSize.x)

    end

    currentY = currentY + backPadding
    currentY = math.max(0, currentY)
    
    local finalWidth
    if fixedMinorSize then
        finalWidth = self:GetSize().x
    else
        finalWidth = maxWidth
    end
    
    local newSize = Vector(finalWidth, currentY, 0)
    self:SetSize(newSize)

end
