-- ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenu_Customize.lua
--
--    Created by:   Brian Arneson(samusdroid@gmail.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com ====================
Script.Load("lua/menu/MenuPoses.lua")
Script.Load("lua/menu/GUIMainMenu_BadgesSelection.lua")

local Resolve = Locale.ResolveString

local menuRefresed = false
local function InitCustomizationOptions(customizeElements)
    
    local function BoolToIndex(value)
        if value then
            return 2
        end
        return 1
    end
    
    local options = GetAndSetVariantOptions()
    
    customizeElements.SexType:SetValue(options.sexType)
    customizeElements.MarineVariantName:SetValue(GetVariantName(kMarineVariantData, options.marineVariant))
    customizeElements.ShoulderPad:SetValue(kShoulderPadNames[options.shoulderPadIndex])
    customizeElements.SkulkVariantName:SetValue(GetVariantName(kSkulkVariantData, options.skulkVariant))
    customizeElements.GorgeVariantName:SetValue(GetVariantName(kGorgeVariantData, options.gorgeVariant))
    customizeElements.LerkVariantName:SetValue(GetVariantName(kLerkVariantData, options.lerkVariant))
    customizeElements.FadeVariantName:SetValue(GetVariantName(kFadeVariantData, options.fadeVariant))
    customizeElements.OnosVariantName:SetValue(GetVariantName(kOnosVariantData, options.onosVariant))
    customizeElements.ExoVariantName:SetValue(GetVariantName(kExoVariantData, options.exoVariant))
    customizeElements.RifleVariantName:SetValue(GetVariantName(kRifleVariantData, options.rifleVariant))
    customizeElements.PistolVariantName:SetValue(GetVariantName(kPistolVariantData, options.pistolVariant))
    customizeElements.AxeVariantName:SetValue(GetVariantName(kAxeVariantData, options.axeVariant))
    customizeElements.ShotgunVariantName:SetValue(GetVariantName(kShotgunVariantData, options.shotgunVariant))
    customizeElements.FlamethrowerVariantName:SetValue(GetVariantName(kFlamethrowerVariantData, options.flamethrowerVariant))
    customizeElements.GrenadeLauncherVariantName:SetValue(GetVariantName(kGrenadeLauncherVariantData, options.grenadeLauncherVariant))
    customizeElements.WelderVariantName:SetValue(GetVariantName(kWelderVariantData, options.welderVariant))
    customizeElements.HMGVariantName:SetValue(GetVariantName(kHMGVariantData, options.hmgVariant))
    customizeElements.MarineStructureVariantName:SetValue(GetVariantName(kMarineStructureVariantsData, options.marineStructuresVariant))
    customizeElements.AlienStructureVariantName:SetValue(GetVariantName(kAlienStructureVariantsData, options.alienStructuresVariant))
    customizeElements.AlienTunnelVariantName:SetValue(GetVariantName(kAlienTunnelVariantsData, options.alienTunnelsVariant))
    
end

GUIMainMenu.CreateCustomizeForm = function(mainMenu, content, options, customizeElements)

    local form = CreateMenuElement(content, "Form", true)
    
    -- Things are getting REALLY tight on the both side...
    local rowHeight = 90
    local numColumns = 2
    
    local y = 0
    local columnWidth = 250
    for i = 1, #options do
 
        local option = options[i]
        local input
        local label
        local defaultInputClass = "customize_input"
        
        local column = (i-1) % numColumns
        local xOffset = 12 + column * columnWidth - (250 * (numColumns * 0.5))
        local labelXOffset = 136 + (column * 250)

        if column == 0 then
            y = y + rowHeight
        end
        
        if option.type == "select" then
            input = form:CreateFormElement(Form.kElementType.DropDown, option.name, option.value)
            if option.values then
                input:SetOptions(option.values)
            end
        end
        
        if option.callback then
            input:AddSetValueCallback(option.callback)
        end
        local inputClass = defaultInputClass
        if option.inputClass then
            inputClass = option.inputClass
        end
        
        for index, child in ipairs(input:GetChildren()) do
        child:AddEventCallbacks({ 
            OnMouseIn = function(self)

            local currentModel = Client.GetOptionString("currentModel", "")
            Client.SetOptionString("currentModel", input:GetFormElementName())
            
            local modelType

                if input:GetFormElementName() ~= currentModel or menuRefresed == true then
                    --Default to allowing rotation
                    mainMenu.sliderAngleBar:SetIsVisible(true)
                    mainMenu.sliderAngleBarLabel:SetIsVisible(true)

                    if input:GetFormElementName() == "MarineVariantName" or input:GetFormElementName() == "SexType" then
                        modelType = "marine"
                    elseif input:GetFormElementName() == "ShoulderPad" then
                        mainMenu.sliderAngleBar:SetIsVisible(false) --Disable for viewing shoulder patches
                        mainMenu.sliderAngleBarLabel:SetIsVisible(false)
                        modelType = "decal"
                    elseif input:GetFormElementName() == "SkulkVariantName" then
                        modelType = "skulk"
                    elseif input:GetFormElementName() == "GorgeVariantName" then
                        modelType = "gorge"
                    elseif input:GetFormElementName() == "LerkVariantName" then
                        modelType = "lerk"
                    elseif input:GetFormElementName() == "FadeVariantName" then
                        modelType = "fade"
                    elseif input:GetFormElementName() == "OnosVariantName" then
                        modelType = "onos"
                    elseif input:GetFormElementName() == "ExoVariantName" then
                        modelType = "exo"
                    elseif input:GetFormElementName() == "RifleVariantName" then
                        modelType = "rifle"
                    elseif input:GetFormElementName() == "PistolVariantName" then
                        modelType = "pistol"
                    elseif input:GetFormElementName() == "AxeVariantName" then
                        modelType = "axe"
                    elseif input:GetFormElementName() == "ShotgunVariantName" then
                        modelType = "shotgun"
                    elseif input:GetFormElementName() == "FlamethrowerVariantName" then
                        modelType = "flamethrower"
                    elseif input:GetFormElementName() == "GrenadeLauncherVariantName" then
                        modelType = "grenadeLauncher"
                    elseif input:GetFormElementName() == "WelderVariantName" then
                        modelType = "welder"
                    elseif input:GetFormElementName() == "HMGVariantName" then
                        modelType = "hmg"
                    elseif input:GetFormElementName() == "MarineStructureVariantName" then
                        mainMenu.sliderAngleBar:SetIsVisible(false)
                        mainMenu.sliderAngleBarLabel:SetIsVisible(false)
                        modelType = "command_station"
                    elseif input:GetFormElementName() == "AlienStructureVariantName" then
                        mainMenu.sliderAngleBar:SetIsVisible(false)
                        mainMenu.sliderAngleBarLabel:SetIsVisible(false)
                        modelType = "hive"
                    elseif input:GetFormElementName() == "AlienTunnelVariantName" then
                        mainMenu.sliderAngleBar:SetIsVisible(false)
                        mainMenu.sliderAngleBarLabel:SetIsVisible(false)
                        modelType = "tunnel"
                    else
                        modelType = ""
                    end
                        
                    if Client.GetOptionString("lastShownModel", "marine") ~= modelType then
                        MenuPoses_SetPose("idle", modelType, true)
                        MenuPoses_Function():SetCoordsOffset(modelType)
                    end

                    Client.SetOptionString("lastShownModel", modelType)
                    Client.SetOptionString("lastModel", input:GetFormElementName())
                    menuRefresed = false
                end
                
            end,
            })
        end
        
        input:SetCSSClass(inputClass)
        input:SetTopOffset(y)
        input:SetLeftOffset(xOffset)
        
        local label = CreateMenuElement(form, "Font", false)
        label:SetCSSClass("customize_label_" .. option.side)
        label:SetText(option.label)
        label:SetTopOffset(y - 35)
        label:SetLeftOffset(labelXOffset)
        label:SetIgnoreEvents(false)
        
        customizeElements[option.name] = input
    end
    
    form:SetCSSClass("options")

    return form

end

local function OnSexChanged(formElement)
    local sexType = formElement:GetValue()
    Client.SetOptionString("sexType", firstToUpper(sexType))
    MenuPoses_SetPose("idle", "marine", true)
    MenuPoses_Function():SetCoordsOffset("marine")
    SendPlayerVariantUpdate()
end

local function OnMarineChanged(formElement)
    local marineVariantName = formElement:GetValue()
    Client.SetOptionInteger("marineVariant", FindVariant(kMarineVariantData, marineVariantName))
    MenuPoses_SetPose("idle", "marine", true)
    MenuPoses_Function():SetCoordsOffset("marine")
    SendPlayerVariantUpdate()
end

local function OnDecalChanged(formElement)
    local shoulderPadName = formElement:GetValue()
    Client.SetOptionInteger("shoulderPad", GetShoulderPadIndexByName(shoulderPadName))
    MenuPoses_SetPose("idle", "decal", true)
    MenuPoses_Function():SetCoordsOffset("decal")
    SendPlayerVariantUpdate()
end

local function OnExoChanged(formElement)
    local exoVariantName = formElement:GetValue()
    Client.SetOptionInteger("exoVariant", FindVariant(kExoVariantData, exoVariantName))
    MenuPoses_SetPose("idle", "exo", true)
    MenuPoses_Function():SetCoordsOffset("exo")
    SendPlayerVariantUpdate()
end

local function OnRifleChanged(formElement)
    local rifleVariantName = formElement:GetValue()
    Client.SetOptionInteger("rifleVariant", FindVariant(kRifleVariantData, rifleVariantName))
    Client.SetOptionString("lastShownModel", "rifle")
    MenuPoses_SetPose("idle", "rifle", true)
    MenuPoses_Function():SetCoordsOffset("rifle")
    SendPlayerVariantUpdate()
end

local function OnPistolChanged(formElement)
    local pistolVariantName = formElement:GetValue()
    Client.SetOptionInteger("pistolVariant", FindVariant(kPistolVariantData, pistolVariantName))
    Client.SetOptionString("lastShownModel", "pistol")
    MenuPoses_SetPose("idle", "pistol", true) -- TODO
    MenuPoses_Function():SetCoordsOffset("pistol") -- TODO
    SendPlayerVariantUpdate()
end

local function OnAxeChanged(formElement)
    local axeVariantName = formElement:GetValue()
    Client.SetOptionInteger("axeVariant", FindVariant(kAxeVariantData, axeVariantName))
    Client.SetOptionString("lastShownModel", "axe")
    MenuPoses_SetPose("idle", "axe", true) -- TODO
    MenuPoses_Function():SetCoordsOffset("axe") -- TODO
    SendPlayerVariantUpdate()
end

local function OnShotgunChanged(formElement)
    local shotgunVariantName = formElement:GetValue()
    Client.SetOptionInteger("shotgunVariant", FindVariant(kShotgunVariantData, shotgunVariantName))
    Client.SetOptionString("lastShownModel", "shotgun")
    MenuPoses_SetPose("idle", "shotgun", true)
    MenuPoses_Function():SetCoordsOffset("shotgun")
    SendPlayerVariantUpdate()
end

local function OnFlamethrowerChanged(formElement)
    local flamethrowerVariantName = formElement:GetValue()
    Client.SetOptionInteger("flamethrowerVariant", FindVariant(kFlamethrowerVariantData, flamethrowerVariantName))
    Client.SetOptionString("lastShownModel", "flamethrower")
    MenuPoses_SetPose("idle", "flamethrower", true)
    MenuPoses_Function():SetCoordsOffset("flamethrower")
    SendPlayerVariantUpdate()
end

local function OnGrenadeLauncherChanged(formElement)
    local grenadeLauncherVariantName = formElement:GetValue()
    Client.SetOptionInteger("grenadeLauncherVariant", FindVariant(kGrenadeLauncherVariantData, grenadeLauncherVariantName))
    Client.SetOptionString("lastShownModel", "grenadeLauncher")
    MenuPoses_SetPose("idle", "grenadeLauncher", true)
    MenuPoses_Function():SetCoordsOffset("grenadeLauncher")
    SendPlayerVariantUpdate()
end

local function OnWelderChanged(formElement)
    local welderVariantName = formElement:GetValue()
    Client.SetOptionInteger("welderVariant", FindVariant(kWelderVariantData, welderVariantName))
    Client.SetOptionString("lastShownModel", "welder")
    MenuPoses_SetPose("idle", "welder", true)
    MenuPoses_Function():SetCoordsOffset("welder")
    SendPlayerVariantUpdate()
end

local function OnHMGChanged(formElement)
    local hmgVariantName = formElement:GetValue()
    Client.SetOptionInteger("hmgVariant", FindVariant(kHMGVariantData, hmgVariantName))
    Client.SetOptionString("lastShownModel", "hmg")
    MenuPoses_SetPose("idle", "hmg", true)
    MenuPoses_Function():SetCoordsOffset("hmg")
    SendPlayerVariantUpdate()
end

local function OnSkulkChanged(formElement)
    local skulkVariantName = formElement:GetValue()
    Client.SetOptionInteger("skulkVariant", FindVariant(kSkulkVariantData, skulkVariantName))
    Client.SetOptionString("lastShownModel", "skulk")
    MenuPoses_SetPose("idle", "skulk", true)
    SendPlayerVariantUpdate()
end

local function OnGorgeChanged(formElement)
    local gorgeVariantName = formElement:GetValue()
    Client.SetOptionInteger("gorgeVariant", FindVariant(kGorgeVariantData, gorgeVariantName))
    Client.SetOptionString("lastShownModel", "gorge")
    MenuPoses_SetPose("idle", "gorge", true)
    SendPlayerVariantUpdate()
end

local function OnLerkChanged(formElement)
    local lerkVariantName = formElement:GetValue()
    Client.SetOptionInteger("lerkVariant", FindVariant(kLerkVariantData, lerkVariantName))
    Client.SetOptionString("lastShownModel", "lerk")
    MenuPoses_SetPose("idle", "lerk", true)
    SendPlayerVariantUpdate()
end

local function OnFadeChanged(formElement)
    local fadeVariantName = formElement:GetValue()
    Client.SetOptionInteger("fadeVariant", FindVariant(kFadeVariantData, fadeVariantName))
    Client.SetOptionString("lastShownModel", "fade")
    MenuPoses_SetPose("idle", "fade", true)
    SendPlayerVariantUpdate()
end

local function OnOnosChanged(formElement)
    local onosVariantName = formElement:GetValue()
    Client.SetOptionInteger("onosVariant", FindVariant(kOnosVariantData, onosVariantName))
    Client.SetOptionString("lastShownModel", "onos")
    MenuPoses_SetPose("idle", "onos", true)
    MenuPoses_Function():SetCoordsOffset("onos")
    SendPlayerVariantUpdate()
end

local function OnMarineStructureChanged(formElement)
    local marineStructureVariantName = formElement:GetValue()
    Client.SetOptionInteger("marineStructuresVariant", FindVariant(kMarineStructureVariantsData, marineStructureVariantName))
    Client.SetOptionString("lastShownModel", "command_station")
    MenuPoses_SetPose("idle", "command_station", true)
    MenuPoses_Function():SetCoordsOffset("command_station")
    SendPlayerVariantUpdate()
end

local function OnAlienStructureChanged(formElement)
    local alienStructureVariantName = formElement:GetValue()
    Client.SetOptionInteger("alienStructuresVariant", FindVariant(kAlienStructureVariantsData, alienStructureVariantName))
    Client.SetOptionString("lastShownModel", "hive")
    MenuPoses_SetPose("idle_active", "hive", true)
    MenuPoses_Function():SetCoordsOffset("hive")
    SendPlayerVariantUpdate()
end

local function OnAlienTunnelChanged(formElement)
    local alienTunnelVariantName = formElement:GetValue()
    Client.SetOptionInteger("alienTunnelsVariant", FindVariant(kAlienTunnelVariantsData, alienTunnelVariantName))
    Client.SetOptionString("lastShownModel", "tunnel")
    MenuPoses_SetPose("idle_open", "tunnel", true)
    MenuPoses_Function():SetCoordsOffset("tunnel")
    SendPlayerVariantUpdate()
end

function GUIMainMenu:CreateCustomizeLoadingWindow( onShowCallback )
    if not self.customizeLoadingWindow then
        self.customizeLoadingWindow = self:CreateWindow()
        self.customizeLoadingWindow:SetWindowName("LOADING")
        self.customizeLoadingWindow:SetInitialVisible(false)
        self.customizeLoadingWindow:SetIsVisible(false)
        self.customizeLoadingWindow:DisableResizeTile()
        self.customizeLoadingWindow:DisableSlideBar()
        self.customizeLoadingWindow:DisableContentBox()
        self.customizeLoadingWindow:SetCSSClass("playnow_window")
        self.customizeLoadingWindow:DisableCloseButton()

        self.customizeLoadingWindow.showCallbacks = { onShowCallback }

        local function Cancel()
            self.customizeLoadingWindow:SetIsVisible(false)
            self:ShowMenu()
        end

        self.customizeLoadingWindow.escapeCallbacks = { Cancel }
       
        self.customizeLoadingWindow.updatingInventory = CreateMenuElement(self.customizeLoadingWindow.titleBar, "Font", false)
        self.customizeLoadingWindow.updatingInventory:SetCSSClass("playnow_title")
        self.customizeLoadingWindow.updatingInventory:SetText(Locale.ResolveString("LOADING_INVENTORY"))

        local cancelButton = CreateMenuElement(self.customizeLoadingWindow, "MenuButton")
        cancelButton:SetCSSClass("playnow_cancel")
        cancelButton:SetText(Locale.ResolveString("CANCEL"))

        cancelButton:AddEventCallbacks({ OnClick =
            Cancel })
    else
        self.customizeLoadingWindow.showCallbacks = { onShowCallback }
        
        self.customizeLoadingWindow:SetIsVisible(true)
    end
end

function GUIMainMenu:CreateTundraUnpackWindow()
    if not self.customizeTundraUnpackWindow then
        self.customizeTundraUnpackWindow = nil
        self.customizeTundraUnpackWindow = self:CreateWindow()
        self.customizeTundraUnpackWindow:SetWindowName("HINT")
        self.customizeTundraUnpackWindow:SetInitialVisible(true)
        self.customizeTundraUnpackWindow:SetIsVisible(true)
        self.customizeTundraUnpackWindow:DisableResizeTile()
        self.customizeTundraUnpackWindow:DisableSlideBar()
        self.customizeTundraUnpackWindow:DisableContentBox()
        self.customizeTundraUnpackWindow:SetCSSClass("tundra_window")
        self.customizeTundraUnpackWindow:DisableCloseButton()
        self.customizeTundraUnpackWindow:DisableTitleBar()
        self.customizeTundraUnpackWindow:SetLayer(kGUILayerMainMenuDialogs)

        self.customizeTundraUnpackWindow:AddEventCallbacks{
            OnEscape = function ()
                if self.customizeTundraUnpackWindow then
                    self:DestroyWindow( self.customizeTundraUnpackWindow )
                    self.customizeTundraUnpackWindow = nil
                    self:CreateCustomizeWindow()
                end
            end
        }

        local icon = CreateMenuElement(self.customizeTundraUnpackWindow, "Image")
        icon:SetCSSClass("tundra_icon")

        local title = CreateMenuElement(self.customizeTundraUnpackWindow, "Font")
        title:SetText(Locale.ResolveString("TUNDRA_BUNDLE_TITLE"))
        title:SetCSSClass("tundra_title")

        local hint = CreateMenuElement(self.customizeTundraUnpackWindow, "Font")
        hint:SetCSSClass("tundra_msg")
        hint:SetText(Locale.ResolveString("TUNDRA_BUNDLE_MSG"))
        hint:SetTextClipped( true, GUIScaleWidth(400), GUIScaleHeight(200) )

        local okButton = CreateMenuElement(self.customizeTundraUnpackWindow, "MenuButton")
        okButton:SetCSSClass("tundra_open")
        okButton:SetText(Locale.ResolveString("OPEN_TUNDRA_BUNDLE"))
        okButton:AddEventCallbacks({ OnClick = function()
            if self.customizeTundraUnpackWindow then
                self:DestroyWindow( self.customizeTundraUnpackWindow )
                self.customizeTundraUnpackWindow = nil
                
                --Opens Tundra Pack
                self:OpenCustomizeWindow( function() Client.ExchangeItem( kTundraBundleItemId, kUnpackTundraBundleItemId ) end )
                
            end
        end})

        local skipButton = CreateMenuElement(self.customizeTundraUnpackWindow, "MenuButton")
        skipButton:SetCSSClass("tundra_later")
        skipButton:SetText(Locale.ResolveString("CANCEL"))
        skipButton:AddEventCallbacks({OnClick = function()
            if self.customizeTundraUnpackWindow then
                self:DestroyWindow( self.customizeTundraUnpackWindow )
                self.customizeTundraUnpackWindow = nil
                self:CreateCustomizeWindow()
            end
        end})
    end
end

function GUIMainMenu:CreateNocturneUnpackWindow()
    if not self.customizeNocturneUnpackWindow then
        self.customizeNocturneUnpackWindow = nil
        self.customizeNocturneUnpackWindow = self:CreateWindow()
        self.customizeNocturneUnpackWindow:SetWindowName("HINT")
        self.customizeNocturneUnpackWindow:SetInitialVisible(true)
        self.customizeNocturneUnpackWindow:SetIsVisible(true)
        self.customizeNocturneUnpackWindow:DisableResizeTile()
        self.customizeNocturneUnpackWindow:DisableSlideBar()
        self.customizeNocturneUnpackWindow:DisableContentBox()
        self.customizeNocturneUnpackWindow:SetCSSClass("nocturne_window")
        self.customizeNocturneUnpackWindow:DisableCloseButton()
        self.customizeNocturneUnpackWindow:DisableTitleBar()
        self.customizeNocturneUnpackWindow:SetLayer(kGUILayerMainMenuDialogs)

        self.customizeNocturneUnpackWindow:AddEventCallbacks{
            OnEscape = function ()
                if self.customizeNocturneUnpackWindow then
                    self:DestroyWindow( self.customizeNocturneUnpackWindow )
                    self.customizeNocturneUnpackWindow = nil
                    self:CreateCustomizeWindow()
                end
            end
        }

        local icon = CreateMenuElement(self.customizeNocturneUnpackWindow, "Image")
        icon:SetCSSClass("nocturne_icon")

        local title = CreateMenuElement(self.customizeNocturneUnpackWindow, "Font")
        title:SetText(Locale.ResolveString("NOCTURNE_BUNDLE_TITLE"))
        title:SetCSSClass("nocturne_title")

        local hint = CreateMenuElement(self.customizeNocturneUnpackWindow, "Font")
        hint:SetCSSClass("nocturne_msg")
        hint:SetText(Locale.ResolveString("NOCTURNE_BUNDLE_MSG"))
        hint:SetTextClipped( true, GUIScaleWidth(400), GUIScaleHeight(200) )

        local okButton = CreateMenuElement(self.customizeNocturneUnpackWindow, "MenuButton")
        okButton:SetCSSClass("nocturne_open")
        okButton:SetText(Locale.ResolveString("OPEN_NOCTURNE_BUNDLE"))
        okButton:AddEventCallbacks({ OnClick = function()
            if self.customizeNocturneUnpackWindow then
                self:DestroyWindow( self.customizeNocturneUnpackWindow )
                self.customizeNocturneUnpackWindow = nil
                
                --Opens Tundra Pack
                self:OpenCustomizeWindow( function() Client.ExchangeItem( kAnnivAlienPackItemId, kUnpackNocturneBundleItemId ) end )
                
            end
        end})

        local skipButton = CreateMenuElement(self.customizeNocturneUnpackWindow, "MenuButton")
        skipButton:SetCSSClass("nocturne_later")
        skipButton:SetText(Locale.ResolveString("CANCEL"))
        skipButton:AddEventCallbacks({OnClick = function()
            if self.customizeNocturneUnpackWindow then
                self:DestroyWindow( self.customizeNocturneUnpackWindow )
                self.customizeNocturneUnpackWindow = nil
                self:CreateCustomizeWindow()
            end
        end})
    end
end

function GUIMainMenu:CreateForgeUnpackWindow()
    if not self.customizeForgeUnpackWindow then
        self.customizeForgeUnpackWindow = nil
        self.customizeForgeUnpackWindow = self:CreateWindow()
        self.customizeForgeUnpackWindow:SetWindowName("HINT")
        self.customizeForgeUnpackWindow:SetInitialVisible(true)
        self.customizeForgeUnpackWindow:SetIsVisible(true)
        self.customizeForgeUnpackWindow:DisableResizeTile()
        self.customizeForgeUnpackWindow:DisableSlideBar()
        self.customizeForgeUnpackWindow:DisableContentBox()
        self.customizeForgeUnpackWindow:SetCSSClass("forge_window")
        self.customizeForgeUnpackWindow:DisableCloseButton()
        self.customizeForgeUnpackWindow:DisableTitleBar()
        self.customizeForgeUnpackWindow:SetLayer(kGUILayerMainMenuDialogs)

        self.customizeForgeUnpackWindow:AddEventCallbacks{
            OnEscape = function ()
                if self.customizeForgeUnpackWindow then
                    self:DestroyWindow( self.customizeForgeUnpackWindow )
                    self.customizeForgeUnpackWindow = nil
                    self:CreateCustomizeWindow()
                end
            end
        }

        local icon = CreateMenuElement(self.customizeForgeUnpackWindow, "Image")
        icon:SetCSSClass("forge_icon")

        local title = CreateMenuElement(self.customizeForgeUnpackWindow, "Font")
        title:SetText(Locale.ResolveString("FORGE_BUNDLE_TITLE"))
        title:SetCSSClass("forge_title")

        local hint = CreateMenuElement(self.customizeForgeUnpackWindow, "Font")
        hint:SetCSSClass("forge_msg")
        hint:SetText(Locale.ResolveString("FORGE_BUNDLE_MSG"))
        hint:SetTextClipped( true, GUIScaleWidth(400), GUIScaleHeight(200) )

        local okButton = CreateMenuElement(self.customizeForgeUnpackWindow, "MenuButton")
        okButton:SetCSSClass("forge_open")
        okButton:SetText(Locale.ResolveString("OPEN_FORGE_BUNDLE"))
        okButton:AddEventCallbacks({ OnClick = function()
            if self.customizeForgeUnpackWindow then
                self:DestroyWindow( self.customizeForgeUnpackWindow )
                self.customizeForgeUnpackWindow = nil
                
                --Opens Tundra Pack
                self:OpenCustomizeWindow( function() Client.ExchangeItem( kAnnivMarinePackItemId, kUnpackForgeBundleItemId ) end )
                
            end
        end})

        local skipButton = CreateMenuElement(self.customizeForgeUnpackWindow, "MenuButton")
        skipButton:SetCSSClass("forge_later")
        skipButton:SetText(Locale.ResolveString("CANCEL"))
        skipButton:AddEventCallbacks({OnClick = function()
            if self.customizeForgeUnpackWindow then
                self:DestroyWindow( self.customizeForgeUnpackWindow )
                self.customizeForgeUnpackWindow = nil
                self:CreateCustomizeWindow()
            end
        end})
    end
end

function GUIMainMenu:CreateShadowUnpackWindow()
    if not self.customizeShadowUnpackWindow then
        self.customizeShadowUnpackWindow = nil
        self.customizeShadowUnpackWindow = self:CreateWindow()
        self.customizeShadowUnpackWindow:SetWindowName("HINT")
        self.customizeShadowUnpackWindow:SetInitialVisible(true)
        self.customizeShadowUnpackWindow:SetIsVisible(true)
        self.customizeShadowUnpackWindow:DisableResizeTile()
        self.customizeShadowUnpackWindow:DisableSlideBar()
        self.customizeShadowUnpackWindow:DisableContentBox()
        self.customizeShadowUnpackWindow:SetCSSClass("shadow_window")
        self.customizeShadowUnpackWindow:DisableCloseButton()
        self.customizeShadowUnpackWindow:DisableTitleBar()
        self.customizeShadowUnpackWindow:SetLayer(kGUILayerMainMenuDialogs)

        self.customizeShadowUnpackWindow:AddEventCallbacks{
            OnEscape = function ()
                if self.customizeShadowUnpackWindow then
                    self:DestroyWindow( self.customizeShadowUnpackWindow )
                    self.customizeShadowUnpackWindow = nil
                    self:CreateCustomizeWindow()
                end
            end
        }

        local icon = CreateMenuElement(self.customizeShadowUnpackWindow, "Image")
        icon:SetCSSClass("shadow_icon")

        local title = CreateMenuElement(self.customizeShadowUnpackWindow, "Font")
        title:SetText(Locale.ResolveString("SHADOW_BUNDLE_TITLE"))
        title:SetCSSClass("shadow_title")

        local hint = CreateMenuElement(self.customizeShadowUnpackWindow, "Font")
        hint:SetCSSClass("shadow_msg")
        hint:SetText(Locale.ResolveString("SHADOW_BUNDLE_MSG"))
        hint:SetTextClipped( true, GUIScaleWidth(400), GUIScaleHeight(200) )

        local okButton = CreateMenuElement(self.customizeShadowUnpackWindow, "MenuButton")
        okButton:SetCSSClass("shadow_open")
        okButton:SetText(Locale.ResolveString("OPEN_SHADOW_BUNDLE"))
        okButton:AddEventCallbacks({ OnClick = function()
            if self.customizeShadowUnpackWindow then
                self:DestroyWindow( self.customizeShadowUnpackWindow )
                self.customizeShadowUnpackWindow = nil

                --Opens Shadow Pack
                self:OpenCustomizeWindow( function() Client.ExchangeItem( kShadowBundleItemId, kUnpackShadowBundleItemId ) end )

            end
        end})

        local skipButton = CreateMenuElement(self.customizeShadowUnpackWindow, "MenuButton")
        skipButton:SetCSSClass("shadow_later")
        skipButton:SetText(Locale.ResolveString("CANCEL"))
        skipButton:AddEventCallbacks({OnClick = function()
            if self.customizeShadowUnpackWindow then
                self:DestroyWindow( self.customizeShadowUnpackWindow )
                self.customizeShadowUnpackWindow = nil
                self:CreateCustomizeWindow()
            end
        end})
    end
end

function GUIMainMenu:OpenCustomizeWindow( onShowCallback )
    self:CreateCustomizeLoadingWindow( onShowCallback )
end

function GUIMainMenu:OnInventoryUpdated()
    if not self.customizeLoadingWindow or not self.customizeLoadingWindow:GetIsVisible() then return end
    
    self.customizeLoadingWindow:SetIsVisible(false)

    if GetOwnsItem(kTundraBundleItemId) then
        self:CreateTundraUnpackWindow()
    elseif GetOwnsItem(kAnnivAlienPackItemId) then
        self:CreateNocturneUnpackWindow()
    elseif GetOwnsItem(kAnnivMarinePackItemId) then
        self:CreateForgeUnpackWindow()
    elseif GetOwnsItem(kShadowBundleItemId) then
        self:CreateShadowUnpackWindow()
    else
        self:CreateCustomizeWindow()
    end
end

function GUIMainMenu:CreateCustomizeWindow()
    self.customizeFrame = self:CreateWindow()
    self:SetupWindow(self.customizeFrame, "CUSTOMIZE PLAYER")
    self.customizeFrame:AddCSSClass("customize_window")
    self.customizeFrame:ResetSlideBar()    -- so it doesn't show up mis-drawn
    self.customizeFrame:DisableSlideBar()
    self.customizeFrame:GetContentBox():SetCSSClass("customize_content")

    self.customizeLeft = CreateMenuElement(self.mainWindow, "ContentBox", true)
    self.customizeLeft:SetCSSClass("customize_left")
    self.customizeRight = CreateMenuElement(self.mainWindow, "ContentBox", true)
    self.customizeRight:SetCSSClass("customize_right")

    self.sliderAngleBar = CreateMenuElement(self.mainWindow, "SlideBar", false)
    self.sliderAngleBar:SetCSSClass("customize_slider")
    self.sliderAngleBar:SetBackgroundSize(Vector(700, 950, 0), true)
    self.sliderAngleBar:HideButton(false)
    self.sliderAngleBar.buttonMin:SetIsVisible(false)
    self.sliderAngleBar.buttonMax:SetIsVisible(false)
    self.sliderAngleBar:ScrollMax()
    self.sliderAngleBar:SetValue(0.5)
    self.sliderAngleBar:Register( self.customizeFrame:GetContentBox(), SLIDE_HORIZONTAL)

    self.sliderAngleBarLabel = CreateMenuElement(self.mainWindow, "Font", false)
    self.sliderAngleBarLabel:SetCSSClass("customize_slider_label")
    self.sliderAngleBarLabel:SetText(Resolve("CUSTOMIZE_MENU_ROTATE"))

    self.marineLogo = CreateMenuElement(self.customizeLeft, "Image", true)
    self.marineLogo:SetCSSClass("customize_logo_marine")

    self.alienLogo = CreateMenuElement(self.customizeRight, "Image", true)
    self.alienLogo:SetCSSClass("customize_logo_alien")
    
    self.shopLink = CreateMenuElement( self.mainWindow, "Image", true )
    self.shopLink:SetCSSClass("customize_shoplink")
    self.shopLink:SetBackgroundTexture("ui/button_store_catalyst.dds")
    self.shopLink:AddEventCallbacks{
        OnClick = function()
            Analytics.RecordEvent("customize_store" )
            Client.ShowWebpage("http://store.steampowered.com/itemstore/4920/")
        end,
        
        OnMouseOver = function()
            self.shopLink:SetBackgroundTexture("ui/button_store_catalyst_hover.dds")
        end,

        OnMouseOut = function()
            self.shopLink:SetBackgroundTexture("ui/button_store_catalyst.dds")
        end
    }
    
    self.marketLink = CreateMenuElement( self.mainWindow, "Image", true )
    self.marketLink:SetCSSClass("customize_marketlink")
    self.marketLink:SetBackgroundTexture("ui/button_market.dds")
    self.marketLink:AddEventCallbacks{
        OnClick = function()
            Analytics.RecordEvent("customize_market")
            Client.ShowWebpage("http://steamcommunity.com/market/search?appid=4920")
        end,
        
        OnMouseOver = function()
            self.marketLink:SetBackgroundTexture("ui/button_market_hover.dds")
        end,
        
        OnMouseOut = function()
            self.marketLink:SetBackgroundTexture("ui/button_market.dds")
        end
    }

    self.badgeselection = CreateMenuElement(self.mainWindow, "GUIBadgesSelection", true)

    self.badgesButton = CreateMenuElement(self.mainWindow, "MenuButton", true)
    self.badgesButton:SetCSSClass("customize_badges")
    self.badgesButton:SetText(Resolve("CUSTOMIZE_MENU_BADGES"))
    self.badgesButton:AddEventCallbacks( { OnClick =
        function(self)
            Analytics.RecordEvent("customize_badges" )
            self.scriptHandle.badgeselection:SetIsVisible(true)
        end } )


    local function InitCustomizationWindow()
        InitCustomizationOptions(self.customizeElements)
    end

    MenuPoses_Initialize()

    local back = CreateMenuElement(self.mainWindow, "MenuButton")
    back:SetCSSClass("customize_back")
    back:SetText(Resolve("BACK"))
    back:AddEventCallbacks( { OnClick = function() self.customizeFrame:SetIsVisible(false) end } )

    local hideTickerCallbacks =
    {
        OnShow = function(self)
            MenuPoses_OnMenuOpened()
            if self.scriptHandle.sliderAngleBar then
                self.scriptHandle.sliderAngleBar:SetValue(0.5)
            end
            menuRefresed = true
        end,

        OnHide = function(self)
            MenuPoses_OnMenuClosed()
            self.scriptHandle.shopLink:SetIsVisible(false)
            self.scriptHandle.marketLink:SetIsVisible(false)
            self.scriptHandle.customizeLeft:SetIsVisible(false)
            self.scriptHandle.customizeRight:SetIsVisible(false)
            self.scriptHandle.sliderAngleBar:SetIsVisible(false)
            self.scriptHandle.sliderAngleBarLabel:SetIsVisible(false)
            self.scriptHandle.badgesButton:SetIsVisible(false)
            self.scriptHandle.badgeselection:SetIsVisible(false)

            back:SetIsVisible(false)
        end
    }

    self.customizeFrame:AddEventCallbacks( hideTickerCallbacks )

    local contentLeft = self.customizeLeft
    local contentRight = self.customizeRight

    local shoulderPadNames = {}
    for index, name in ipairs(kShoulderPadNames) do
        if GetHasShoulderPad(index) then
            table.insert(shoulderPadNames, name)
        end
    end

    local function BuildVariantsTable( enum, data )
        assert( enum and data )
        local ret = {}
        local entry
        for key, name in ipairs( enum ) do
            entry = data[key]
            if data and GetHasVariant( data, key ) then
                ret[#ret+1] = entry.displayName
            end
        end
        return ret
    end

    local marineVariantNames = BuildVariantsTable( kMarineVariant, kMarineVariantData )
    local skulkVariantNames = BuildVariantsTable( kSkulkVariant, kSkulkVariantData )
    local gorgeVariantNames = BuildVariantsTable( kGorgeVariant, kGorgeVariantData )
    local lerkVariantNames = BuildVariantsTable( kLerkVariant, kLerkVariantData )
    local fadeVariantNames = BuildVariantsTable( kFadeVariant, kFadeVariantData )
    local onosVariantNames = BuildVariantsTable( kOnosVariant, kOnosVariantData )
    local exoVariantNames = BuildVariantsTable( kExoVariant, kExoVariantData )
    local rifleVariantNames = BuildVariantsTable( kRifleVariant, kRifleVariantData )
    local pistolVariantNames = BuildVariantsTable( kPistolVariant, kPistolVariantData )
    local axeVariantNames = BuildVariantsTable( kAxeVariant, kAxeVariantData )
    local shotgunVariantNames = BuildVariantsTable( kShotgunVariant, kShotgunVariantData )
    local flamethrowerVariantNames = BuildVariantsTable( kFlamethrowerVariant, kFlamethrowerVariantData )
    local grenadeLauncherVariantNames = BuildVariantsTable( kGrenadeLauncherVariant, kGrenadeLauncherVariantData )
    local welderVariantNames = BuildVariantsTable( kWelderVariant, kWelderVariantData )
    local hmgVariantNames = BuildVariantsTable( kHMGVariant, kHMGVariantData )
    local marineStructureVariantNames = BuildVariantsTable( kMarineStructureVariants, kMarineStructureVariantsData )
    local alienStructureVariantNames = BuildVariantsTable( kAlienStructureVariants, kAlienStructureVariantsData )
    local alienTunnelVariantNames = BuildVariantsTable( kAlienTunnelVariants, kAlienTunnelVariantsData )

    local sexTypes = { "Male", "Female" }
    local sexType = Client.GetOptionString("sexType", "Male")
    Client.SetOptionString("sexType", sexType)

    local leftOptions =
        {
            {
                name    = "SexType",
                label   = Resolve("CUSTOMIZE_MENU_MARINE_GENDER"),
                type    = "select",
                side     = "left",
                values  = sexTypes,
                callback = OnSexChanged,
            },
            {
                name    = "MarineVariantName",
                label   = Resolve("CUSTOMIZE_MENU_MARINE_ARMOR"),
                type    = "select",
                side     = "left",
                values  = marineVariantNames,
                callback = OnMarineChanged,
            },
            {
                name    = "ShoulderPad",
                label   = Resolve("CUSTOMIZE_MENU_SHOULDER_PAD"),
                type    = "select",
                side     = "left",
                values  = shoulderPadNames,
                callback = OnDecalChanged,
            },
            {
                name    = "ExoVariantName",
                label   = Resolve("CUSTOMIZE_MENU_EXO_ARMOR"),
                type    = "select",
                side     = "left",
                values  = exoVariantNames,
                callback = OnExoChanged,
            },
            {
                name    = "RifleVariantName",
                label   = Resolve("CUSTOMIZE_MENU_RIFLE_SKIN"),
                type    = "select",
                side     = "left",
                values  = rifleVariantNames,
                callback = OnRifleChanged,
            },
            {
                name    = "PistolVariantName",
                label   = Resolve("CUSTOMIZE_MENU_PISTOL_SKIN"),
                type    = "select",
                side     = "left",
                values  = pistolVariantNames,
                callback = OnPistolChanged,
            },
            {
                name    = "AxeVariantName",
                label   = Resolve("CUSTOMIZE_MENU_AXE_SKIN"),
                type    = "select",
                side    = "left",
                values  = axeVariantNames,
                callback = OnAxeChanged,
            },
            {
                name    = "ShotgunVariantName",
                label   = Resolve("CUSTOMIZE_MENU_SHOTGUN_SKIN"),
                type    = "select",
                side    = "left",
                values  = shotgunVariantNames,
                callback = OnShotgunChanged,
            },
            {
                name    = "FlamethrowerVariantName",
                label   = Resolve("CUSTOMIZE_MENU_FLAMETHROWER_SKIN"),
                type    = "select",
                side    = "left",
                values  = flamethrowerVariantNames,
                callback = OnFlamethrowerChanged,
            },
            {
                name    = "GrenadeLauncherVariantName",
                label   = Resolve("CUSTOMIZE_MENU_GRENADE_LAUNCHER_SKIN"),
                type    = "select",
                side    = "left",
                values  = grenadeLauncherVariantNames,
                callback = OnGrenadeLauncherChanged,
            },
            {
                name    = "WelderVariantName",
                label   = Resolve("CUSTOMIZE_MENU_WELDER_SKIN"),
                type    = "select",
                side    = "left",
                values  = welderVariantNames,
                callback = OnWelderChanged,
            },
            {
                name    = "HMGVariantName",
                label   = Resolve("CUSTOMIZE_MENU_HMG_SKIN"),
                type    = "select",
                side    = "left",
                values  = hmgVariantNames,
                callback = OnHMGChanged,
            },
            {
                name    = "MarineStructureVariantName",
                label   = Resolve("CUSTOMIZE_MENU_MARINE_STRUCTURES_SKIN"),
                type    = "select",
                side    = "left",
                values  = marineStructureVariantNames,
                callback = OnMarineStructureChanged
            },
            
        }

    local rightOptions =
        {
            {
                name    = "SkulkVariantName",
                label   = Resolve("CUSTOMIZE_MENU_SKULK_TYPE"),
                type    = "select",
                side     = "right",
                values  = skulkVariantNames,
                callback = OnSkulkChanged
            },
            {
                name    = "GorgeVariantName",
                label   = Resolve("CUSTOMIZE_MENU_GORGE_TYPE"),
                type    = "select",
                side     = "right",
                values  = gorgeVariantNames,
                callback = OnGorgeChanged
            },
            {
                name    = "LerkVariantName",
                label   = Resolve("CUSTOMIZE_MENU_LERK_TYPE"),
                type    = "select",
                side     = "right",
                values  = lerkVariantNames,
                callback = OnLerkChanged
            },
            {
                name    = "FadeVariantName",
                label   = Resolve("CUSTOMIZE_MENU_FADE_TYPE"),
                type    = "select",
                side     = "right",
                values  = fadeVariantNames,
                callback = OnFadeChanged
            },
            {
                name    = "OnosVariantName",
                label   = Resolve("CUSTOMIZE_MENU_ONOS_TYPE"),
                type    = "select",
                side     = "right",
                values  = onosVariantNames,
                callback = OnOnosChanged
            },
            {
                name    = "AlienStructureVariantName",
                label   = Resolve("CUSTOMIZE_MENU_ALIEN_STRUCTURES_SKIN"),
                type    = "select",
                side    = "right",
                values  = alienStructureVariantNames,
                callback = OnAlienStructureChanged
            },
            {
                name    = "AlienTunnelVariantName",
                label   = Resolve("CUSTOMIZE_MENU_ALIEN_TUNNELS_SKIN"),
                type    = "select",
                side    = "right",
                values  = alienTunnelVariantNames,
                callback = OnAlienTunnelChanged
            },
        }

    -- save our option elements for future reference
    self.customizeElements = { }

    local customizeFormLeft      = GUIMainMenu.CreateCustomizeForm(self, contentLeft, leftOptions, self.customizeElements)
    local customizeFormRight     = GUIMainMenu.CreateCustomizeForm(self, contentRight, rightOptions, self.customizeElements)

    InitCustomizationWindow()
    self:TriggerOpenAnimation(self.customizeFrame)
end

