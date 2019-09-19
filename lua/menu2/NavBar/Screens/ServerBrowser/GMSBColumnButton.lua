-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Toggleable icon button, used in the columns of server entries.  Can be set to glowing, for
--    when the server entry is selected.
--    Takes 4 images to use as the icon graphics (can be provided as parameters, or set in an
--    extending class).
--      - emptyTexture
--      - filledTexture
--      - glowingEmptyTexture
--      - glowingFilledTexture
--
--  Properties:
--      Enabled     Whether or not the button can be interacted with.
--      MouseOver   Whether or not the mouse is over the button (regardless of enabled-state).
--      Pressed     Whether or not the button is being pressed in by the mouse.
--      State       The current state of the button.  Can by the following:
--                      disabled    -- The button cannot be interacted with.
--                      pressed     -- The button is currently being hovered over and pressed down
--                                         on by the user.
--                      hover       -- The mouse is hovering over the button, but not pressed.
--                      active      -- The button is enabled and not being interacted with.
--      Value       Current value of the button's toggle -- true or false.
--      Glowing     Whether or not this button is glowing (eg it glows when entry it belongs to is
--                  selected).
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIToggleButton.lua")

---@class GMSBColumnButton : GUIToggleButton
class "GMSBColumnButton" (GUIToggleButton)

GMSBColumnButton:AddClassProperty("Glowing", false)

local kDefaultSize = Vector(80, 80, 0)

local function UpdateGlowing(self)
    
    self.glowingGraphic:SetVisible(self:GetGlowing())
    self.graphic:SetVisible(not self:GetGlowing())
    
end

local function OnPressed(self)
    
    if self:GetValue() then
        PlayMenuSound("AcceptChoice")
    else
        PlayMenuSound("CancelChoice")
    end
    
end

local function OnValueChanged(self)
    
    if self:GetValue() then
        self.graphic:SetTexture(self.filledTexture)
        self.glowingGraphic:SetTexture(self.glowingFilledTexture)
    else
        self.graphic:SetTexture(self.emptyTexture)
        self.glowingGraphic:SetTexture(self.glowingEmptyTexture)
    end
    
end

local function OnFXStateChanged(self, state, prevState)
    
    if state == "pressed" then
        self.graphic:SetScale(1, 1)
        self.glowingGraphic:SetScale(1, 1)
        self.graphic:SetColor((MenuStyle.kLightGrey + MenuStyle.kHighlight) * 0.5)
        self.glowingGraphic:SetColor(0.75, 0.75, 0.75, 1.0)
    elseif state == "hover" then
        if prevState == "pressed" then
            self.graphic:SetScale(1.1, 1.1)
            self.glowingGraphic:SetScale(1.1, 1.1)
            self.graphic:SetColor(MenuStyle.kHighlight)
            self.glowingGraphic:SetColor(1, 1, 1, 1)
        else
            self.graphic:SetScale(1.1, 1.1)
            self.glowingGraphic:SetScale(1.1, 1.1)
            self.graphic:SetColor(MenuStyle.kHighlight)
            self.glowingGraphic:SetColor(1, 1, 1, 1)
            PlayMenuSound("ButtonHover")
        end
    elseif state == "default" then
        self.graphic:SetScale(1, 1)
        self.glowingGraphic:SetScale(1, 1)
        self.graphic:SetColor(MenuStyle.kLightGrey)
        self.glowingGraphic:SetColor(1, 1, 1, 0.75)
    end
    
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

function GMSBColumnButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"boolean", "nil"}, params.glowing, "params.glowing", errorDepth)
    
    -- Ensure textures are provided as either parameters, or specified in the class.
    RequireTexturePath(self, params, "emptyTexture", errorDepth)
    RequireTexturePath(self, params, "filledTexture", errorDepth)
    RequireTexturePath(self, params, "glowingEmptyTexture", errorDepth)
    RequireTexturePath(self, params, "glowingFilledTexture", errorDepth)
    
    GUIToggleButton.Initialize(self, params, errorDepth)
    
    if params.emptyTexture then
        self.emptyTexture = params.emptyTexture
    end
    
    if params.filledTexture then
        self.filledTexture = params.filledTexture
    end
    
    if params.glowingEmptyTexture then
        self.glowingEmptyTexture = params.glowingEmptyTexture
    end
    
    if params.glowingFilledTexture then
        self.glowingFilledTexture = params.glowingFilledTexture
    end
    
    assert(self.emptyTexture)
    assert(self.filledTexture)
    assert(self.glowingEmptyTexture)
    assert(self.glowingFilledTexture)
    
    self.graphic = self:CreateGUIItem()
    self.graphic:SetTexture(self.emptyTexture)
    self.graphic:SetSizeFromTexture()
    self.graphic:SetColor(MenuStyle.kLightGrey)
    self.graphic:AlignCenter()
    
    self.glowingGraphic = self:CreateGUIItem()
    self.glowingGraphic:SetTexture(self.glowingEmptyTexture)
    self.glowingGraphic:SetSizeFromTexture()
    self.glowingGraphic:AlignCenter()
    
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    self:HookEvent(self, "OnPressed", OnPressed)
    self:HookEvent(self, "OnValueChanged", OnValueChanged)
    self:HookEvent(self, "OnGlowingChanged", UpdateGlowing)
    
    UpdateGlowing(self)
    
    self:SetSize(kDefaultSize)
    
end
