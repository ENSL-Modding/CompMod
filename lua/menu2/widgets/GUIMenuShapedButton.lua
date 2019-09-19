-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuShapedButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    A button whose shape is defined by an arbitrary polygon instead of a rectangle.
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
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIShapedButton.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuShapedButton : GUIShapedButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIShapedButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuShapedButton" (baseClass)

GUIMenuShapedButton:AddCompositeClassProperty("Label", "text", "Text")
GUIMenuShapedButton:AddCompositeClassProperty("LabelOffset", "text", "Position")

local function OnPressed()
    PlayMenuSound("ButtonClick")
end

function GUIMenuShapedButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.text = CreateGUIObject("text", GUIMenuText, self,
    {
        defaultColor = MenuStyle.kOptionHeadingColor,
        font = MenuStyle.kHeadingFont,
    })
    self.text:AlignCenter()
    
    self:HookEvent(self, "OnPressed", OnPressed)
    
end

function GUIMenuShapedButton:SetFont(font)
    self.text:SetFont(font)
end
