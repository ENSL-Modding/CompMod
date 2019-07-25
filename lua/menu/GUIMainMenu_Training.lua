-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenu_Tutorial.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/GUIVideoTutorialIntro.lua")
Script.Load("lua/menu/TutorialMenuButton.lua")

local function GetPageSize()
    return Vector(Client.GetScreenWidth() * 0.9, Client.GetScreenHeight() * 0.9, 0)
end

local kOrderedVideoCategories = 
{
    "General",
    "Marine Basics",
    "Marine Advanced",
    "Marine Weapons",
    "Marine Items",
    "Alien Basics",
    "Alien Advanced",
    "Skulk & Lerk",
    "Gorge",
    "Fade & Onos",
    "Evolution Traits",
}

local function FindIn( list, query )

    for i,item in ipairs(list) do
        if item == query then
            return i
        end
    end

    return -1

end

-- for a given category
function GUIMainMenu:ShowVideoLinksForCategory(cat)

    self:ClearVideoLinks()

    -- find all videos for this cat

    local vids = {}
    for _,video in ipairs(gSpawnTipVideos) do

        if video.category == cat then
            table.insert( vids, video )
        end

    end

    -- first link is BACK

    self.videoLinks[1]:SetText(Locale.ResolveString("BACK"))
    self.videoLinks[1].OnClick = function()
        self:ShowVideoCategoryLinks()
        MainMenu_OnButtonClicked()
    end

    -- setup links

    for i,vid in ipairs(vids) do

        if i+1 > #self.videoLinks then
            Print("Too many vids in category "..cat)
            break
        end

        local link = self.videoLinks[i+1]
        link:SetText(Locale.ResolveString(string.format("%s_TITEL", vid.subKey)))
        link.OnClick = function()
            Analytics.RecordEvent("training_tipvid")
            self.videoPlayer:TriggerVideo(vid, 8)
            MainMenu_OnTrainingLinkedClicked()
        end

    end

end

function GUIMainMenu:ShowVideoCategoryLinks()

    self:ClearVideoLinks()

    for i,cat in ipairs(kOrderedVideoCategories) do

        local link = self.videoLinks[i]
        link:SetText(Locale.ResolveString( string.format("TUT_CAT_%s", i) ))
        link.OnClick = function()
            self:ShowVideoLinksForCategory(cat)
            MainMenu_OnButtonClicked()
        end

    end

end

function GUIMainMenu:ClearVideoLinks()

    for i,link in ipairs(self.videoLinks) do
        link:SetText("")
        link.OnClick = nil
    end

end

local function CreateVideosPage(self)
    self.videosPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.videosPage:SetCSSClass("play_now_content")
    self.videosPage:AddEventCallbacks({
            OnHide = function()
                self.videoPlayer:Hide()
            end
            })

    self.videoLinks = {}

    -- gather unique categories, make sure they are all in our ordered list

    local categorySet = {}
    for _,data in ipairs(gSpawnTipVideos) do

        local cat = data.category

        if not categorySet[ cat ] then
            categorySet[ cat ] = true
            if FindIn(kOrderedVideoCategories, cat) == -1 then
                Print("** ERROR: Could not find category "..cat.." in kOrderedVideoCategories" )
            end
        end

    end

    -- verify other direction
    -- make sure all categories in our list are accounted for
    for _,cat in ipairs(kOrderedVideoCategories) do
        if categorySet[cat] == nil then
            Print("** ERROR: Could not find category "..cat.." in the video data")
        end
    end

    -- create link elements

    for linkId = 0,13 do

        local link = CreateMenuElement(self.videosPage, "Link")
        table.insert( self.videoLinks, link )

        link:SetCSSClass("vid_link_"..linkId)
        link:SetText("link "..linkId)
        link:EnableHighlighting()

    end

    self:ShowVideoCategoryLinks()
    
end

local function CreateTutorialPage(self)

    self.tutorialPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.tutorialPage:SetCSSClass("play_now_content")

    self.menu = CreateMenuElement(self.tutorialPage, "Image")
    self.menu:SetCSSClass("tutorial_menu")

    self.body = CreateMenuElement(self.tutorialPage, "Image")
    self.body:SetCSSClass("tutorial_body")

    self.banner = CreateMenuElement(self.body, "Image")
    self.banner:SetCSSClass("tutorial_banner")

    self.tut_description = CreateMenuElement(self.body, "Font")
    self.tut_description:SetCSSClass("tutorial_description")
    self.tut_description:SetText("This is an example text bla")

    self.startButton = CreateMenuElement(self.body, "MenuButton")
    self.startButton:SetCSSClass("tutorial_start")
    self.startButton:SetText(Locale.ResolveString("TUT_START"))

    self.replayIntroButton = CreateMenuElement(self.menu, "TutorialMenuButton")
    self.replayIntroButton:SetCSSClass("replay_intro_video")
    self.replayIntroButtonHighlight = CreateMenuElement(self.replayIntroButton, "Image")
    self.replayIntroButtonHighlight:SetCSSClass("medium_highlight")
    self.replayIntroButtonHighlight:SetIgnoreEvents(true)
    self.replayIntroButton.highlight_element = self.replayIntroButtonHighlight
    self.replayIntroButtonText = CreateMenuElement(self.replayIntroButton, "Font")
    self.replayIntroButtonText:SetCSSClass("replay_intro_video")
    self.replayIntroButtonText:SetText(Locale.ResolveString("REPLAY_INTRO_VIDEO"))

    self.replayIntroButton:AddEventCallbacks({

            OnClick = function(self, _, doubleclick)
                local onClick = function()
                    Analytics.RecordEvent("training_introvid")
                    GUIVideoTutorialIntro_Play(nil, nil)
                end

                if doubleclick then
                    onClick(self)
                else
                    self.scriptHandle:SetTutorialPage(self, Locale.ResolveString("REPLAY_INTRO_VIDEO_DESCRIPTION"), onClick, "ui/menu/training/intro_banner.dds")
                end
            end,
            
            OnMouseOver = function(self)
                if self.highlight_element then
                    self.highlight_element:SetBackgroundColor(Color(1,1,1,1))
                end
            end,
            
            OnMouseOut = function(self)
                if self.highlight_element and not self.highlight_element.activePage then
                    self.highlight_element:SetBackgroundColor(Color(0,0,0,0))
                end
            end,
        })
    
    self.playTutorial1Button = CreateMenuElement(self.menu, "TutorialMenuButton")
    self.playTutorial1Button:SetCSSClass("play_tutorial1")
    self.playTutorial1ButtonHighlight = CreateMenuElement(self.playTutorial1Button, "Image")
    self.playTutorial1ButtonHighlight:SetCSSClass("medium_highlight")
    self.playTutorial1ButtonHighlight:SetIgnoreEvents(true)
    self.playTutorial1Button.highlight_element = self.playTutorial1ButtonHighlight
    self.playTutorial1ButtonText = CreateMenuElement(self.playTutorial1Button, "Font")
    self.playTutorial1ButtonText:SetCSSClass('play_tutorial')
    self.playTutorial1ButtonText:SetText(Locale.ResolveString("PLAY_TUT1"))
    
    self.playTutorial1Button:AddEventCallbacks({
            OnClick = function(self, _, doubleclick)
                local onClick = function(self)
                    Analytics.RecordEvent("training_tutorial1")
                    self.scriptHandle:StartMarineTutorial()
                end

                if doubleclick then
                    onClick(self)
                else
                    self.scriptHandle:SetTutorialPage(self, Locale.ResolveString("PLAY_TUT1_DESCRIPTION"), onClick, "ui/menu/training/marine_banner.dds")
                end
            end,
            
            OnMouseOver = function(self)
                if self.highlight_element then
                    self.highlight_element:SetBackgroundColor(Color(1,1,1,1))
                end
            end,
            
            OnMouseOut = function(self)
                if self.highlight_element and not self.highlight_element.activePage then
                    self.highlight_element:SetBackgroundColor(Color(0,0,0,0))
                end
            end,
        })
        
    self.playTutorial2Button = CreateMenuElement(self.menu, "TutorialMenuButton")
    self.playTutorial2Button:SetCSSClass("play_tutorial2")
    self.playTutorial2ButtonHighlight = CreateMenuElement(self.playTutorial2Button, "Image")
    self.playTutorial2ButtonHighlight:SetCSSClass("medium_highlight")
    self.playTutorial2ButtonHighlight:SetIgnoreEvents(true)
    self.playTutorial2Button.highlight_element = self.playTutorial2ButtonHighlight
    self.playTutorial2ButtonText = CreateMenuElement(self.playTutorial2Button, "Font")
    self.playTutorial2ButtonText:SetCSSClass("play_tutorial2")
    self.playTutorial2ButtonText:SetText(Locale.ResolveString("PLAY_TUT2"))
    
    self.playTutorial2Button:AddEventCallbacks({
            OnClick = function(self, _, doubleclick)
                local onClick = function(self)
                    Analytics.RecordEvent("training_tutorial2")
                    self.scriptHandle:StartAlienTutorial()
                end

                if doubleclick then
                    onClick(self)
                else
                    self.scriptHandle:SetTutorialPage(self, Locale.ResolveString("PLAY_TUT2_DESCRIPTION"), onClick, "ui/menu/training/alien_banner.dds")
                end
            end,
            
            OnMouseOver = function(self)
                if self.highlight_element then
                    self.highlight_element:SetBackgroundColor(Color(1,1,1,1))
                end
            end,
            
            OnMouseOut = function(self)
                if self.highlight_element and not self.highlight_element.activePage then
                    self.highlight_element:SetBackgroundColor(Color(0,0,0,0))
                end
            end,
        })

    self.playTutorial3Button = CreateMenuElement(self.menu, "TutorialMenuButton")
    self.playTutorial3Button:SetCSSClass("play_tutorial3")
    self.playTutorial3ButtonHighlight = CreateMenuElement(self.playTutorial3Button, "Image")
    self.playTutorial3ButtonHighlight:SetCSSClass("medium_highlight")
    self.playTutorial3ButtonHighlight:SetIgnoreEvents(true)
    self.playTutorial3Button.highlight_element = self.playTutorial3ButtonHighlight
    self.playTutorial3ButtonText = CreateMenuElement(self.playTutorial3Button, "Font")
    self.playTutorial3ButtonText:SetCSSClass('play_tutorial3')
    self.playTutorial3ButtonText:SetText(Locale.ResolveString("PLAY_TUT3"))

    self.playTutorial3Button:AddEventCallbacks({
        OnClick = function(self, _, doubleclick)
            local onClick = function(self)
                Analytics.RecordEvent("training_tutorial3")
                self.scriptHandle:StartMarineCommanderTutorial()
            end

            if doubleclick then
                onClick(self)
            else
                self.scriptHandle:SetTutorialPage(self, Locale.ResolveString("PLAY_TUT3_DESCRIPTION"), onClick, "ui/menu/training/commander_banner.dds")
            end
        end,

        OnMouseOver = function(self)
            if self.highlight_element then
                self.highlight_element:SetBackgroundColor(Color(1,1,1,1))
            end
        end,

        OnMouseOut = function(self)
            if self.highlight_element and not self.highlight_element.activePage then
                self.highlight_element:SetBackgroundColor(Color(0,0,0,0))
            end
        end,
    })

    self.playTutorial4Button = CreateMenuElement(self.menu, "TutorialMenuButton")
    self.playTutorial4Button:SetCSSClass("play_tutorial4")
    self.playTutorial4ButtonHighlight = CreateMenuElement(self.playTutorial4Button, "Image")
    self.playTutorial4ButtonHighlight:SetCSSClass("medium_highlight")
    self.playTutorial4ButtonHighlight:SetIgnoreEvents(true)
    self.playTutorial4Button.highlight_element = self.playTutorial4ButtonHighlight
    self.playTutorial4ButtonText = CreateMenuElement(self.playTutorial4Button, "Font")
    self.playTutorial4ButtonText:SetCSSClass('play_tutorial4')
    self.playTutorial4ButtonText:SetText(Locale.ResolveString("PLAY_TUT4"))
    
    self.playTutorial4Button:AddEventCallbacks({
        OnClick = function(self, _, doubleclick)
            local onClick = function(self)
                Analytics.RecordEvent("training_tutorial4")
                self.scriptHandle:StartAlienCommanderTutorial()
            end

            if doubleclick then
                onClick(self)
            else
                self.scriptHandle:SetTutorialPage(self, Locale.ResolveString("PLAY_TUT4_DESCRIPTION"), onClick, "ui/menu/training/alien_commander_banner.dds")
            end
        end,

        OnMouseOver = function(self)
            if self.highlight_element then
                self.highlight_element:SetBackgroundColor(Color(1,1,1,1))
            end
        end,

        OnMouseOut = function(self)
            if self.highlight_element and not self.highlight_element.activePage then
                self.highlight_element:SetBackgroundColor(Color(0,0,0,0))
            end
        end,
    })
    
    self.playTutorial1ButtonCheckmark = CreateMenuElement(self.playTutorial1Button, "Image")
    self.playTutorial2ButtonCheckmark = CreateMenuElement(self.playTutorial2Button, "Image")
    self.playTutorial3ButtonCheckmark = CreateMenuElement(self.playTutorial3Button, "Image")
    self.playTutorial4ButtonCheckmark = CreateMenuElement(self.playTutorial4Button, "Image")
    self.playTutorial1ButtonCheckmark:SetCSSClass("play_tutorial_checkmark")
    self.playTutorial2ButtonCheckmark:SetCSSClass("play_tutorial_checkmark")
    self.playTutorial3ButtonCheckmark:SetCSSClass("play_tutorial_checkmark")
    self.playTutorial4ButtonCheckmark:SetCSSClass("play_tutorial_checkmark")
    local check1Visible = Client.GetAchievement("First_0_6")
    local check2Visible = Client.GetAchievement("First_0_7")
    local check3Visible = Client.GetAchievement("First_0_8")
    local check4Visible = Client.GetAchievement("First_0_9")
    self.playTutorial1ButtonCheckmark:SetIsVisible(check1Visible)
    self.playTutorial2ButtonCheckmark:SetIsVisible(check2Visible)
    self.playTutorial3ButtonCheckmark:SetIsVisible(check3Visible)
    self.playTutorial4ButtonCheckmark:SetIsVisible(check4Visible)
    self.playTutorial1ButtonCheckmark:SetIgnoreEvents(true)
    self.playTutorial2ButtonCheckmark:SetIgnoreEvents(true)
    self.playTutorial3ButtonCheckmark:SetIgnoreEvents(true)
    self.playTutorial4ButtonCheckmark:SetIgnoreEvents(true)

    self.sandboxButton = CreateMenuElement(self.menu, "TutorialMenuButton")
    self.sandboxButton:SetCSSClass("play_sandbox")
    self.sandboxButtonHighlight = CreateMenuElement(self.sandboxButton, "Image")
    self.sandboxButtonHighlight:SetCSSClass("medium_highlight")
    self.sandboxButtonHighlight:SetIgnoreEvents(true)
    self.sandboxButton.highlight_element = self.sandboxButtonHighlight
    self.sandboxButtonText = CreateMenuElement(self.sandboxButton, "Font")
    self.sandboxButtonText:SetCSSClass("play_sandbox")
    self.sandboxButtonText:SetText(Locale.ResolveString("PLAY_BOOTCAMP"))

    self.sandboxButton:AddEventCallbacks({
        OnClick = function(self, _, doubleclick)
            local onClick = function(self)
                Analytics.RecordEvent("training_sandbox")
                self.scriptHandle:DoQuickJoin("ns2")
            end

            if doubleclick then
                onClick(self)
            else
                self.scriptHandle:SetTutorialPage(self, Locale.ResolveString("PLAY_SANDBOX_DESCRIPTION"), onClick, "ui/menu/training/bootcamp_banner.dds")
            end
        end,

        OnMouseOver = function(self)
            if self.highlight_element then
                self.highlight_element:SetBackgroundColor(Color(1,1,1,1))
            end
        end,

        OnMouseOut = function(self)
            if self.highlight_element and not self.highlight_element.activePage then
                self.highlight_element:SetBackgroundColor(Color(0,0,0,0))
            end
        end,
    })
    
    self.hiveChallengeButton = CreateMenuElement(self.menu, "TutorialMenuButton")
    self.hiveChallengeButton:SetCSSClass("play_hive_challenge")
    self.hiveChallengeButtonHighlight = CreateMenuElement(self.hiveChallengeButton, "Image")
    self.hiveChallengeButtonHighlight:SetCSSClass("medium_highlight")
    self.hiveChallengeButtonHighlight:SetIgnoreEvents(true)
    self.hiveChallengeButton.highlight_element = self.hiveChallengeButtonHighlight
    self.hiveChallengeButtonText = CreateMenuElement(self.hiveChallengeButton, "Font")
    self.hiveChallengeButtonText:SetCSSClass("play_hive_challenge")
    self.hiveChallengeButtonText:SetText(Locale.ResolveString("PLAY_HIVE_CHALLENGE"))
    
    self.hiveChallengeButton:AddEventCallbacks({
            OnClick = function(self, _, doubleclick)
                local onClick = function(self)
                    Analytics.RecordEvent("training_hive")
                    self.scriptHandle:StartHiveChallenge()
                end

                if doubleclick then
                    onClick(self)
                else
                    self.scriptHandle:SetTutorialPage(self, Locale.ResolveString("TUT_HIVE_CHALLENGE_TOOLTIP"), onClick, "ui/menu/training/hive_challenge_banner.dds")
                end
            end,
            
            OnMouseOver = function(self)
                if self.highlight_element then

                    self.highlight_element:SetBackgroundColor(Color(1,1,1,1))
                end
            end,
            
            OnMouseOut = function(self)
                if self.highlight_element and not self.highlight_element.activePage then
                    self.highlight_element:SetBackgroundColor(Color(0,0,0,0))
                end
            end,
        })
    
    self.skulkChallengeButton = CreateMenuElement(self.menu, "TutorialMenuButton")
    self.skulkChallengeButton:SetCSSClass("play_skulk_challenge")
    self.skulkChallengeButtonHighlight = CreateMenuElement(self.skulkChallengeButton, "Image")
    self.skulkChallengeButtonHighlight:SetCSSClass("medium_highlight")
    self.skulkChallengeButtonHighlight:SetIgnoreEvents(true)
    self.skulkChallengeButton.highlight_element = self.skulkChallengeButtonHighlight
    self.skulkChallengeButtonText = CreateMenuElement(self.skulkChallengeButton, "Font")
    self.skulkChallengeButtonText:SetCSSClass("play_skulk_challenge")
    self.skulkChallengeButtonText:SetText(Locale.ResolveString("PLAY_SKULK_CHALLENGE"))
    
    self.skulkChallengeButton:AddEventCallbacks({
            OnClick = function(self, _, doubleclick)
                local onClick = function(self)
                    Analytics.RecordEvent("training_skulk")
                    self.scriptHandle:StartSkulkChallenge()
                end

                if doubleclick then
                    onClick(self)
                else
                    self.scriptHandle:SetTutorialPage(self, Locale.ResolveString("TUT_SKULK_CHALLENGE_TOOLTIP"), onClick, "ui/menu/training/skulk_challenge_banner.dds")
                end
            end,
            
            OnMouseOver = function(self)
                if self.highlight_element then

                    self.highlight_element:SetBackgroundColor(Color(1,1,1,1))
                end
            end,
            
            OnMouseOut = function(self)
                if self.highlight_element and not self.highlight_element.activePage then
                    self.highlight_element:SetBackgroundColor(Color(0,0,0,0))
                end
            end,
        })

    local buttonOrder = {
        self.replayIntroButton,
        self.playTutorial1Button,
        self.playTutorial2Button,
        self.playTutorial3Button,
        self.playTutorial4Button,
        self.sandboxButton,
        self.hiveChallengeButton,
        self.skulkChallengeButton,
    }

    for i, button in ipairs(buttonOrder) do
        button:SetTopOffset((i-1)*96)
    end
    
end

function GUIMainMenu:SetTutorialPage(guiElement, description, OnClick, banner)
    self.startButton.OnClick = OnClick
    self.tut_description:SetText(WordWrap(self.tut_description.text, description, 0, GUIScaleWidth(540)))
    self.banner:SetBackgroundTexture(banner)

    if self.oldActiveTutElement then
        self.oldActiveTutElement:SetBackgroundColor(Color(0,0,0,0))
        self.oldActiveTutElement.activePage = false
    end

    if guiElement.highlight_element then
        guiElement.highlight_element:SetBackgroundColor(Color(1,1,1,1))
        guiElement.highlight_element.activePage = true
        self.oldActiveTutElement = guiElement.highlight_element
    end
end

function GUIMainMenu:StartHiveChallenge()
    
    local modIndex = Client.GetLocalModId("challenges/hive_challenge")
    
    if modIndex == -1 then
        Shared.Message("Hive Challenge mod does not exist!")
        return
    end
    
    local password      = "dummypassword"..ToString(math.random())
    local port          = 27015
    local maxPlayers    = 1    -- leaving room for bots
    local serverName    = "private hive-challenge server"
    local mapName       = "ns2_ch_hive_platform"
    Client.SetOptionString("lastServerMapName", mapName)
    
    if Client.StartServer(modIndex, mapName, serverName, password, port, maxPlayers, true, true) then
        LeaveMenu()
    end
    
end

function GUIMainMenu:StartSkulkChallenge()
    
    local modIndex = Client.GetLocalModId("challenges/skulk_challenge")
    
    if modIndex == -1 then
        Shared.Message("Hive Challenge mod does not exist!")
        return
    end
    
    local password      = "dummypassword"..ToString(math.random())
    local port          = 27015
    local maxPlayers    = 1    -- leaving room for bots
    local serverName    = "private skulk-challenge server"
    local mapName       = "ns2_skulk_challenge_1"
    Client.SetOptionString("lastServerMapName", mapName)
    
    if Client.StartServer(modIndex, mapName, serverName, password, port, maxPlayers, true, true) then
        LeaveMenu()
    end
    
end

function GUIMainMenu:StartAlienTutorial()

    local modIndex = Client.GetLocalModId("bootcamp/alien_1")
    
    if modIndex == -1 then
        Shared.Message("Tutorial mod does not exist!")
        return
    end

    local password      = "dummypassword"..ToString(math.random())
    local port          = 27015
    local maxPlayers    = 1    -- need room for bots
    local serverName    = "private tutorial server"
    local mapName       = "ns2_tut_alien_1"
    Client.SetOptionString("lastServerMapName", mapName)
    
    if Client.StartServer(modIndex, mapName, serverName, password, port, maxPlayers, true, true) then
        LeaveMenu()
    end
    
end

function GUIMainMenu:StartMarineTutorial()

    local modIndex = Client.GetLocalModId("bootcamp/marine_1")
    
    if modIndex == -1 then
        Shared.Message("Tutorial mod does not exist!")
        return
    end

    local password      = "dummypassword"..ToString(math.random())
    local port          = 27015
    local maxPlayers    = 1    -- need room for bots
    local serverName    = "private tutorial server"
    local mapName       = "ns2_tut_marine_1"
    Client.SetOptionString("lastServerMapName", mapName)
    
    if Client.StartServer(modIndex, mapName, serverName, password, port, maxPlayers, true, true) then
        LeaveMenu()
    end
    
end

function GUIMainMenu:StartMarineCommanderTutorial()

    local modIndex = Client.GetLocalModId("bootcamp/command_1")
    
    if modIndex == -1 then
        Shared.Message("Tutorial mod does not exist!")
        return
    end

    local password      = "dummypassword"..ToString(math.random())
    local port          = 27015
    local maxPlayers    = 1
    local serverName    = "private tutorial server"
    local mapName       = "ns2_tut_cmd_1"
    Client.SetOptionString("lastServerMapName", mapName)
    
    if Client.StartServer(modIndex, mapName, serverName, password, port, maxPlayers, true, true) then
        LeaveMenu()
    end
    
end

function GUIMainMenu:StartAlienCommanderTutorial()

    local modIndex = Client.GetLocalModId("bootcamp/command_2")
    
    if modIndex == -1 then
        Shared.Message("Tutorial mod does not exist!")
        return
    end

    local password      = "dummypassword"..ToString(math.random())
    local port          = 27015
    local maxPlayers    = 1
    local serverName    = "private tutorial server"
    local mapName       = "ns2_tut_cmd_2"
    Client.SetOptionString("lastServerMapName", mapName)
    
    if Client.StartServer(modIndex, mapName, serverName, password, port, maxPlayers, true, true) then
        LeaveMenu()
    end
    
end

local function CreateSandboxPage(self)

    self.sandboxPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.sandboxPage:SetCSSClass("play_now_content")

    local formOptions = {
        {
            name  = "Map",
            label = Locale.ResolveString("SERVERBROWSER_MAP"),
            type  = "select",
            value = "Docking",
        },
    }

    local note = CreateMenuElement( self.sandboxPage, "Font", false )
    note:SetCSSClass("sandbox_note")
    note:SetText(Locale.ResolveString("TUT_MESSAGE_2"))
    
end

function GUIMainMenu:StartSandbox()

    local modIndex = Client.GetLocalModId("explore")

    if modIndex == -1 then
        Shared.Message("Sandbox mod does not exist!")
        return
    end


    local password      = "dummypassword"
    local port          = 27015
    local maxPlayers    = 1
    local serverName    = "private sandbox server"
    local mapName       = "ns2_docking"
    Client.SetOptionString("lastServerMapName", mapName)
    
    if Client.StartServer(modIndex, mapName, serverName, password, port, maxPlayers, true, true) then
        Client.SetOptionBoolean("sandboxMode", true)
        LeaveMenu()
    end
    
end

local function CreateBotsPage(self)

    self.botsPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.botsPage:SetCSSClass("play_now_content")
    
    local minPlayers            = 2
    local maxPlayers            = 24
    local playerLimitOptions    = { }
    
    for i = minPlayers, maxPlayers do
        table.insert(playerLimitOptions, i)
    end

    local minBots            = 0
    local maxBots            = 8
    local botLimitOptions    = { }

    for i = minBots, maxBots do
        table.insert(botLimitOptions, i)
    end

    local hostOptions = 
    {
        {   
            name   = "ServerName",            
            label  = Locale.ResolveString("SERVERBROWSER_SERVERNAME"),
            value  = "Training vs. Bots"
        },
        {   
            name   = "Password",            
            label  = Locale.ResolveString("SERVERBROWSER_CREATE_PASSWORD"),
        },
        {
            name    = "Map",
            label   = Locale.ResolveString("SERVERBROWSER_MAP"),
            type    = "select",
            value  = "Descent",
        },
        {
            name    = "PlayerLimit",
            label   = Locale.ResolveString("SERVERBROWSER_CREATE_PLAYER_LIMIT"),
            type    = "select",
            values  = playerLimitOptions,
            value   = 16
        },
        {
            name    = "NumMarineBots",
            label   = Locale.ResolveString("TUT_MBOTNUMBER"),
            type    = "select",
            values  = botLimitOptions,
            value   = 6
        },
        {
            name    = "AddMarineCommander",
            label   = Locale.ResolveString("TUT_MCOMMBOT"),
            value   = "false",
            type    = "checkbox"
        },
        {
            name    = "NumAlienBots",
            label   = Locale.ResolveString("TUT_ABOTNUMBER"),
            type    = "select",
            values  = botLimitOptions,
            value   = 6
        },
        {
            name    = "AddAlienCommander",
            label   = Locale.ResolveString("TUT_ACOMMBOT"),
            value   = "true",
            type    = "checkbox"
        }
    }
        
    local createdElements = {}
    local content = self.botsPage
    local form = GUIMainMenu.CreateOptionsForm(self, content, hostOptions, createdElements)
    form:SetCSSClass("createserver")
    
    local mapList = createdElements.Map
    
    self.playBotsButton = CreateMenuElement(self.trainingWindow, "MenuButton")
    self.playBotsButton:SetCSSClass("apply")
    self.playBotsButton:SetText(Locale.ResolveString("PLAY"))
    
    self.playBotsButton:AddEventCallbacks(
    {
        OnClick = function()

            local formData = form:GetFormData()

            -- validate
            if tonumber(formData.NumMarineBots) == nil then
                MainMenu_SetAlertMessage("Not a valid number for # MARINE BOTS: "..formData.NumMarineBots)
            elseif tonumber(formData.NumAlienBots) == nil then
                MainMenu_SetAlertMessage("Not a valid number for # ALIEN BOTS: "..formData.NumAlienBots)
            else

                 Analytics.RecordEvent("training_vsbots")
                 
                -- start server!
                local password   = formData.Password
                local port       = 27015
                local maxPlayers = formData.PlayerLimit
                local serverName = formData.ServerName
                local mapName    = "ns2_" .. string.lower(formData.Map)
                Client.SetOptionString("lastServerMapName", mapName)

                Client.SetOptionBoolean("sendBotsCommands", true)
                Client.SetOptionInteger("botsSettings_numMarineBots", tonumber(formData.NumMarineBots))
                Client.SetOptionInteger("botsSettings_numAlienBots", tonumber(formData.NumAlienBots))
                Client.SetOptionBoolean("botsSettings_marineCom", formData.AddMarineCommander)
                Client.SetOptionBoolean("botsSettings_alienCom", formData.AddAlienCommander)
                
                if Client.StartServer(mapName, serverName, password, port, maxPlayers) then
                    LeaveMenu()
                end

            end
            
        end
    })

    local note = CreateMenuElement( form, "Font", false )
    note:SetCSSClass("bot_note")
    note:SetText(Locale.ResolveString("TUT_MESSAGE_3"))

    self.botsPage:AddEventCallbacks(
    {
     OnShow = function (self)
            mapList:SetOptions( MainMenu_GetMapNameList() )
        end
    })
    
end

function GUIMainMenu:HideAll()

    self.videosPage:SetIsVisible(false)
    self.tutorialPage:SetIsVisible(false)
    self.trainingWindow:DisableSlideBar()
    self.trainingWindow:ResetSlideBar()

end

function GUIMainMenu:SelectNextTutorialPage()
    local check1Visible = Client.GetAchievement("First_0_6")
    local check2Visible = Client.GetAchievement("First_0_7")
    local check3Visible = Client.GetAchievement("First_0_8")
    local check4Visible = Client.GetAchievement("First_0_9")

    if not check1Visible then

        local onClick = function(self)
            Analytics.RecordEvent("training_tutorial1")
            self.scriptHandle:StartMarineTutorial()
        end
        self:SetTutorialPage(self.playTutorial1Button, Locale.ResolveString("PLAY_TUT1_DESCRIPTION"), onClick, "ui/menu/training/marine_banner.dds")

    elseif not check2Visible then

        local onClick = function(self)
            Analytics.RecordEvent("training_tutorial2")
            self.scriptHandle:StartAlienTutorial()
        end
        self:SetTutorialPage(self.playTutorial2Button, Locale.ResolveString("PLAY_TUT2_DESCRIPTION"), onClick, "ui/menu/training/alien_banner.dds")

    elseif not check3Visible then

        local onClick = function(self)
            Analytics.RecordEvent("training_tutorial3")
            self.scriptHandle:StartMarineCommanderTutorial()
        end

        self:SetTutorialPage(self.playTutorial3Button, Locale.ResolveString("PLAY_TUT3_DESCRIPTION"), onClick, "ui/menu/training/commander_banner.dds")

    elseif not check4Visible then

        local onClick = function(self)
            Analytics.RecordEvent("training_tutorial4")
            self.scriptHandle:StartAlienCommanderTutorial()
        end

        self:SetTutorialPage(self.playTutorial4Button, Locale.ResolveString("PLAY_TUT4_DESCRIPTION"), onClick, "ui/menu/training/alien_commander_banner.dds")

    elseif Client.GetSkillTier() ~= -1 or Client.GetSkillTier() <= kRookieMaxSkillTier then

        local onClick = function(self)
            Analytics.RecordEvent("training_sandbox")
            self.scriptHandle:DoQuickJoin("ns2")
        end

        self:SetTutorialPage(self.sandboxButton, Locale.ResolveString("PLAY_SANDBOX_DESCRIPTION"), onClick, "ui/menu/training/bootcamp_banner.dds")

    else

        local onClick = function(self)
            Analytics.RecordEvent("training_hive")
            self.scriptHandle:StartSkulkChallenge()
        end

        self:SetTutorialPage(self.skulkChallengeButton, Locale.ResolveString("TUT_SKULK_CHALLENGE_TOOLTIP"), onClick, "ui/menu/training/skulk_challenge_banner.dds")

    end
end

function GUIMainMenu:CreateTrainingWindow()

    self.trainingWindow = self:CreateWindow()
    self.trainingWindow:DisableCloseButton()
    self:SetupWindow(self.trainingWindow, "TRAINING")
    self.trainingWindow:SetCSSClass("tutorial_window")
    
    -- for whatever reason, the height specified in main_menu.css is just completely disregarded... so we'll hard
    -- code it here...  964 = (1080 * 80%) + 100 (the height of a button)
    self.trainingWindow:SetHeight(964, false)
    
    if not self.videoPlayer then
        self.videoPlayer = GetGUIManager():CreateGUIScriptSingle("GUITipVideo")
    end
    
    local tabs = 
    {
        { label = Locale.ResolveString("TUTORIAL"), func = function(self)
                    self.scriptHandle:HideAll()
                    self.scriptHandle.tutorialPage:SetIsVisible(true)
                end },
        { label = Locale.ResolveString("TIP_CLIPS"), func = function(self)
                    self.scriptHandle:HideAll()
                    self.scriptHandle.videosPage:SetIsVisible(true)
                end },
        --{ label = Locale.ResolveString("VS_BOTS"), func = function(self)
        --        if not gVideoPlaying then
        --                self.scriptHandle:HideAll()
        --                self.scriptHandle.botsPage:SetIsVisible(true)
        --                self.scriptHandle.playBotsButton:SetIsVisible(true)
        --            end
        --        end },
    }
        
    local xTabWidth = 256

    local tabBackground = CreateMenuElement(self.trainingWindow, "Image")
    tabBackground:SetCSSClass("tab_background")
    tabBackground:SetIgnoreEvents(true)
    
    local tabAnimateTime = 0.1
        
    for i = 1,#tabs do
    
        local tab = tabs[i]
        local tabButton = CreateMenuElement(self.trainingWindow, "MenuButton")
        
        local function ShowTab()
            for j =1, #tabs do
                local tabPosition = tabButton.background:GetPosition()
                tabBackground:SetBackgroundPosition( tabPosition, false, tabAnimateTime ) 
            end
        end
    
        tabButton:SetCSSClass("tab")
        tabButton:SetText(tab.label)
        tabButton:AddEventCallbacks({ OnClick = tab.func })
        tabButton:AddEventCallbacks({ OnClick = ShowTab })
        
        local tabWidth = tabButton:GetWidth()
        tabButton:SetBackgroundPosition( Vector(tabWidth * (i - 1), 0, 0) )
        
    end

    --CreateBotsPage(self)
    --CreateSandboxPage(self)
    CreateVideosPage(self)
    CreateTutorialPage(self)

    self.footer = CreateMenuElement(self.trainingWindow:GetContentBox(), "Form")
    self.footer:SetCSSClass("tutorial_footer_bg")
    
    self.footer.back = CreateMenuElement(self.footer, "MenuButton")
    self.footer.back:SetCSSClass("tutorial_footer_play")
    self.footer.back:SetText(Locale.ResolveString("BACK"))
    self.footer.back:AddEventCallbacks{
        OnClick = function ()
            self.trainingWindow:SetIsVisible(false)
            self.videoPlayer:Hide()

            if self.trainingWindow.playScreen then
                self.showWindowAnimation:SetIsVisible(false)

                self:HideMenu()

                self.trainingWindow.playScreen:Show()
                self.trainingWindow.playScreen = nil

            end
        end
    }

    self:HideAll()

    self.tutorialPage:SetIsVisible(true)

    self:SelectNextTutorialPage()
end
