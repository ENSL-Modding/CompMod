-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnIcon.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Icon to be displayed in a column of a server browser entry.
--    Takes 2 images to use as the icon graphics (can be provided as parameters, or set in an
--    extending class).
--      - regularTexture
--      - glowingTexture
--
--  Properties:
--      Glowing     Whether or not this button is glowing (eg it glows when entry it belongs to is
--                  selected).
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")

---@class GMSBColumnIcon : GUIObject
class "GMSBColumnIcon" (GUIObject)

GMSBColumnIcon:AddClassProperty("Glowing", false)

local kDefaultSize = Vector(80, 80, 0)

local function UpdateGlowing(self)
    
    self.glowingGraphic:SetVisible(self:GetGlowing())
    self.graphic:SetVisible(not self:GetGlowing())
    
end

local function RequireTexturePath(self, params, texturePathName, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    local requiredTypes = {"nil"}
    if not self[texturePathName] then
        -- texture not provided at class level, require it as a parameter.
        requiredTypes[#requiredTypes+1] = "string"
    end
    
    RequireType(requiredTypes, params[texturePathName], string.format("params.%s", texturePathName), errorDepth)
    
end

function GMSBColumnIcon:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"boolean", "nil"}, params.glowing, "params.glowing", errorDepth)
    
    -- Ensure textures are provided as either parameters, or specified in the class.
    RequireTexturePath(self, params, "regularTexture", errorDepth)
    RequireTexturePath(self, params, "glowingTexture", errorDepth)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    if params.regularTexture then
        self.regularTexture = params.regularTexture
    end
    
    if params.glowingTexture then
        self.glowingTexture = params.glowingTexture
    end
    
    assert(self.regularTexture)
    assert(self.glowingTexture)
    
    self.graphic = self:CreateGUIItem()
    self.graphic:SetTexture(self.regularTexture)
    self.graphic:SetSizeFromTexture()
    self.graphic:SetColor(MenuStyle.kLightGrey)
    self.graphic:AlignCenter()
    
    self.glowingGraphic = self:CreateGUIItem()
    self.glowingGraphic:SetTexture(self.glowingTexture)
    self.glowingGraphic:SetSizeFromTexture()
    self.glowingGraphic:AlignCenter()
    
    self:HookEvent(self, "OnGlowingChanged", UpdateGlowing)
    
    UpdateGlowing(self)
    
    self:SetSize(kDefaultSize)
    
end
