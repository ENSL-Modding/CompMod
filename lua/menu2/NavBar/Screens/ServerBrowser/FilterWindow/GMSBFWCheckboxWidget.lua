-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWCheckboxWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Checkbox and label, themed for the server browser's filter window.
--  
--  Properties
--      Label       Text displayed left of the checkbox.
--      Value       Boolean value for whether or not the checkbox is checked.
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/GUI/widgets/GUIToggleButton.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")

---@class GMSBFWCheckboxWidget : GUIToggleButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIToggleButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GMSBFWCheckboxWidget" (baseClass)

local kDefaultSize = Vector(622, 38, 0)

local kFont = MenuStyle.kServerBrowserFiltersWindowFont
local kLabelColor = MenuStyle.kOptionHeadingColor

local kCheckboxBackgroundSize = Vector(42, 38, 0)
local kCheckboxInsideImage = PrecacheAsset("ui/newMenu/server_browser/filter_window_checkbox.dds")

local kStrokeWidth = 2
local kStrokeWidthHover = 3

GMSBFWCheckboxWidget:AddCompositeClassProperty("Label", "label", "Text")

local function OnPressed(self)
    if self:GetValue() then
        PlayMenuSound("AcceptChoice")
    else
        PlayMenuSound("CancelChoice")
    end
end

local function OnValueChanged(self, value)
    local goal = value and 1 or 0
    self.checkboxInside:AnimateProperty("Color", Color(1, 1, 1, goal), MenuAnimations.FadeFast)
end

local function OnFXStateChanged(self, state, prevState)
    if state == "disabled" then
        -- Not used for these widgets
    elseif state == "pressed" then
        self.checkboxBack:ClearPropertyAnimations("StrokeColor")
        self.checkboxBack:ClearPropertyAnimations("StrokeWidth")
        self.checkboxBack:SetStrokeColor((MenuStyle.kBasicStrokeColor + MenuStyle.kHighlight) * 0.5)
        self.checkboxBack:SetStrokeWidth(kStrokeWidth)
    elseif state == "hover" then
        if prevState == "pressed" then
            self.checkboxBack:ClearPropertyAnimations("StrokeColor")
            self.checkboxBack:ClearPropertyAnimations("StrokeWidth")
            self.checkboxBack:SetStrokeColor(MenuStyle.kHighlight)
            self.checkboxBack:SetStrokeWidth(kStrokeWidthHover)
        else
            PlayMenuSound("ButtonHover")
            DoColorFlashEffect(self.checkboxBack, "StrokeColor")
            self.checkboxBack:AnimateProperty("StrokeWidth", kStrokeWidthHover, MenuAnimations.FadeFast)
        end
    elseif state == "default" then
        self.checkboxBack:AnimateProperty("StrokeWidth", kStrokeWidth, MenuAnimations.FadeFast)
        self.checkboxBack:AnimateProperty("StrokeColor", MenuStyle.kBasicStrokeColor, MenuAnimations.FadeFast)
    end
end

function GMSBFWCheckboxWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    RequireType({"boolean", "nil"}, params.default, "params.default", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.label = CreateGUIObject("label", GUIText, self)
    self.label:AlignLeft()
    self.label:SetFont(kFont)
    self.label:SetColor(kLabelColor)
    
    self.checkboxBack = CreateGUIObject("checkboxBack", GUIMenuBasicBox, self)
    self.checkboxBack:AlignRight()
    self.checkboxBack:SetSize(kCheckboxBackgroundSize)
    
    self.checkboxInside = CreateGUIObject("checkboxInside", GUIObject, self.checkboxBack)
    self.checkboxInside:SetTexture(kCheckboxInsideImage)
    self.checkboxInside:SetSizeFromTexture()
    self.checkboxInside:AlignCenter()
    self.checkboxInside:SetColor(1, 1, 1, 0)
    
    self:HookEvent(self, "OnPressed", OnPressed)
    self:HookEvent(self, "OnValueChanged", OnValueChanged)
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    
    self:SetSize(kDefaultSize)
    
    if params.label then
        self:SetLabel(params.label)
    end
    
    if params.default ~= nil then
        self:SetValue(params.default)
    end
    
end
