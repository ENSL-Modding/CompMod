-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuOptionsBarButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Button for the options menu's button bar.
--
--  Properties:
--      Enabled             -- Whether or not the button can be interacted with.
--      MouseOver           -- Whether or not the mouse is over the button (regardless of
--                             enabled-state).
--      Pressed             -- Whether or not the button is being pressed in by the mouse.
--      Points              -- A table that is an array of Vector points that correspond to the
--                             (ordered) points of the polygon.  These points are specified in
--                             parent-local space.  This object's Position and Size will be set to
--                             the bounding box of the points.
--      Label               -- The text displayed in this button.
--      LabelOffset         -- An offset added to the label position to make it sit better.
--      Glowing             -- Whether or not the glow effect underneath the button is active.
--                             This glow is used to indicate the currently active menu.
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/widgets/GUIMenuShapedButton.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/GUI/utilities/Polygon.lua")

---@class GUIMenuOptionsBarButton : GUIMenuShapedButton
class "GUIMenuOptionsBarButton" (GUIMenuShapedButton)

GUIMenuOptionsBarButton:AddClassProperty("Glowing", false)

GUIMenuOptionsBarButton:AddCompositeClassProperty("_GlowColor", "glow", "Color")

local kLightTexture = PrecacheAsset("ui/newMenu/optionsNavBarButtonLight.dds")

local function OnGlowingChanged(self, glowing)
    
    local goalOpacity = glowing and 1.0 or 0.0
    local goalColor = Color(1, 1, 1, goalOpacity)
    self:AnimateProperty("_GlowColor", goalColor, MenuAnimations.Fade)
    
end

function GUIMenuOptionsBarButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuShapedButton.Initialize(self, params, errorDepth)
    
    self.text:SetLayer(2)
    
    self.glow = self:CreateGUIItem()
    self.glow:SetTexture(kLightTexture)
    self.glow:SetSizeFromTexture()
    self.glow:AlignCenter()
    self.glow:SetColor(1, 1, 1, 0)
    self.glow:SetLayer(1)
    
    self:HookEvent(self, "OnGlowingChanged", OnGlowingChanged)
    
end

function GUIMenuOptionsBarButton:SetGlowOffset(offset)
    self.glow:SetPosition(offset)
end
