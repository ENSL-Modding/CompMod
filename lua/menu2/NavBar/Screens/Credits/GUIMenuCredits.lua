-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/Credits/GUIMenuCredits.lua
--
--    Created by:   Brock Gillespie (brock@naturalselection2.com)
--
--    Viewer for CreditsData.lua file shipped with the game with simple transitions and grouping
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================


Script.Load("lua/menu2/MenuStyles.lua") --To ref existing things ...isn't this already in scope though?
Script.Load("lua/menu2/NavBar/Screens/GUIMenuNavBarScreen.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/GUIMenuTabbedBox.lua")
Script.Load("lua/menu2/GUIMenuGraphic.lua")  --required for background images / logos?
Script.Load("lua/menu2/GUIMenuText.lua") --should use this, or plan GUIText?

Script.Load("lua/menu2/NavBar/Screens/Credits/CreditsData.lua")


---@class GUIMenuCredits : GUIMenuNavBarScreen
class "GUIMenuCredits" (GUIMenuNavBarScreen)

-- how many pixels to leave between the bottom of the screen and the bottom of this screen.
local kScreenBottomDistance = 250
local kScreenWidth = 2577

local kTabHeight = 94
local kTabMinWidth = 900

local kInnerBackgroundSideSpacing = 32 -- horizontal spacing between edge of outer background and inner background.
local kInnerBackgroundTopSpacing = 116 -- spacing between top edge of outer background and inner background.
-- spacing between bottom edge of outer background and inner background (not including tab height!).
local kInnerBackgroundBottomSpacing = 18

local kInnerBackgroundImageSideSpacing = 0
local kInnerBackgroundImageTopSpacing = 0
local kInnerBackgroundImageBottomSpacing = 6

local kInnerCreditPageSideSpacing = 64
local kInnerCreditsPageTopSpacing = 144

local kBgImageScreenTime = 10
local kBgImageFadeTime = 5
local kBackgroundAlphaInit = 0.32
local kBgFullColor = Color(1,1,1,kBackgroundAlphaInit)
local kBgHiddenColor = Color(1,1,1,0)

local kCreditsPageBgAlpha = 0.075
local kCreditsPageTime = 6
local kCreditsPageTimeManual = 20 --additional time before page-flip


local function UpdateInnerBackgroundSize(self, coolBackSize)
    self.innerBack:SetSize(coolBackSize - Vector(kInnerBackgroundSideSpacing * 2, kInnerBackgroundBottomSpacing + kInnerBackgroundTopSpacing, 0))
end

local function UpdateCreditsBackgroundSize(self, innerBackSize)
    for i = 1, #self.creditsPages do
        if self.creditsPages[i] then
            self.creditsPages[i]:SetSize(innerBackSize - Vector(kInnerBackgroundImageSideSpacing * 2, kInnerBackgroundImageBottomSpacing, 0))
        end
    end
end

local function UpdateInnerBackgroundImageSize(self, innerBackSize)
    for i = 1, #self.backgroundImages do
        if self.backgroundImages[i] then
            self.backgroundImages[i]:SetSize(innerBackSize - Vector(kInnerBackgroundImageSideSpacing * 2, kInnerBackgroundImageBottomSpacing, 0))
        end
    end
end

local function OnCreditsMenuSizeChanged(self)
    -- Make the outer background the same size as this object.
    self.coolBack:SetSize(self:GetSize() + Vector(0, GUIMenuNavBar.kUnderlapYSize, 0))
    self.innerBack:SetSize(self:GetSize() + Vector(-kInnerBackgroundSideSpacing * 2, GUIMenuNavBar.kUnderlapYSize - kInnerBackgroundTopSpacing - kInnerBackgroundBottomSpacing - kTabHeight, 0))
end

local function RecomputeCreditsMenuHeight(self)
    -- Resize this object to leave a consistent spacing to the bottom of the screen.
    local aScale = self.absoluteScale
    local ssSpacing = kScreenBottomDistance * aScale.y
    local ssBottomY = Client.GetScreenHeight() - ssSpacing
    local ssTopY = self:GetParent():GetScreenPosition().y
    local ssSizeY = ssBottomY - ssTopY
    local localSizeY = ssSizeY / aScale.y
    self:SetSize(kScreenWidth, localSizeY)
end

local function OnAbsoluteScaleChanged(self, aScale)
    self.absoluteScale = aScale
    RecomputeCreditsMenuHeight(self)
end

local function GetNextIndex(curIdx, maxVal)
    local index = 1
    if curIdx < maxVal then
        index = curIdx + 1
    end
    return index
end

local function GetPrevIndex(curIdx, maxVal)
    local index = 1
    if curIdx < maxVal and curIdx > 1 then
        index = curIdx - 1
    end
    return index
end

local function isValidBackgroundImage(str) --TODO change to search a table instead
    return not string.find(str, "loadingscreen") and not string.find(str, "IntroScreen")
end

local function GetMaxLines( parentHeight, lineHeight )
    return math.floor( parentHeight / lineHeight )
end

local gCreditsMenu_debugSkipAutoFlip = false


function GUIMenuCredits:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "screenName", "Credits")
    GUIMenuNavBarScreen.Initialize(self, params, errorDepth)
    PopParamChange(params, "screenName")

    self:GetRootItem():SetDebugName("creditsMenu")
    self:ListenForCursorInteractions() -- prevent click-through

    self.creditsPages = {}
    self.activePageIdx = 1
    self.lastPageIdx = 0
    self.creditPageTime = 0
    self.pageManuallyChanged = false

    self.backgroundImages = {}
    self.activeBackgroundIndex = 1
    self.activeImageScreenTime = 0

    self.lastUpdatedTime = 0

    self.runAnimation = false --early outs OnUpdate

    -- Background (two layers, the "cool" layer, and a basic layer on top of that).
    self.coolBack = CreateGUIObject("coolBack", GUIMenuTabbedBox, self)
    self.coolBack:SetLayer(-2)
    self.coolBack:SetPosition(0, -GUIMenuNavBar.kUnderlapYSize)
    
    self.innerBack = CreateGUIObject("innerBack", GUIMenuBasicBox, self)
    self.innerBack:SetLayer(-1)
    self.innerBack:SetPosition(kInnerBackgroundSideSpacing, kInnerBackgroundTopSpacing - GUIMenuNavBar.kUnderlapYSize)
    self:HookEvent(self.coolBack, "OnSizeChanged", UpdateInnerBackgroundSize)
    
    -- Create bottom tab buttons.  These change based on which credits page is active
    self.bottomButtons = CreateGUIObject("bottomButtons", GUIMenuTabButtonsWidget, self)
    self.bottomButtons:SetLayer(2)
    self.bottomButtons:AlignBottom()
    self.bottomButtons:SetLeftLabel("<")
    self.bottomButtons:SetLeftEnabled(false) --init in disabled state, only useful once we're past page 1
    self.bottomButtons:SetRightLabel(">")
    self.bottomButtons:SetTabMinWidth(kTabMinWidth)
    self.bottomButtons:SetTabHeight(kTabHeight)
    self.bottomButtons:SetFont(MenuStyle.kButtonFont)
    
    self:HookEvent(self.bottomButtons, "OnLeftPressed", self.OnPreviousPagePressed)
    self:HookEvent(self.bottomButtons, "OnRightPressed", self.OnNextPagePressed)

    self.coolBack:HookEvent(self.bottomButtons, "OnTabSizeChanged", self.coolBack.SetTabSize)
    self.coolBack:SetTabSize(self.bottomButtons:GetTabSize())

    EnableOnAbsoluteScaleChangedEvent(self)

    self:HookEvent(self, "OnAbsoluteScaleChanged", OnAbsoluteScaleChanged)
    self:HookEvent(GetGlobalEventDispatcher(), "OnResolutionChanged", RecomputeCreditsMenuHeight)
    
    self:HookEvent(self, "OnSizeChanged", OnCreditsMenuSizeChanged)
    
    self:InitializeBackgrounds()
    
    self:InitializeCreditsData( gGameCreditsData )

    --TODO ?? Add "timer bar" for each page display to show how much longer its on screen?

    self:SetUpdates(true)

end

function GUIMenuCredits:Display(immediate)
    GUIMenuNavBarScreen.Display(self, immediate)
    self.runAnimation = true
end

function GUIMenuCredits:Hide()
    GUIMenuNavBarScreen.Hide(self)

    self.runAnimation = false

    self.creditsPages[self.activePageIdx]:SetVisible(false)
    self.activePageIdx = 1
    self.creditsPages[self.activePageIdx]:SetVisible(true)

    self.activeImageScreenTime = kBgImageScreenTime
end

function GUIMenuCredits:OnNextPagePressed()
    local nextIdx = GetNextIndex( self.activePageIdx, #self.creditsPages )
    self.creditsPages[self.activePageIdx]:SetVisible(false)
    self.creditsPages[nextIdx]:SetVisible(true)
    self.activePageIdx = nextIdx
    self.pageManuallyChanged = true
end

function GUIMenuCredits:OnPreviousPagePressed()
    local prevIdx = GetPrevIndex( self.activePageIdx, #self.creditsPages )
    self.creditsPages[self.activePageIdx]:SetVisible(false)
    self.creditsPages[prevIdx]:SetVisible(true)
    self.activePageIdx = prevIdx
    self.pageManuallyChanged = true
end

--TODO Need a big UWE logo in here somewhere

function GUIMenuCredits:InitializeBackgrounds()
    local backgroundFileNames = {}
    Shared.GetMatchingFileNames("screens/*.jpg", false, backgroundFileNames )

    ASSERT(#backgroundFileNames > 0)

    for i = 1, #backgroundFileNames do 
        if isValidBackgroundImage(backgroundFileNames[i]) then
            local t = #self.backgroundImages + 1
            self.backgroundImages[t] = {}
            self.backgroundImages[t] = CreateGUIObject("backgroundImage-" .. i, GUIMenuGraphic, self.innerBack)
            self.backgroundImages[t].sourceImage = backgroundFileNames[i]
            self.backgroundImages[t]:SetPosition( kInnerBackgroundImageSideSpacing, kInnerBackgroundTopSpacing - GUIMenuNavBar.kUnderlapYSize )
            self.backgroundImages[t]:SetTexture( backgroundFileNames[i] )
            self.backgroundImages[t]:SetColor( (i == 1 and kBgFullColor or kBgHiddenColor) )
            self.backgroundImages[t]:SetVisible( i == 1 )
        end
    end
    
    --Updates all image sizes in self.backgroundImages
    self:HookEvent(self.innerBack, "OnSizeChanged", UpdateInnerBackgroundImageSize)

    self.activeImageScreenTime = kBgImageScreenTime
    self.activeBackgroundIndex = 1
end

function GUIMenuCredits:InitializeCreditsData( data )
    ASSERT(data and type(data) == "table" and #data > 0)

    self.activePageIdx = 1
    self.lastPageIdx = #data

    for s = 0, #data do
        if data[s] and data[s].title and (data[s].members or data[s].groups) then
            self.creditsPages[s] = CreateGUIObject("creditsPage" .. s, GUIMenuBasicBox, self.innerBack)
            self.creditsPages[s]:SetPosition( kInnerCreditPageSideSpacing, kInnerCreditsPageTopSpacing - GUIMenuNavBar.kUnderlapYSize)
            self.creditsPages[s]:SetStrokeWidth(0)
            self.creditsPages[s]:SetStrokeColor(Color(0,0,0,0))
            self.creditsPages[s]:SetFillColor(Color(0,0,0,0))
            self:HookEvent(self.innerBack, "OnSizeChanged", UpdateCreditsBackgroundSize)

            self:InitCreditsSectionPage( self.creditsPages[s], data[s], s )
            self.creditsPages[s]:SetVisible( s == self.activePageIdx )
        end
    end

end

function GUIMenuCredits:InitCreditsSectionPage( creditsPage, data, idx )
    assert(creditsPage and data)

    local titleStr = data.title
    local isGrouped = data.groups ~= nil
    local autoPageTimer = data.autoTime ~= nil and data.autoTime or kCreditsPageTime

    creditsPage.pageContents = {}
    creditsPage.pageAutoTime = autoPageTimer
    --?? other properties?

    creditsPage.pageContents.pageTitle = CreateGUIObject("creditPageTitle" .. idx, GUIMenuText, creditsPage,
    {
        defaultColor = MenuStyle.kServerEntryHighlightStrokeColor,
        font = MenuStyle.kButtonFont
    })
    creditsPage.pageContents.pageTitle:SetPosition( 0, kInnerBackgroundTopSpacing - GUIMenuNavBar.kUnderlapYSize )
    creditsPage.pageContents.pageTitle:SetText( titleStr )

    local maxHeight = 1000  --TODO move to file local-global
    local maxWidth = 2048 --?

    --Handle Credits data that is a simple list
    if not isGrouped then 

        creditsPage.pageContents.members = {}
        
        local colWidth = data.colWidth ~= nil and data.colWidth or 750
        local maxColmLines = GetMaxLines( maxHeight, 24 + MenuStyle.kOptionFont.size )  --FIXME Need to move to local-class prop 
        local lineOffset = kInnerBackgroundTopSpacing - GUIMenuNavBar.kUnderlapYSize + (MenuStyle.kOptionGroupHeadingFont.size + 18) --FIXME move all refs to class-prop

        local initYOffset = 0
        for g = 1, #data.members do

            local yOffset = lineOffset * g
            local xOffset = 48
            if g == 1 then
                initYOffset = yOffset
            end

            if g > maxColmLines then  --FIXME This doesn't allow for 3+ cols  ...is this REALLY worth fixing?
                xOffset = xOffset + colWidth
                yOffset = initYOffset * ( g - maxColmLines)
            end
            
            local color = MenuStyle.kTooltipText
            local itemFont = MenuStyle.kOptionFont
            local textStr
            if type(data.members[g]) == "table" then
                ASSERT(data.members[g].value)
                if data.members[g].style == "bold" then
                    color = MenuStyle.kWhite
                    itemFont = MenuStyle.kOptionFont
                end
                textStr = data.members[g].value
            else
                textStr = data.members[g]
                if data.style == "bold" then
                    color = MenuStyle.kOffWhite
                end
            end

            local memberText = CreateGUIObject( "pageMembers" .. g, GUIMenuText, creditsPage, { defaultColor = color, font = itemFont } )
            memberText:SetPosition( xOffset, yOffset )
            memberText:SetText( textStr )

            creditsPage.pageContents.members[g] = memberText
        end

    --Handle Credits data that has sub-sections
    else
        
        creditsPage.pageContents.sections = {}

        local secLineStart = 1
        local lineOffset = kInnerBackgroundTopSpacing - GUIMenuNavBar.kUnderlapYSize + (MenuStyle.kOptionGroupHeadingFont.size + 18)

        for g = 1, #data.groups do

            creditsPage.pageContents.sections[g] = {}
            creditsPage.pageContents.sections[g].members = {}

            --Handle sub-section title
            local subTitleYOffset = lineOffset * secLineStart
            local subTitleXOffset = 48

            local subTitleText = CreateGUIObject( "subTitle" .. g, GUIMenuText, creditsPage, 
            { 
                defaultColor = MenuStyle.kOffWhite,
                font = MenuStyle.kHeadingFont
            } )
            subTitleText:SetPosition( subTitleXOffset, subTitleYOffset )
            subTitleText:SetText( data.groups[g].subtitle )

            creditsPage.pageContents.sections[g].subTitle = subTitleText

            secLineStart = secLineStart + 1

            --Prime params for members list
            local colWidth = data.groups[g].colWidth ~= nil and data.groups[g].colWidth or 500
            local colLimit = math.floor( maxWidth / colWidth )
            local col = 0

            --TODO Allow for variable lineOffset (so smaller fonts take up less vertical space)
            
            for m = 1, #data.groups[g].members do

                local xOffset = 96 + colWidth * col
                local yOffset = lineOffset * secLineStart

                local color = MenuStyle.kTooltipText
                local itemFont = MenuStyle.kOptionFont

                local memberText = CreateGUIObject( "pageMembers" .. g, GUIMenuText, creditsPage, { defaultColor = color, font = itemFont } )
                memberText:SetPosition( xOffset, yOffset )
                memberText:SetText( data.groups[g].members[m] )

                creditsPage.pageContents.sections[g].members[m] = memberText

                if data.groups[g].forceNewline ~= nil and data.groups[g].forceNewline then
                    secLineStart = secLineStart + 1
                else
                    col = ( col / colLimit == 1 and 0 or col + 1 )
                    if col == 0 then
                        secLineStart = secLineStart + 1
                    end
                end
                
            end

            secLineStart = secLineStart + 1 --always advance new line on new grouping
        end
        
    end

end

local kUpdateRate = 0.033  --"30fps"
function GUIMenuCredits:OnUpdate(delta, time)
    
    if not self.runAnimation then
        return
    end

    
    if self.lastUpdatedTime + kUpdateRate > time then
        return
    end

    self.lastUpdatedTime = time

    self.bottomButtons:SetLeftEnabled( self.activePageIdx > 1 )

    if self.pageManuallyChanged then
        self.creditPageTime = time + kCreditsPageTimeManual  --extend a little
        self.pageManuallyChanged = false
    end

    --Set the auto-flip timer based on credits data
    local creditsChangeTime = self.creditPageTime + self.creditsPages[self.activePageIdx].pageAutoTime
    
    if creditsChangeTime <= time and not gCreditsMenu_debugSkipAutoFlip then
        local nextIdx = GetNextIndex( self.activePageIdx, #self.creditsPages )
        self.creditsPages[self.activePageIdx]:SetVisible(false)
        self.creditsPages[nextIdx]:SetVisible(true)
        self.activePageIdx = nextIdx
        self.creditPageTime = time
    end


--Update background image roation and transitions
    local numBgs = #self.backgroundImages
    local fadeStartTime = self.activeImageScreenTime + kBgImageFadeTime
    local fadeEndTime = self.activeImageScreenTime + kBgImageScreenTime
    local alphaStep = 0.01

    --Crossfade transition
    if fadeStartTime >= time and fadeEndTime > time then
        local nextIdx = GetNextIndex( self.activeBackgroundIndex, numBgs )
        
        local curColor = self.backgroundImages[self.activeBackgroundIndex]:GetColor()
        local nextColor = self.backgroundImages[nextIdx]:GetColor()

        local newCurColor = Color( curColor.r, curColor.g, curColor.b, Clamp(curColor.a - alphaStep, 0, kBackgroundAlphaInit) )
        local newNextColor = Color( nextColor.r, nextColor.g, nextColor.b, Clamp(nextColor.a + alphaStep, 0, kBackgroundAlphaInit) )

        self.backgroundImages[self.activeBackgroundIndex]:SetColor( newCurColor )
        self.backgroundImages[nextIdx]:SetColor( newNextColor )

        if newNextColor.a >= alphaStep and not self.backgroundImages[nextIdx]:GetVisible() then
            self.backgroundImages[nextIdx]:SetVisible(true)
        elseif newCurColor.a < alphaStep and self.backgroundImages[self.activeBackgroundIndex]:GetVisible() then
            self.backgroundImages[self.activeBackgroundIndex]:SetVisible(false)
        end
    end

    if fadeEndTime <= time then
        self.activeImageScreenTime = time
        --self.backgroundImages[self.activeBackgroundIndex]:SetVisible(false)
        --self.backgroundImages[self.activeBackgroundIndex]:SetColor( kBgHiddenColor )
        
        self.activeBackgroundIndex = GetNextIndex(self.activeBackgroundIndex, numBgs)
        --self.backgroundImages[self.activeBackgroundIndex]:SetVisible(true)
        --self.backgroundImages[self.activeBackgroundIndex]:SetColor( kBgFullColor )
    end

end


