-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenu_Changelog.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIChangelog' (Window)


local kTextureName = "*changelog_webpage_render"
GUIChangelog.URL = "http://unknownworlds.com/ns2/ingame-changelog/"
GUIChangelog.titleText = Locale.ResolveString("CHANGELOG_TITLE")

function GUIChangelog:Initialize()
	Window.Initialize(self)

	self:SetWindowName("Changelog")
	self:SetInitialVisible(true)
	self:DisableResizeTile()
	self:DisableSlideBar()
	self:DisableContentBox()
	self:SetLayer(kGUILayerMainMenuDialogs)

	self:AddEventCallbacks{
		OnEscape = function(self)
			self:SetIsVisible(false)
            GetGUIMainMenu():MaybeOpenPopup()
		end
	}

	-- Hook the close...
	self.titleBar.closeButton:AddEventCallbacks( { 
		OnClick = function(self)
			if self.windowHandle then
				self.windowHandle:SetIsVisible(false)
				GetGUIMainMenu():MaybeOpenPopup()
			end
		end
	} )
        

	self.title = CreateMenuElement(self:GetTitleBar(), "Font")
	self.title:SetText(self.titleText)
	self.title:SetCSSClass("title")

	self.webContainer = CreateMenuElement(self, "Image")
	self.webContainer:SetBackgroundTexture(kTextureName)
	self.webContainer:SetCSSClass("web")

	self.webContainer.webView = Client.CreateWebView(self.webContainer:GetWidth(), self.webContainer:GetHeight())
	self.webContainer.webView:SetTargetTexture(kTextureName)
	self.webContainer.webView:LoadUrl(self.URL)
    self.webContainer.webView:SetGreenScreen(true)
    
	self.webContainer:AddEventCallbacks{
		OnMouseIn = function(self)
			local windowManager = GetWindowManager()
			windowManager:HandleFocusBlur(windowManager:GetActiveWindow(), self)
		end,
		OnMouseOut = function(self)
			GetWindowManager():ClearActiveElement(self)
		end,
		OnMouseOver = function(self)
			local mouseX, mouseY = Client.GetCursorPosScreen()
			local _, withinX, withinY = GUIItemContainsPoint(self:GetBackground(), mouseX, mouseY)
			self.webView:OnMouseMove(withinX, withinY)
		end,
		OnMouseUp = function(self)
			self.webView:OnMouseUp(0)
		end,
		OnMouseDown = function(self)
			self.webView:OnMouseDown(0)
		end,
		OnMouseWheel = function(self, up)
			if up then
				self.webView:OnMouseWheel(30, 0)
				MainMenu_OnSlide()
			else
				self.webView:OnMouseWheel(-30, 0)
				MainMenu_OnSlide()
			end
		end
	}

	self.footer = CreateMenuElement(self, "Image")
	self.footer:SetCSSClass("footer")

	self.voteText = CreateMenuElement(self.footer, "Font")
	self.voteText:SetText(Locale.ResolveString("CHANGELOG_FEEDBACK"))

	local textwidth = self.voteText:GetWidth()
	self.upVoteButton = CreateMenuElement(self.footer, "MenuButton")
	self.upVoteButton:AddEventCallbacks({ OnClick = function()
		Analytics.RecordEvent( "changelog_upvote" )
		self:OnVote()
	end})
	self.upVoteButton:SetCSSClass("upvote")
	self.upVoteButton:SetLeftOffset(textwidth + 35)

	self.neutralVoteButton = CreateMenuElement(self.footer, "MenuButton")
	self.neutralVoteButton:AddEventCallbacks({ OnClick = function()
		Analytics.RecordEvent( "changelog_neutralvote" )
		self:OnVote()
	end})
	self.neutralVoteButton:SetCSSClass("neutralvote")
	self.neutralVoteButton:SetLeftOffset(textwidth + 77)

	self.downVoteButton = CreateMenuElement(self.footer, "MenuButton")
	self.downVoteButton:AddEventCallbacks({ OnClick = function()
		Analytics.RecordEvent( "changelog_downvote" )
		self:OnVote()
	end})
	self.downVoteButton:SetCSSClass("downvote")
	self.downVoteButton:SetLeftOffset(textwidth + 119)

	self.discordButton = CreateMenuElement(self.footer, "Link")
	self.discordButton:AddEventCallbacks({
		OnClick = function()
			Analytics.RecordEvent( "changelog_discord" )
			Client.ShowWebpage("https://discord.gg/ns2")
		end})
	self.discordButton:SetText(Locale.ResolveString("CHANGELOG_DISCORD"))
	self.discordButton:SetCSSClass("discord")
end

function GUIChangelog:OnVote()
	self.upVoteButton:SetIsVisible(false)
	self.downVoteButton:SetIsVisible(false)
	self.neutralVoteButton:SetIsVisible(false)

	self.voteText:SetText(Locale.ResolveString("CHANGELOG_FEEDBACK_RESPONSE"))
end

function GUIChangelog:OnEscape()
	self:SetIsVisible(false)
            GetGUIMainMenu():MaybeOpenPopup()
end

function GUIChangelog:GetTagName()
	return "changelog"
end
