-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/Hud/HelpScreen/Binding.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Displays an appropriate graphic for a key binding.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Hud/Marine/GUIMarineHUDStyle.lua")
Script.Load("lua/Hud/Alien/GUIAlienHUDStyle.lua")

class "HelpScreenBinding" (GUIScript)

local kDefaultScaleFactor = 0.3

local kIconLayer = 5
local kTextLayer = 6

local kFontHeight = 28.0
local kFontActualHeight = 28.0
local kFont = Fonts.kAgencyFB_Large
local kUnboundColor = Color( 1, 58/255, 58/255, 1)

local kKeyIconScaleFactor = 0.2442 / kDefaultScaleFactor
local kKeyIconSmallMaxWidth = 43 -- maximum width of the text that can be displayed within this icon (@ 1080)
local kKeyIconMedMaxWidth = 108
local kKeyTextOffset = Vector(0, -8, 0) -- shift text by this amount so it fits nicely into the graphic.

local kDefaultShader = "shaders/GUIBasicSaturation.surface_shader"

local function GetTextItem(self)
    
    if not self.text then
        self.text = GUI.CreateItem()
        self.text:SetShader(kDefaultShader)
        self.text:SetOptionFlag(GUIItem.ManageRender)
        self.text:SetFontName(kFont)
        local s = (kFontHeight / kFontActualHeight) * self.scaling
        self.text:SetScale(Vector(s,s,0))
        self.text:SetTextAlignmentX(GUIItem.Align_Center)
        self.text:SetTextAlignmentY(GUIItem.Align_Center)
        self.text:SetLayer(kTextLayer)
        self.text:SetIsVisible(self.visible)
    end
    
    return self.text
    
end

local function GetIconItem(self)
    
    if not self.icon then
        self.icon = GUI.CreateItem()
        local s = kDefaultScaleFactor * self.scaling
        self.icon:SetScale(Vector(s,s,0))
        self.icon:SetLayer(kIconLayer)
        self.icon:SetIsVisible(self.visible)
    end
    
    return self.icon
    
end

local function DestroyTextItem(self)
    if self.text then
        GUI.DestroyItem(self.text)
        self.text = nil
    end
end

local function DestroyIconItem(self)
    if self.icon then
        GUI.DestroyItem(self.icon)
        self.icon = nil
    end
end

local kSpaceAdditions = {'Num','Pad','Left','Right','Page','App','Mouse','Button','Wheel','Print', 'Joystick', 'Rotation', 'Pov', 'Slider'}
local function GetFriendlyName(name)
    
    local newName = name
    for i=1, #kSpaceAdditions do
        newName = string.gsub(newName, kSpaceAdditions[i], kSpaceAdditions[i]..' ')
    end
    
    return newName
    
end

local kKnownIcons = 
{
    ["MouseButton0"]    = { iconName = "mouse_regular", parameter = 1 },
    ["MouseButton1"]    = { iconName = "mouse_regular", parameter = 2 },
    ["MouseButton2"]    = { iconName = "mouse_regular", parameter = 3 },
    ["MouseButton3"]    = { iconName = "mouse_side",    parameter = 2 },
    ["MouseButton4"]    = { iconName = "mouse_side",    parameter = 1 },
    ["MouseWheelUp"]    = { iconName = "mouse_wheel",   parameter = 1 },
    ["MouseWheelDown"]  = { iconName = "mouse_wheel",   parameter = 2 },
    ["Space"]           = { iconName = "keyboard",      parameter = 3 },
}

local kIconSetups = 
{
    mouse_regular =
    {
        [1] = -- left mouse button
        {
            texture = "ui/mouse_buttons.dds",
            shader = "shaders/GUIMouseButtonsIcon.surface_shader",
            shaderParams = 
            {
                [1] = { name = "rIntensity", value = 1.0, },
                [2] = { name = "gIntensity", value = 0.0, },
                [3] = { name = "bIntensity", value = 0.0, },
            },
        },
        
        [2] = -- right mouse button
        {
            texture = "ui/mouse_buttons.dds",
            shader = "shaders/GUIMouseButtonsIcon.surface_shader",
            shaderParams = 
            {
                [1] = { name = "rIntensity", value = 0.0, },
                [2] = { name = "gIntensity", value = 1.0, },
                [3] = { name = "bIntensity", value = 0.0, },
            },
        },
        
        [3] = -- middle mouse button
        {
            texture = "ui/mouse_buttons.dds",
            shader = "shaders/GUIMouseButtonsIcon.surface_shader",
            shaderParams = 
            {
                [1] = { name = "rIntensity", value = 0.0, },
                [2] = { name = "gIntensity", value = 0.0, },
                [3] = { name = "bIntensity", value = 1.0, },
            },
        },
    },
    
    mouse_wheel = 
    {
        [1] = -- wheel up
        {
            texture = "ui/mouse_wheel.dds",
            shader = "shaders/GUIMouseWheelIcon.surface_shader",
            shaderParams = 
            {
                [1] = { name = "rIntensity", value = 1.0, },
                [2] = { name = "gIntensity", value = 0.0, },
            },
        },
        
        [2] = -- wheel down
        {
            texture = "ui/mouse_wheel.dds",
            shader = "shaders/GUIMouseWheelIcon.surface_shader",
            shaderParams = 
            {
                [1] = { name = "rIntensity", value = 0.0, },
                [2] = { name = "gIntensity", value = 1.0, },
            },
        },
    },
    
    mouse_side = 
    {
        [1] = -- front-side button
        {
            texture = "ui/mouse_side_buttons.dds",
            shader = "shaders/GUIMouseWheelIcon.surface_shader",
            shaderParams = 
            {
                [1] = { name = "rIntensity", value = 1.0, },
                [2] = { name = "gIntensity", value = 0.0, },
            },
        },
        
        [2] = -- back-side button
        {
            texture = "ui/mouse_side_buttons.dds",
            shader = "shaders/GUIMouseWheelIcon.surface_shader",
            shaderParams = 
            {
                [1] = { name = "rIntensity", value = 0.0, },
                [2] = { name = "gIntensity", value = 1.0, },
            },
        },
    },
    
    keyboard =
    {
        [1] =
        {
            texture = "ui/keyboard_key_small.dds",
            shader = "shaders/GUIGreyToAlpha.surface_shader",
        },
        
        [2] =
        {
            texture = "ui/keyboard_key_med.dds",
            shader = "shaders/GUIGreyToAlpha.surface_shader",
        },
        
        [3] =
        {
            texture = "ui/keyboard_key_large.dds",
            shader = "shaders/GUIGreyToAlpha.surface_shader",
        },
    }
}
-- precache assets
for key, value in pairs(kIconSetups) do
    for i=1, #value do
        if value[i].texture then
            PrecacheAsset(value[i].texture)
        end
    end
end
local function GetKeyIcon(name)
    
    local iconConfigTable = kKnownIcons[name]
    if iconConfigTable then
        return iconConfigTable.iconName, iconConfigTable.parameter
    end
    
    -- use a key icon, and don't specify a size, let the text dimensions determine it.
    return "keyboard", nil
    
end

local function GetAppropriateKeyboardIconSize(self, item, str)
    
    local textWidth = item:GetTextWidth(str)
    local textWidthAt1080 = textWidth / self.scaling
    
    local keyParam = 1 -- smallest size.
    if textWidthAt1080 > kKeyIconSmallMaxWidth then
        if textWidthAt1080 > kKeyIconMedMaxWidth then
            keyParam = 3 -- largest size.
        else
            keyParam = 2 -- medium size.
        end
    end
    
    return keyParam
    
end

local function UpdateColor(self)
    
    if not self.color then
        return
    end
    
    if self.icon then
        self.icon:SetColor(self.color)
    end
    
    if self.text then
        self.text:SetColor(self.color)
    end
    
end

local function UpdatePosition(self)
    
    if self.icon then
        local size = self.icon:GetSize()
        local scaledSize = self.icon:GetScaledSize()
        local pos = Vector(self.position)
        local offset = Vector(scaledSize.x * -self.anchorPoint.x * 0.5, scaledSize.y * -self.anchorPoint.y * 0.5, 0)
        pos.x = pos.x - (size.x * 0.5)
        pos.y = pos.y - (size.y * 0.5)
        self.icon:SetPosition(pos + offset)
        
        if self.text then
            self.text:SetPosition(self.position + (kKeyTextOffset * self.scaling) + offset)
        end
    else
        if self.text then
            self.text:SetPosition(self.position + (kKeyTextOffset * self.scaling))
        end
    end
    
end

-- force binding to update.
local function UpdateBinding(self)
    
    -- Handle case where key is unbound first.
    if self.controlName == "" or self.controlName == "None" then
        local text = GetTextItem(self)
        text:SetColor(kUnboundColor)
        text:SetText(Locale.ResolveString("UNBOUND"))
        text:SetIsVisible(self.visible)
        DestroyIconItem(self) -- no icon for this state.
        return
    end
    
    local friendlyName = GetFriendlyName(self.controlName)
    local iconType, iconParam = GetKeyIcon(self.controlName)
    local iconItem = GetIconItem(self)
    if iconType == "keyboard" then
        
        local textItem = GetTextItem(self)
        textItem:SetText(friendlyName)
        textItem:SetIsVisible(self.visible)
        -- determine which variant (width) of key graphic we should use based on the width of the text it will contain.
        iconParam = iconParam or GetAppropriateKeyboardIconSize(self, textItem, friendlyName)
        
        local s = kDefaultScaleFactor * self.scaling * kKeyIconScaleFactor
        iconItem:SetScale(Vector(s,s,0))
        
    else
        local s = kDefaultScaleFactor * self.scaling
        iconItem:SetScale(Vector(s,s,0))
        DestroyTextItem(self) -- no use for text when mouse is displayed.
    end
    
    -- setup shaders w/ parameters, or default if not specified
    local iconSetup = kIconSetups[iconType][iconParam]
    assert(iconSetup)
    assert(iconSetup.texture)
    iconItem:SetTexture(iconSetup.texture)
    iconItem:SetSize(Vector(iconItem:GetTextureWidth(), iconItem:GetTextureHeight(),0))
    if iconSetup.shader then
        iconItem:SetShader(iconSetup.shader)
        if iconSetup.shaderParams then
            for i=1, #iconSetup.shaderParams do
                iconItem:SetFloatParameter( iconSetup.shaderParams[i].name, iconSetup.shaderParams[i].value )
            end
        end
    else
        iconItem:SetShader(kDefaultShader)
    end
    
    iconItem:SetIsVisible(self.visible)
    
    UpdatePosition(self)
    self:UpdateSaturation() -- ensure new icon/text is given the proper saturation value.
    
end

function HelpScreenBinding:Initialize()
    
    self.scaling = self.scaling or 1.0
    self.updateInterval = 0.25 -- 4fps
    self.controlName = ""
    self.action = self.action or nil
    self.text = nil
    self.icon = nil
    self.anchorPoint = self.anchorPoint or Vector(0, 0, 0) -- default to center.
    self.position = self.position or Vector(0,0,0)
    self.saturation = self.saturation or 1.0
    self.color = self.color or Color(1,1,1,1)
    self.desaturatedColor = self.desaturatedColor or Color(1,1,1,1)
    self.visible = (self.visible == true)
    
end

function HelpScreenBinding:Uninitialize()
    
    DestroyIconItem(self)
    DestroyTextItem(self)
    self.text = nil
    self.icon = nil
    
end

function HelpScreenBinding:OnResolutionChanged()
    
    self:Uninitialize()
    self:Initialize()
    UpdateBinding(self)
    UpdateColor(self)
    
end

function HelpScreenBinding:Update(deltaTime)
    
    local controlName = BindingsUI_GetInputValue(self.action)
    
    if self.controlName ~= controlName then
        self.controlName = controlName
        UpdateBinding(self)
        UpdateColor(self)
    end
    
end

local function Desaturate(color)
    
    local val = color.r * 0.21 + color.g * 0.72 * color.b * 0.07
    val = val ^ (1.0 / 2.2) -- gamma fix
    return Color(val, val, val, color.a)
    
end

function HelpScreenBinding:SetColor(color)
    
    self.color = color
    self.desaturatedColor = Desaturate(self.color)
    UpdateColor(self)
    
end

-- set the action we want to display the keybind for.
function HelpScreenBinding:SetAction(action)
    
    if action ~= self.action then
        self.action = action
        self:Update(0)
    end
    
end

function HelpScreenBinding:SetScalingFactor(scale)
    
    self.scaling = scale
    UpdateBinding(self) -- This can influence which key icon is chosen.
    
end

-- measured in real pixels, not the auto-sized 1080p pixel measurements.
function HelpScreenBinding:SetPosition(position)
    
    self.position = position
    UpdatePosition(self)
    
end

-- multiplier of each dimension to subtract from the upper-left corner's position (eg so 0.5, 0.5 will make this
-- graphic center on its position, while a value of 0, 0 will make set it's upper left corner to the position).
function HelpScreenBinding:SetAnchorPoint(vect)
    
    self.anchorPoint = vect
    
end

function HelpScreenBinding:SetIsVisible(state)
    
    self.visible = state
    if self.text then
        self.text:SetIsVisible(state)
    end
    if self.icon then
        self.icon:SetIsVisible(state)
    end
    
end

function HelpScreenBinding:GetScaledSize()
    
    if self.icon then
        return self.icon:GetScaledSize()
    end
    
    if self.text then
        return Vector(self.text:GetTextWidth(self.text:GetText()) * self.text:GetScale().x, self.text:GetTextHeight(self.text:GetText()) * self.text:GetScale().y, 0)
    end
    
    return Vector(0,0,0)
    
end

local function GetSaturatedColor(color, grey, sat)
    
    local r = color.r * sat + grey.r * (1.0 - sat)
    local g = color.g * sat + grey.g * (1.0 - sat)
    local b = color.b * sat + grey.b * (1.0 - sat)
    
    return Color(r,g,b,color.a)
    
end

function HelpScreenBinding:UpdateSaturation()
    
    if self.icon then
        self.icon:SetColor(GetSaturatedColor(self.color, self.desaturatedColor, self.saturation))
    end
    
    if self.text then
        self.text:SetFloatParameter("saturation", self.saturation)
    end
    
end

function HelpScreenBinding:SetSaturation(sat)
    
    self.saturation = sat
    self:UpdateSaturation()
    
end

