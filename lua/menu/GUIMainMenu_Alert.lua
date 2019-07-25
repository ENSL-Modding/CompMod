-- ======= Copyright (c) 2003-2018, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenu_Alert.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIAlertWindow' (Window)

local iconTexture = PrecacheAssetSafe("ui/menu/alert-message-icon.dds")

function GUIAlertWindow:Initialize()
    Window.Initialize(self)

    self:SetWindowName(Locale.ResolveString("ALERT"))
    self:SetInitialVisible(true)
    self:DisableResizeTile()
    self:DisableSlideBar()
    self:DisableTitleBar()
    self:DisableContentBox()
    self:SetLayer(kGUILayerMainMenuDialogs)

    self.icon = CreateMenuElement(self, "Image")
    self.icon:SetBackgroundTexture( iconTexture )

    self.title = CreateMenuElement(self, "Font")
    self.title:SetCSSClass("title")

    self.retryButton = CreateMenuElement(self, "MenuButton")
    self.retryButton:SetText(string.UTF8Upper(Locale.ResolveString("RETRY")))
    self.retryButton:AddEventCallbacks({ OnClick = function()
        OnRetryCommand()
        self:SetIsVisible(false)
    end})
    self.retryButton:SetCSSClass("retry")

    self.tryAnotherButton = CreateMenuElement(self, "MenuButton")
    self.tryAnotherButton:SetText(Locale.ResolveString("TRY_ANOTHER_SERVER"))
    self.tryAnotherButton:AddEventCallbacks({ OnClick = function()
        local gMenu = GetGUIMainMenu and GetGUIMainMenu()
        if gMenu then gMenu:DoQuickJoin() end
        self:SetIsVisible(false)
    end})
    self.tryAnotherButton:SetCSSClass("try")

    self.okButton = CreateMenuElement(self, "MenuButton")
    self.okButton:SetText(string.UTF8Upper(Locale.ResolveString("CLOSE")))
    self.okButton:SetCSSClass("okay")

    self.okButton:AddEventCallbacks({ OnClick = function()
        self:SetIsVisible(false)
    end})
end

function GUIAlertWindow:OnEscape()
    self:SetIsVisible(false)
end

function GUIAlertWindow:GetTagName()
    return "newiteminfo"
end