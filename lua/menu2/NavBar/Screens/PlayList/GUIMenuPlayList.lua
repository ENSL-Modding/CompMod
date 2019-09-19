-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/PlayList/GUIMenuPlayList.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Play menu options in a button list.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/GUIMenuNavBarScreen.lua")

Script.Load("lua/GUI/layouts/GUIListLayout.lua")
Script.Load("lua/menu2/NavBar/Screens/PlayList/GUIMenuPlayListItem.lua")
Script.Load("lua/menu2/NavBar/Screens/PlayList/GUIMenuQuickPlayListItem.lua")

Script.Load("lua/menu2/GUIMenuDropShadow.lua")
Script.Load("lua/menu2/GUIMenuCoolBox2.lua")

Script.Load("lua/menu2/QuickPlay/GUIMenuQuickPlayPopup.lua")

---@class GUIMenuPlayList : GUIMenuNavBarScreen
class "GUIMenuPlayList" (GUIMenuNavBarScreen)

GUIMenuPlayList.kSpacing = 24
GUIMenuPlayList.kPadding = Vector(0, 48, 0)

local kWiresTexture = PrecacheAsset("ui/newMenu/playListWires.dds")
local kWire1BoundsX = 76
local kWire2BoundsX = 122
local kWireBoundsY = 556
local kWire1PosX = 40

local kCropOffsetUL = Vector(-8, -8, 0)
local kCropOffsetLR = Vector(40, 40, 0)

function GUIMenuPlayList:GetOptionDefsTable()
    return
    {
        {
            name = "quickPlay",
            class = GUIMenuQuickPlayListItem,
            params =
            {
                label = Locale.ResolveString("PLAY_MENU_QUICK_PLAY"),
            },
            callback = GUIMenuPlayList.OnQuickJoinClicked,
        },
        
        {
            name = "serverBrowser",
            class = GUIMenuPlayListItem,
            params =
            {
                label = Locale.ResolveString("MENU_SERVER_BROWSER"),
            },
            callback = GUIMenuPlayList.OnServerBrowserClicked,
        },
        
        {
            name = "training",
            class = GUIMenuPlayListItem,
            params =
            {
                label = Locale.ResolveString("MENU_TRAINING"),
            },
            callback = GUIMenuPlayList.OnTrainingClicked,
        },
        
        {
            name = "challenges",
            class = GUIMenuPlayListItem,
            params =
            {
                label = Locale.ResolveString("MENU_CHALLENGES"),
            },
            callback = GUIMenuPlayList.OnChallengesClicked,
        },
        
        {
            name = "startServer",
            class = GUIMenuPlayListItem,
            params =
            {
                label = Locale.ResolveString("MENU_START_LISTEN_SERVER"),
            },
            callback = GUIMenuPlayList.OnStartListenServerClicked,
        },
    }
end

local function UpdateSize(self, newSize)
    
    local paddedSize = newSize + self.kPadding * 2
    
    self.back:SetSize(paddedSize)
    self.backShadow:SetSize(paddedSize)
    self:SetSize(paddedSize)
    
    -- Update crop.
    -- Add some padding around crop zone to prevent it from cropping away the effects like
    -- outer stroke, and drop shadow.
    self:SetCropMin(kCropOffsetUL.x / paddedSize.x, kCropOffsetUL.y / paddedSize.y)
    self:SetCropMax((kCropOffsetLR.x + paddedSize.x) / paddedSize.x, (kCropOffsetLR.y + paddedSize.y) / paddedSize.y)
    
end

function GUIMenuPlayList:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PROFILE("GUIMenuPlayList:Initialize")
    
    PushParamChange(params, "screenName", "Play")
    GUIMenuNavBarScreen.Initialize(self, params, errorDepth)
    PopParamChange(params, "screenName")
    
    self:ListenForCursorInteractions() -- prevent click-through
    
    self.back = CreateGUIObject("back", GUIMenuCoolBox2, self)
    self.back:SetLayer(-1)
    
    self.backWire1 = self.back:CreateGUIItem()
    self.backWire1:SetTexture(kWiresTexture)
    self.backWire1:SetTexturePixelCoordinates(0, 0, kWire1BoundsX, kWireBoundsY)
    self.backWire1:SetSize(kWire1BoundsX, kWireBoundsY)
    self.backWire1:SetPosition(kWire1PosX, 0)
    self.backWire1:AlignBottomLeft()
    
    self.backWire2 = self.back:CreateGUIItem()
    self.backWire2:SetTexture(kWiresTexture)
    self.backWire2:SetTexturePixelCoordinates(kWire1BoundsX, 0, kWire2BoundsX, kWireBoundsY)
    self.backWire2:SetSize(kWire2BoundsX - kWire1BoundsX, kWireBoundsY)
    self.backWire2:AlignBottomRight()
    
    self.backShadow = CreateGUIObject("backShadow", GUIMenuDropShadow, self)
    self.backShadow:SetLayer(-2)
    
    self.listLayout = CreateGUIObject("listLayout", GUIListLayout, self, {orientation = "vertical"})
    self.listLayout:SetSpacing(self.kSpacing)
    self.listLayout:SetPosition(self.kPadding)
    
    self:HookEvent(self.listLayout, "OnSizeChanged", UpdateSize)
    
    self.options = {}
    local optionDefs = self:GetOptionDefsTable()
    for i=1, #optionDefs do
        local optionDef = optionDefs[i]
        local newOption = CreateGUIObjectFromConfig(optionDef, self.listLayout)
        self:HookEvent(newOption, "OnPressed", optionDef.callback)
    end
    
end

function GUIMenuPlayList:UpdateBackgroundSize(input, output)
    output[1].x = input[1].x + self.kPadding.x * 2
    output[1].y = input[1].y + self.kPadding.y * 2
    return output[1]
end

function GUIMenuPlayList:OnQuickJoinClicked()
    DoQuickJoin()
end

function GUIMenuPlayList:OnServerBrowserClicked()
    GetScreenManager():DisplayScreen("ServerBrowser")
end

function GUIMenuPlayList:OnChallengesClicked()
    GetScreenManager():DisplayScreen("Challenges")
end

function GUIMenuPlayList:OnTrainingClicked()
    GetScreenManager():DisplayScreen("Training")
end

function GUIMenuPlayList:OnStartListenServerClicked()
    GetScreenManager():DisplayScreen("StartServer")
end

