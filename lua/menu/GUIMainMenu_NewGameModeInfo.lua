-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenu_NewGameModeInfo.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUINewGameModeInfo' (Window)

function GUINewGameModeInfo:Initialize()
	Window.Initialize(self)

	self:SetWindowName("New Item Received!")
	self:SetInitialVisible(true)
	self:DisableResizeTile()
	self:DisableSlideBar()
	self:DisableTitleBar()
	self:DisableContentBox()
	self:DisableCloseButton()
	self:SetLayer(kGUILayerMainMenuDialogs)

	self.icon = CreateMenuElement(self, "Image")

	self.title = CreateMenuElement(self, "Font")
	self.title:SetCSSClass("title")

	self.description = CreateMenuElement(self, "Font")
	self.description:SetCSSClass("description")

	self.playButton = CreateMenuElement(self, "MenuButton")
	self.playButton:SetText(Locale.ResolveString("PLAY_NOW"))
	self.playButton:AddEventCallbacks({ OnClick = function()
		self:SetIsVisible(false)
		GetGUIMainMenu():DoQuickJoin(self.gamemode)
		Analytics.RecordEvent( string.format("%s_play", self.event) )
	end})
	self.playButton:SetCSSClass("playnow")

	self.okButton = CreateMenuElement(self, "MenuButton")
	self.okButton:SetText(Locale.ResolveString("CANCEL"))
	self.okButton:AddEventCallbacks({ OnClick = function()
		Shared.Message("Ok")
		self:SetIsVisible(false)
		Analytics.RecordEvent( string.format("%s_later", self.event) )
	end})
end

function GUINewGameModeInfo:Setup(data)
	self.icon:SetBackgroundTexture(data.icon)

	self.title:SetText(string.format("Mod Highlight: %s", data.title))
	self.description:SetText(data.description)

    local desc_wrap = WordWrap( self.description.text, data.description, 0, 400 )
    self.description:SetText( desc_wrap )
    
	self.gamemode = data.gamemode
    self.event = data.event
end

function GUINewGameModeInfo:OnEscape()
	self:SetIsVisible(false)
end

function GUINewGameModeInfo:GetTagName()
	return "newgamemodeinfo"
end
