-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/Options/Mods/GUIMenuManageModsDisplayBoxEntry.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIMenuCategoryDisplayBoxEntry that also has a button to take the user to the steam workshop.
--
--  Properties:
--      Label               Text to display for this entry.
--      IndexEven           Whether or not this is an even-numbered entry in the list (determines
--                          color).
--      Selected            Whether or not this entry is selected (determines color).
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/GUIMenuCategoryDisplayBoxEntry.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

---@class GUIMenuManageModsDisplayBoxEntry : GUIMenuCategoryDisplayBoxEntry
local baseClass = GUIMenuCategoryDisplayBoxEntry
class "GUIMenuManageModsDisplayBoxEntry" (baseClass)

local kSteamWorkshopTextureDim = PrecacheAsset("ui/newMenu/steam_workshop_dim.dds")
local kSteamWorkshopTextureLit = PrecacheAsset("ui/newMenu/steam_workshop_lit.dds")

local kLabelSpacing = 48
local kArrowWidth = 48
local kButtonScale = 1.5

local kGetModsURL = "http://steamcommunity.com/workshop/browse?appid=4920"

local function UpdateLabelSize(self)
    
    local labelSize = self.label:GetTextSize()
    local entryWidth = self:GetSize().x
    
    local spaceForLabel = entryWidth - kLabelSpacing*4 - kArrowWidth - self.steamWorkshopButton:GetSize().x * kButtonScale
    local labelWidth = math.min(spaceForLabel, labelSize.x)
    self.label:SetSize(labelWidth, labelSize.y)
    
end

local function OnWorkshopButtonPressed()
    PlayMenuSound("ButtonClick")
    Client.ShowWebpage(kGetModsURL)
end

local function UpdateWorkshopButtonEnabled(self)
    local overlayEnabled = Client.GetIsSteamOverlayEnabled()
    self.steamWorkshopButton:SetEnabled(overlayEnabled)
    self.steamWorkshopButton:SetTooltip(overlayEnabled and Locale.ResolveString("MENU_WORKSHOP_TOOLTIP") or Locale.ResolveString("MENU_WORKSHOP_DISABLED_TOOLTIP"))
end

function GUIMenuManageModsDisplayBoxEntry:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    local buttonClass = GUIMenuFlashGraphic
    buttonClass = GetCursorInteractableWrappedClass(buttonClass)
    buttonClass = GetTooltipWrappedClass(buttonClass)
    self.steamWorkshopButton = CreateGUIObject("steamWorkshopButton", buttonClass, self,
    {
        defaultTexture = kSteamWorkshopTextureDim,
        hoverTexture = kSteamWorkshopTextureLit,
        tooltip = Locale.ResolveString("MENU_WORKSHOP_TOOLTIP"),
        noAutoConnectToParent = true, -- button should react to the mouse separately from the rest.
    })
    self.steamWorkshopButton:AddInstanceProperty("Enabled", true)
    self.steamWorkshopButton:SetScale(kButtonScale, kButtonScale)
    self.steamWorkshopButton:AlignRight()
    self.steamWorkshopButton:SetX(-kArrowWidth - kLabelSpacing)
    self:HookEvent(self.steamWorkshopButton, "OnPressed", OnWorkshopButtonPressed)
    
    -- Client.GetIsSteamOverlayEnabled isn't always loaded yet if we were to call it here (returns
    -- true regardless in this case).  Add a timed callback in oh... say... 5 seconds to update it
    -- again.
    UpdateWorkshopButtonEnabled(self)
    self:AddTimedCallback(UpdateWorkshopButtonEnabled, 5)
    
    -- Need to modify the logic we use to set the label size to now include the steam workshop
    -- in its calculations.  Un-hook the previous one, then re-hook our new function.
    self:UnHookEvent(self.label, "OnTextSizeChanged", GUIMenuCategoryDisplayBoxEntry._UpdateLabelSizeCallbackFunc)
    self:UnHookEvent(self, "OnSizeChanged", GUIMenuCategoryDisplayBoxEntry._UpdateLabelSizeCallbackFunc)
    
    self:HookEvent(self.label, "OnTextSizeChanged", UpdateLabelSize)
    self:HookEvent(self, "OnSizeChanged", UpdateLabelSize)
    UpdateLabelSize(self)
    
end
