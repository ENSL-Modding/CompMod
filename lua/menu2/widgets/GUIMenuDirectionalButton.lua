-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuDirectionalButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu themed directional button that has a texture.
--
--  Parameters (* = required)
--      defaultColor    The color of the graphic when not highlighted or disabled.  Defaults to
--                      MenuStyle.kLightGrey.
--      disabledColor   The color of the graphic when disabled.  Defaults to MenuStyle.kDarkGrey.
--      highlightColor  The color of the graphic when highlighted.  Defaults to
--                      MenuStyle.kHighlight.
--     *texture         Texture file to use.
--      directionOffset How many 90 degree turns the graphic must be rotated to match the direction.
--
--  Properties:
--      Enabled     Whether or not the button can be interacted with.
--      MouseOver   Whether or not the mouse is over the button (regardless of enabled-state).
--      Pressed     Whether or not the button is being pressed in by the mouse.
--      Direction   The direction the button points.
--
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIDirectionalButton.lua")
Script.Load("lua/menu2/GUIMenuGraphic.lua")

---@class GUIMenuDirectionalButton : GUIDirectionalButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIDirectionalButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuDirectionalButton" (baseClass)

local function UpdateDirection(self)
    
    local direction = self:GetDirection()
    local directionIndex = GUIDirectionalButton.DirectionToIndex(direction)
    
    -- adjust for the graphic's orientation.
    directionIndex = (directionIndex + self.directionOffset) % 4
    
    local angle = GUIDirectionalButton.DirectionIndexToAngle(directionIndex)
    self.graphic:SetAngle(angle)
    
    local graphicSize = self.graphic:GetSize()
    
    -- Transpose dimensions of graphic to make it match with rotation on every odd index
    if (directionIndex % 2) == 1 then
        self:SetSize(graphicSize.y, graphicSize.x)
    else
        self:SetSize(graphicSize)
    end
    
end

local function OnPressed()
    PlayMenuSound("ScrollSound")
end

function GUIMenuDirectionalButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType("string", params.texture, "params.texture", errorDepth)
    RequireType({"number", "nil"}, params.directionOffset, "params.directionOffset", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.directionOffset = params.directionOffset or 0
    
    self.graphic = CreateGUIObject("graphic", GUIMenuGraphic, self, params)
    
    self.graphic:SetTexture(params.texture)
    self.graphic:SetSizeFromTexture()
    self.graphic:AlignCenter()
    self.graphic:SetRotationOffset(0.5, 0.5)
    self.graphic:HookEvent(self, "OnOpacityChanged", self.graphic.SetOpacity)
    
    self:HookEvent(self, "OnPressed", OnPressed)
    self:HookEvent(self, "OnDirectionChanged", UpdateDirection)
    
    self:SetSize(self.graphic:GetSize())
    
    UpdateDirection(self)
    
end
