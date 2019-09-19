-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/layouts/GUIListLayout.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Layout that arranges children one after the other, in order, with some margin between them.
--  
--  Parameters (* = required)
--      autoArrange
--      backPadding
--      deferredArrange     If true, this layout will _not_ rearrange itself until the end of
--                          the frame.  Saves a lot of performance if it has a lot of objects to
--                          arrange and is updated frequently.  However, any side effects of
--                          _Arrange() will not be seen until the end of the frame.
--      fixedMinorSize
--      frontPadding
--     *orientation         The orientation of the layout.  Expects either "horizontal" or
--                          "vertical".
--      spacing
--  
--  Properties:
--      AutoArrange         Whether or not the layout will update the arrangement on its own.
--                          If false, the programmer must either call ArrangeNow() or set auto
--                          arrange back to true, otherwise the layout will never update!
--      BackPadding         How much extra space to add to the back of the layout (right padding
--                          in horizontal layout, bottom padding in vertical layout).
--      FixedMinorSize      Whether or not the minor size (eg height in a horizontal layout) is
--                          fixed to the size it's set to, or if it adjusts to the size of the
--                          contents.
--      FrontPadding        How much extra space to add to the front of the layout (left padding
--                          in horizontal layout, top padding in vertical layout).
--      Spacing             How much spacing to add between items.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/layouts/GUIOrientedLayout.lua")

---@class GUIListLayout : GUIOrientedLayout
class "GUIListLayout" (GUIOrientedLayout)

GUIListLayout:AddClassProperty("Spacing", 0)
GUIListLayout:AddClassProperty("FixedMinorSize", false)

function GUIListLayout.GetRelevantPropertyNames(nameTable)
    table.insert(nameTable, "Spacing")
    table.insert(nameTable, "FixedMinorSize")
end

local function GetExpansion(item)
    local itemOwner = GetOwningGUIObject(item)
    if itemOwner and itemOwner:GetPropertyExists("Expansion") then
        local result = itemOwner:GetExpansion()
        return result
    end
    return 1.0
end

function GUIListLayout:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"number", "nil"}, params.spacing, "params.spacing", errorDepth)
    RequireType({"boolean", "nil"}, params.fixedMinorSize, "params.fixedMinorSize", errorDepth)
    
    GUIOrientedLayout.Initialize(self, params, errorDepth)
    
    if params.spacing then
        self:SetSpacing(params.spacing)
    end
    
    if params.fixedMinorSize ~= nil then
        self:SetFixedMinorSize(params.fixedMinorSize)
    end
    
end

function GUIListLayout:_Arrange(items)
    
    PROFILE("GUIListLayout:_Arrange")
    
    local majorAxis = self:GetMajorAxis()
    local minorAxis = self:GetMinorAxis()
    
    local frontPadding = self:GetFrontPadding()
    local backPadding = self:GetBackPadding()
    local spacing = self:GetSpacing()
    local fixedMinorSize = self:GetFixedMinorSize()
    
    local currentMajor = frontPadding
    local maximumMinorSize = 0
    
    for i=1, #items do
        
        local item = items[i]
        
        if item:GetVisible() then
            
            local owner = GetOwningGUIObject(item)
            local itemLocalSize = item:GetSize() * item:GetScale()
        
            item:SetHotSpot(minorAxis * item:GetHotSpot())
            item:SetAnchor(minorAxis * item:GetAnchor())
        
            local expansion = GetExpansion(item)
            local majorSizeSansExpansion = (Dot2D(majorAxis, itemLocalSize) + spacing)
            local majorSize = majorSizeSansExpansion * expansion
        
            local newPosition = majorAxis * (currentMajor - (1.0 - expansion) * majorSizeSansExpansion) + minorAxis * Dot2D(minorAxis, item:GetPosition())
        
            if owner and owner ~= self then
                owner:SetPosition(newPosition)
            else
                item:SetPosition(newPosition)
            end
        
            currentMajor = currentMajor + majorSize
            maximumMinorSize = math.max(maximumMinorSize, Dot2D(minorAxis, itemLocalSize))
            
        end
        
    end
    
    currentMajor = currentMajor + backPadding
    currentMajor = math.max(0, currentMajor - spacing)
    
    local finalMinorSize
    if fixedMinorSize then
        finalMinorSize = Dot2D(minorAxis, self:GetSize())
    else
        finalMinorSize = maximumMinorSize
    end
    
    self:SetSize(majorAxis * currentMajor + minorAxis * finalMinorSize)
    
end
