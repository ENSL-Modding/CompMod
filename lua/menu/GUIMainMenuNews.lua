-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenuNews.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local widthFraction = 0.4
local newsAspect = 1.2/1
local kTextureName = "*mainmenu_news"
local fadeColor = Color(1,1,1,0)
local lastUpdatedtime = 0
local playAnimation = "show"

-- Non local so modders can easily change the URL.
kMainMenuNewsURL = "http://unknownworlds.com/ns2/ingamenews/"

class 'GUIMainMenuNews' (Window)

function GUIMainMenuNews:Initialize()
    Window.Initialize(self)

    self:SetInitialVisible(true)
    self:DisableResizeTile()
    self:DisableSlideBar()
    self:DisableTitleBar()
    self:DisableContentBox()
    self:DisableCloseButton()

    self:SetLayer(kGUILayerMainMenuNews)
    self:SetOpacity(0)

    self.logo =  CreateMenuElement(self, "Image")
    self.logo:SetBackgroundTexture("ui/menu/logo.dds")

    
    local width = widthFraction * 1920
    
    local rightMargin = 96
    local y = 10    -- top margin

    local logoAspect = 600/192
    
    self.logo:SetBackgroundSize( Vector(width, width/logoAspect, 0) )
    self.logo:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.logo:SetBackgroundPosition(Vector( -width-rightMargin, y, 0))
    self.logo:SetBackgroundColor(fadeColor)
    self.logo:AddEventCallbacks{
        OnClick = function()
            Client.ShowWebpage("http://unknownworlds.com/ns2/")
        end
    }

    y = y + width/logoAspect
    
    local logoAspect = 300/100
    local buttonSpacing = 10
    local logoWidth = width/2.0 - buttonSpacing/2
    local buttonHeight = logoWidth / logoAspect
    y = y - 8

    self.leftButton =  CreateMenuElement(self, "Image")
    self.leftButton:SetBackgroundColor(fadeColor)
    self.leftButton:SetBackgroundSize( Vector(logoWidth, buttonHeight, 0) )
    self.leftButton:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.leftButton:SetBackgroundPosition(Vector( -width-rightMargin, y, 0))
    self.leftButton:SetBackgroundTexture("ui/button_discord.dds")
    self.leftButton:AddEventCallbacks{
        OnClick = function()
            GUIMainMenuNews_LeftButtonClick()
        end,
        OnMouseIn = function(self)
            self:SetBackgroundTexture("ui/button_discord_hover.dds")
        end,
        OnMouseOut = function(self)
            self:SetBackgroundTexture("ui/button_discord.dds")
        end,
    }


    self.rightButton = CreateMenuElement(self, "Image")
    self.rightButton:SetBackgroundColor(fadeColor)
    self.rightButton:SetBackgroundSize( Vector(logoWidth, buttonHeight, 0) )
    self.rightButton:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.rightButton:SetBackgroundPosition(Vector( -width-rightMargin+logoWidth+buttonSpacing, y, 0))
    self.rightButton:SetBackgroundTexture("ui/button_store_catalyst.dds")
    self.rightButton:AddEventCallbacks{
        OnClick = function()
            GUIMainMenuNews_RightButtonClick()
        end,
        OnMouseIn = function(self)
            self:SetBackgroundTexture("ui/button_store_catalyst_hover.dds")
        end,
        OnMouseOut = function(self)
            self:SetBackgroundTexture("ui/button_store_catalyst.dds")
        end,
    }

    y = y + buttonHeight + buttonSpacing
    local newsHt = 1080 - (y*1.25)

    self.webContainer = CreateMenuElement(self, "Image")
    self.webContainer:SetBackgroundTexture(kTextureName)
    self.webContainer:SetBackgroundColor(fadeColor)
    self.webContainer:SetBackgroundSize(Vector(width, newsHt, 0))
    self.webContainer:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.webContainer:SetBorderWidth(1)
    self.webContainer:SetBorderColor(Color(79/255, 126/255, 145/255))
    self.webContainer:SetBackgroundPosition(Vector(-width-rightMargin, y, 0))

    self.webContainer.webView = Client.CreateWebView(width, newsHt)
    self.webContainer.webView:SetTargetTexture(kTextureName)
    self.webContainer.webView:LoadUrl(kMainMenuNewsURL)
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
            local within, withinX, withinY = GUIItemContainsPoint(self:GetBackground(), mouseX, mouseY)
            if within then
                self.webView:OnMouseMove(withinX, withinY)
            end
        end,
        OnMouseUp = function(self)
            self.webView:OnMouseUp(0)
        end,
        OnMouseDown = function(self)
            self.webView:OnMouseDown(0)
        end,
        OnMouseWheel = function(self, up)
            if up then
                --if not self.interaction_recorded then
                --    Analytics.RecordEvent( "menu_news" )
                --    self.interaction_recorded = true
                --end
                self.webView:OnMouseWheel(30, 0)
                MainMenu_OnSlide()
            else
                --if not self.interaction_recorded then
                --    Analytics.RecordEvent( "menu_news" )
                --    self.interaction_recorded = true
                --end
                self.webView:OnMouseWheel(-30, 0)
                MainMenu_OnSlide()
            end
        end
    }

    if self.hideNews then
        self:HideNews()
    end
end

function GUIMainMenuNews:HideNews()
    self.hideNews = true

    self.webContainer:SetIsVisible(false)
    self.leftButton:SetIsVisible(false)
    self.rightButton:SetIsVisible(false)
end

function GUIMainMenuNews:ShowNews()
    self.hideNews = false

    self.webContainer:SetIsVisible(true)
    self.leftButton:SetIsVisible(true)
    self.rightButton:SetIsVisible(true)
end

function GUIMainMenuNews_LeftButtonClick()
	Analytics.RecordEvent( "menu_discord" )
	Client.ShowWebpage("https://discord.gg/ns2")
end

function GUIMainMenuNews_RightButtonClick()
	Analytics.RecordEvent( "menu_store" )
	Client.ShowWebpage("http://store.steampowered.com/dlc/4920/")
end

function GUIMainMenuNews:Update(deltaTime)

   if fadeColor.a <= 0 then
       self:SetIsVisible(false)
   elseif fadeColor.a > 0 then
       self:SetIsVisible(true)
   end
    
    self:PlayFadeAnimation()
    
end

function GUIMainMenuNews:SetIsVisible(visible)
    self.logo:SetIsVisible(visible)

    if not self.hideNews then
        self.webContainer:SetIsVisible(visible)
        self.leftButton:SetIsVisible(visible)
        self.rightButton:SetIsVisible(visible)
    end

    self.isVisible = visible
end

function GUIMainMenuNews:ShowAnimation()

    if fadeColor.a <= 1 and Shared.GetTime() - lastUpdatedtime > 0.005 then
        fadeColor.a = fadeColor.a + 0.075
        self.webContainer:SetBackgroundColor(fadeColor)
        self.logo:SetBackgroundColor(fadeColor)
        self.leftButton:SetBackgroundColor(fadeColor)
        self.rightButton:SetBackgroundColor(fadeColor)
        lastUpdatedtime = Shared.GetTime()
    end

end

function GUIMainMenuNews:HideAnimation()

    if fadeColor.a >= 0 and Shared.GetTime() - lastUpdatedtime > 0.005 then
        fadeColor.a = fadeColor.a - 0.075
        self.webContainer:SetBackgroundColor(fadeColor)
        self.logo:SetBackgroundColor(fadeColor)
        self.leftButton:SetBackgroundColor(fadeColor)
        self.rightButton:SetBackgroundColor(fadeColor)
        lastUpdatedtime = Shared.GetTime()
    end

end

function GUIMainMenuNews:PlayFadeAnimation()

    if playAnimation == "show" then
        self:ShowAnimation()
    elseif playAnimation == "hide" then
        self:HideAnimation()
    end
   
end

function GUIMainMenuNews:SetPlayAnimation(animType)
    playAnimation = animType
end

function GUIMainMenuNews:LoadURL(url)
    self.webView:LoadUrl(url)
end

function GUIMainMenuNews:GetTagName()
    return "menunews"
end


Event.Hook("Console_refreshnews", function() MainMenu_LoadNewsURL(kMainMenuNewsURL) end)