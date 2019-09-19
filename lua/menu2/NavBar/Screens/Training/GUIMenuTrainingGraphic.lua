-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/Training/GUIMenuTrainingGraphic.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Object that contains a graphic item that resizes preserving its aspect ratio.  Used for the
--    graphics in the training menu.
--
--  Parameters (* = required)
--      texture         Texture path to use.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")

---@class GUIMenuTrainingGraphic : GUIObject
class "GUIMenuTrainingGraphic" (GUIObject)

local function UpdateGraphicScale(self)
    
    local sizeToFill = self:GetSize()
    local graphicSize = self.graphic:GetSize()
    
    local scaleFactor
    if graphicSize.x ~= 0 then
        scaleFactor = sizeToFill.x / graphicSize.x
    end
    if graphicSize.y ~= 0 then
        local yScaleFactor = sizeToFill.y / graphicSize.y
        if scaleFactor == nil then
            scaleFactor = yScaleFactor
        else
            scaleFactor = math.min(math.abs(scaleFactor), math.abs(yScaleFactor))
        end
    end
    
    scaleFactor = scaleFactor or 1.0
    self.graphic:SetScale(scaleFactor, scaleFactor)
    
    self.back:SetSize(self.graphic:GetSize() * self.graphic:GetScale())
    
end

local function OnTextureChanged(self)
    self.graphic:SetTexture(self:GetTexture())
    self.graphic:SetSizeFromTexture()
    UpdateGraphicScale(self)
end

function GUIMenuTrainingGraphic:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.texture, "params.texture", errorDepth)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.graphic = self:CreateGUIItem()
    self.graphic:AlignTop()
    self:HookEvent(self, "OnTextureChanged", OnTextureChanged)
    self:HookEvent(self, "OnSizeChanged", UpdateGraphicScale)
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:SetLayer(-1)
    self.back:AlignTop()
    UpdateGraphicScale(self)
    
    if params.texture then
        self:SetTexture(params.texture)
    end
    
end
