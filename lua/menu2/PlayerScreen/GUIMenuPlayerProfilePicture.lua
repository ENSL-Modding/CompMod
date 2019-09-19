-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/PlayerScreen/GUIMenuPlayerProfilePicture.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Simple class for displaying the user's profile picture, and adding in button-like behavior.
--
--  Parameters (* = required)
--
--
--  Properties
--
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIButton.lua")

---@class GUIMenuPlayerProfilePicture : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuPlayerProfilePicture" (baseClass)

GUIMenuPlayerProfilePicture:AddClassProperty("_Flash", 0.0)

local function OnFXStateChanged(self, state, prevState)
    
    if state == "pressed" then
        self.back:ClearPropertyAnimations("StrokeWidth")
        self.back:SetStrokeWidth(MenuStyle.kStrokeWidth)
        self.back:ClearPropertyAnimations("StrokeColor")
        self.back:SetStrokeColor((MenuStyle.kHighlight + MenuStyle.kBasicStrokeColor)*0.5)
        self.graphic:ClearPropertyAnimations("Color")
        self.graphic:SetColor(Color(1, 1, 1, 0.5))
    elseif state == "hover" then
        if prevState == "pressed" then
            self.back:AnimateProperty("StrokeWidth", 3, MenuAnimations.Fade)
            self.back:AnimateProperty("StrokeColor", MenuStyle.kHighlight, MenuAnimations.Fade)
            self.graphic:AnimateProperty("Color", Color(1, 1, 1, 1), MenuAnimations.Fade)
        else
            PlayMenuSound("ButtonHover")
            DoColorFlashEffect(self.back, "StrokeColor")
            self.back:ClearPropertyAnimations("StrokeWidth")
            self.back:SetStrokeWidth(3)
            DoFlashEffect(self, "_Flash")
        end
    else -- default or disabled (which isn't used).
        self.back:AnimateProperty("StrokeWidth", MenuStyle.kStrokeWidth, MenuAnimations.Fade)
        self.back:AnimateProperty("StrokeColor", MenuStyle.kBasicStrokeColor, MenuAnimations.Fade)
    end

end

function GUIMenuPlayerProfilePicture:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.graphic = CreateGUIObject("graphic", GUIObject, self)
    self.graphic:SetColor(1, 1, 1, 1)
    self.graphic:SetTexture("*avatar")
    self.graphic:AlignCenter()
    self.graphic:SetSyncToParentSize(true)
    SetupFlashEffect(self, "_Flash", self.graphic)
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:AlignCenter()
    self.back:SetSyncToParentSize(true)
    self.back:SetLayer(-1)
    
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)

end
