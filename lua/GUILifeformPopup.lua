-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUILifeformPopup.lua
--
-- Created by: Trevor Harris (trevor@naturalselection2.com)
--
-- Manages the displaying any text notifications on the screen.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")

class "GUILifeformPopup" (GUIScript)

local kPopupSound = PrecacheAsset("sound/NS2.fev/alien/common/res_received")
Client.PrecacheLocalSound(kPopupSound)

-- Lifeform will only be suggested if < ~20% of players on the team (round up, not including
-- commander) are this lifeform.
local kPlayerLifeformLimitFraction = 0.2

-- update less frequently when no animations are playing.
local kSlowUpdateInterval = 0.25

-- updates animations too, so should be as fast as possible for smoothness.
local kFastUpdateInterval = 0.0

local kAnimateInDuration = 1.0
local kHoldDuration = 8.5
local kAnimateOutDuration = 0.5

local kMinimumRoundTime = 30 -- amount of round time that must have passed before popup can be shown.
local kMinTimeAfterSpawn = 1 -- maximum amount of time after a player spawns, before which the popup cannot show.
local kMaxTimeAfterSpawn = 15 -- maximum amount of time after a player spawns in which the popup can be shown.

local kFlyInXOffset = 600

local kMockupSize = Vector(2880, 1620, 0)

local kAssassinIcon = PrecacheAsset("ui/lifeformPopup/assassinIcon.dds")
local kBruiserIcon = PrecacheAsset("ui/lifeformPopup/bruiserIcon.dds")
local kFadeIcon = PrecacheAsset("ui/lifeformPopup/fadeIcon.dds")
local kGorgeIcon = PrecacheAsset("ui/lifeformPopup/gorgeIcon.dds")
local kLerkIcon = PrecacheAsset("ui/lifeformPopup/lerkIcon.dds")
local kOnosIcon = PrecacheAsset("ui/lifeformPopup/onosIcon.dds")
local kPresIcon = PrecacheAsset("ui/lifeformPopup/presIcon.dds")
local kRangedSupportIcon = PrecacheAsset("ui/lifeformPopup/rangedSupportIcon.dds")
local kSupportIconIcon = PrecacheAsset("ui/lifeformPopup/supportIcon.dds")

local kPresIconSize = Vector(59, 50, 0)

-- Offset from anchor point on right edge of screen, to upper-left corner of the graphic.
-- Given in mockup-pixels (mockup done @ 2880x1620)
local kFadeGraphicOffset = Vector(-289, -126, 0)
local kFadeGraphicSize = Vector(261, 254, 0)

local kGorgeGraphicOffset = Vector(-295, -117, 0)
local kGorgeGraphicSize = Vector(277, 215, 0)

local kLerkGraphicOffset = Vector(-354, -126, 0)
local kLerkGraphicSize = Vector(466, 257, 0)

local kOnosGraphicOffset = Vector(-317, -224, 0)
local kOnosGraphicSize = Vector(296, 370, 0)

local kSmokeGraphicOffset = Vector(-526, -234, 0)
local kSmokeGraphicSize = Vector(600, 738, 0)

local kLifeformNameRightEdge = Vector(-29, 37, 0)
local kLargeFontSize = 40
local kSmallFontSize = 40

local kTitleFontColor = HexToColor("ffcc01")
local kLifeformFontColor = HexToColor("dc7c1d")
local kPresCostFontColor = kTitleFontColor
local kRoleFontColor = kLifeformFontColor

local kTitleTextOffset = Vector(-7, -145, 0)
local kLifeformNameOffset = Vector(-29, 37, 0)
local kLifeformCostTextOffset = Vector(-29, 78, 0)
local kRoleTextOffset = Vector(-28, 106, 0)

local kSmokeyShader = "shaders/GUISmoke.surface_shader"
local kSmokeyAlpha = PrecacheAsset("ui/lifeformPopup/smokeyAlpha.dds")
local kSmokeyNoise = PrecacheAsset("ui/alien_commander_bg_smoke.dds")

local kPresIconOffset = Vector(0, 0, 0)
local kRoleIconOffset = Vector(-10, 0, 0)

local kLifeformData =
{
    Fade =
    {
        texture = kFadeIcon,
        size = kFadeGraphicSize,
        offset = kFadeGraphicOffset,
        
        cost = kFadeCost,
        roleDesc = "LIFEFORM_POPUP_ROLE_ASSASSIN",
        roleIcon = kAssassinIcon,
        roleIconSize = Vector(36, 33, 0),
    },
    
    Gorge =
    {
        texture = kGorgeIcon,
        size = kGorgeGraphicSize,
        offset = kGorgeGraphicOffset,
        
        cost = kGorgeCost,
        roleDesc = "LIFEFORM_POPUP_ROLE_SUPPORT",
        roleIcon = kSupportIconIcon,
        roleIconSize = Vector(37, 38, 0),
    },
    
    Lerk =
    {
        texture = kLerkIcon,
        size = kLerkGraphicSize,
        offset = kLerkGraphicOffset,
        
        cost = kLerkCost,
        roleDesc = "LIFEFORM_POPUP_ROLE_RANGED_SUPPORT",
        roleIcon = kRangedSupportIcon,
        roleIconSize = Vector(39, 41, 0),
    },
    
    Onos =
    {
        texture = kOnosIcon,
        size = kOnosGraphicSize,
        offset = kOnosGraphicOffset,
        
        cost = kOnosCost,
        roleDesc = "LIFEFORM_POPUP_ROLE_BRUISER",
        roleIcon = kBruiserIcon,
        roleIconSize = Vector(57, 36, 0),
    },
}

local kLifeformPriorities = { "Onos", "Fade", "Lerk", "Gorge" }

local kPopupYOffset = -550

local function UpdateFonts(self)
    
    -- Update the font files chosen.
    self.titleText:SetFontAndSize("kAgencyFBBold", kLargeFontSize * self.scale)
    self.lifeformNameText:SetFontAndSize("kAgencyFBBold", kLargeFontSize * self.scale)
    self.lifeformCostText:SetFontAndSize("kAgencyFBBold", kLargeFontSize * self.scale)
    
    self.roleText:SetFontAndSize("kAgencyFB", kSmallFontSize * self.scale)
    
end

local function UpdateScalingAndPosition(self)
    
    -- Update fonts first since we'll need to calculate text sizes.
    UpdateFonts(self)
    
    self.background:SetPosition(Vector(self.background:GetPosition().x, kPopupYOffset * self.scale, 0))
    
    self.smoke:SetPosition(kSmokeGraphicOffset * self.scale)
    self.smoke:SetSize(kSmokeGraphicSize * self.scale)
    
    local lifeformData = kLifeformData[self.currentLifeformName]
    assert(lifeformData)
    self.lifeformGraphic:SetSize(lifeformData.size * self.scale)
    self.lifeformGraphic:SetPosition(lifeformData.offset * self.scale)
    
    self.titleText:SetPosition(kTitleTextOffset * self.scale)
    
    self.lifeformNameText:SetPosition(kLifeformNameOffset * self.scale)
    self.lifeformCostText:SetPosition(kLifeformCostTextOffset * self.scale)
    
    local costTextWidth = self.lifeformCostText:GetTextWidth(self.lifeformCostText:GetText()) * self.lifeformCostText:GetScale().x / self.scale
    self.presIcon:SetSize(kPresIconSize * self.scale)
    self.presIcon:SetPosition(Vector(kPresIconOffset.x - kPresIconSize.x - costTextWidth + kLifeformCostTextOffset.x,
                                     -kPresIconSize.y * 0.5 + kLifeformCostTextOffset.y + kPresIconOffset.y,
                                     0) * self.scale)
    
    self.roleText:SetPosition(kRoleTextOffset * self.scale)
    
    local roleTextWidth = self.roleText:GetTextWidth(self.roleText:GetText()) * self.roleText:GetScale().x / self.scale
    local roleIconSize = lifeformData.roleIconSize
    self.roleIcon:SetSize(roleIconSize * self.scale)
    self.roleIcon:SetPosition(Vector(kRoleIconOffset.x - lifeformData.roleIconSize.x       - roleTextWidth + kRoleTextOffset.x,
                                     kRoleIconOffset.y - lifeformData.roleIconSize.y * 0.5                 + kRoleTextOffset.y,
                                     0) * self.scale)
    
end

local function SetCurrentLifeform(self, lifeformName)
    
    self.currentLifeformName = lifeformName
    
    -- Set the lifeform name, in caps.  Eg GORGE, LERK, but use translations too.
    local localeName = string.upper(lifeformName)
    self.lifeformNameText:SetText(string.upper(Locale.ResolveString(localeName)))
    
    local lifeformData = kLifeformData[self.currentLifeformName]
    assert(lifeformData)
    
    self.lifeformGraphic:SetTexture(lifeformData.texture)
    
    self.lifeformCostText:SetText(tostring(lifeformData.cost))
    
    self.roleIcon:SetTexture(lifeformData.roleIcon)
    self.roleText:SetText(Locale.ResolveString(lifeformData.roleDesc))
    
    UpdateScalingAndPosition(self)
    
end

local function SetUpdateInterval(self, interval)
    self.updateInterval = interval
end

function GUILifeformPopup:Initialize()
    
    -- Update fast rate initially (throttles itself automatically).
    SetUpdateInterval(self, kFastUpdateInterval)
    
    self.state = "hidden"
    self.lifeformCheckThrottle = 0
    self.flyInFraction = 0
    self.opacity = 0
    
    -- Set scale using our own values.
    self.scale = Client.GetScreenHeight() / kMockupSize.y
    
    -- Create an invisible object to hold everything.
    self.background = GetGUIManager():CreateGraphicItem()
    self.background:SetColor(Color(1, 1, 1, 0))
    self.background:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.background:SetIsVisible(not HelpScreen_GetHelpScreen():GetIsBeingDisplayed())
    
    -- Create a smokey graphic for the background.
    self.smoke = GetGUIManager():CreateGraphicItem()
    self.background:AddChild(self.smoke)
    self.smoke:SetShader(kSmokeyShader)
    self.smoke:SetTexture(kSmokeyAlpha)
    self.smoke:SetAdditionalTexture("noise", kSmokeyNoise)
    self.smoke:SetFloatParameter("correctionX", 3)
    self.smoke:SetFloatParameter("correctionY", 3)
    self.smoke:SetInheritsParentAlpha(true)
    
    -- Create graphic for lifeform.
    self.lifeformGraphic = GetGUIManager():CreateGraphicItem()
    self.lifeformGraphic:SetInheritsParentAlpha(true)
    self.background:AddChild(self.lifeformGraphic)
    
    -- Create "EVOLUTION AVAILABLE" text.
    self.titleText = GetGUIManager():CreateTextItem()
    self.background:AddChild(self.titleText)
    self.titleText:SetText(Locale.ResolveString("LIFEFORM_POPUP_EVOLUTION_AVAILABLE"))
    self.titleText:SetTextAlignmentX(GUIItem.Align_Max) -- right align
    self.titleText:SetTextAlignmentY(GUIItem.Align_Center) -- center text vertically
    self.titleText:SetColor(kTitleFontColor)
    self.titleText:SetInheritsParentAlpha(true)
    
    -- Create lifeform name text.
    self.lifeformNameText = GetGUIManager():CreateTextItem()
    self.background:AddChild(self.lifeformNameText)
    self.lifeformNameText:SetTextAlignmentX(GUIItem.Align_Max) -- right align
    self.lifeformNameText:SetTextAlignmentY(GUIItem.Align_Center) -- center text vertically
    self.lifeformNameText:SetColor(kLifeformFontColor)
    self.lifeformNameText:SetInheritsParentAlpha(true)
    
    -- Create pres cost counter.
    self.lifeformCostText = GetGUIManager():CreateTextItem()
    self.background:AddChild(self.lifeformCostText)
    self.lifeformCostText:SetTextAlignmentX(GUIItem.Align_Max) -- right align
    self.lifeformCostText:SetTextAlignmentY(GUIItem.Align_Center) -- center text vertically
    self.lifeformCostText:SetColor(kPresCostFontColor)
    self.lifeformCostText:SetInheritsParentAlpha(true)
    
    -- Create pres icon graphic.
    self.presIcon = GetGUIManager():CreateGraphicItem()
    self.background:AddChild(self.presIcon)
    self.presIcon:SetTexture(kPresIcon)
    self.presIcon:SetInheritsParentAlpha(true)
    
    -- Create lifeform role text.
    self.roleText = GetGUIManager():CreateTextItem()
    self.background:AddChild(self.roleText)
    self.roleText:SetTextAlignmentX(GUIItem.Align_Max) -- right align
    self.roleText:SetTextAlignmentY(GUIItem.Align_Center) -- center text vertically
    self.roleText:SetColor(kRoleFontColor)
    self.roleText:SetInheritsParentAlpha(true)
    
    -- Create role icon graphic.
    self.roleIcon = GetGUIManager():CreateGraphicItem()
    self.roleIcon:SetInheritsParentAlpha(true)
    self.background:AddChild(self.roleIcon)
    
    SetCurrentLifeform(self, "Gorge") -- default to gorgie
    UpdateScalingAndPosition(self) -- also updates fonts
    
end

function GUILifeformPopup:SetIsVisible(state)
    self.background:SetIsVisible(state)
end

function GUILifeformPopup:GetIsVisible(state)
    return self.background:GetIsVisible()
end

function GUILifeformPopup:OnResolutionChanged(oldX, oldY, newX, newY)

    self.scale = newY / kMockupSize.y
    UpdateScalingAndPosition(self)
    
end

function GUILifeformPopup:Uninitialize()
    
    GUI.DestroyItem(self.background) -- destroys child items as well.
    
end

local kPlayerStatusToLifeform =
{
    [kPlayerStatus.Skulk]     = "Skulk",
    [kPlayerStatus.SkulkEgg]  = "Skulk",
    [kPlayerStatus.Gorge]     = "Gorge",
    [kPlayerStatus.GorgeEgg]  = "Gorge",
    [kPlayerStatus.Lerk]      = "Lerk",
    [kPlayerStatus.LerkEgg]   = "Lerk",
    [kPlayerStatus.Fade]      = "Fade",
    [kPlayerStatus.FadeEgg]   = "Fade",
    [kPlayerStatus.Onos]      = "Onos",
    [kPlayerStatus.OnosEgg]   = "Onos",
}

local function GetAlienTeamComposition()
    
    local playerInfoEnts = EntityListToTable(Shared.GetEntitiesWithClassname("PlayerInfoEntity"))
    local playerCount = 0
    local lifeformCounts = {total=0}
    
    for i=1, #playerInfoEnts do
        
        local playerInfo = playerInfoEnts[i]
        local status = playerInfo.status
        local lifeformName = kPlayerStatusToLifeform[status]
        
        if playerInfo.teamNumber == 2 then
            
            lifeformCounts.total = lifeformCounts.total + 1
            
            if lifeformName and playerInfo.teamNumber == 2 then
                lifeformCounts[lifeformName] = (lifeformCounts[lifeformName] or 0) + 1
            end
            
        end
        
    end
    
    return lifeformCounts
    
end

local function GetLifeformLimit(numPlayersOnTeam)
    
    -- Assume commander isn't going to evolve.
    local numGroundPlayers = math.max(1, numPlayersOnTeam - 1)
    
    return math.ceil(numGroundPlayers * kPlayerLifeformLimitFraction)
end

-- Returns the name of the highest lifeform the player _should_ evolve to, if they wish.  In order
-- for a lifeform to be picked, it must satisfy the following:
--      - Lifeform must be higher than the player's current lifeform.
--      - Player must be able to afford the upgrade.
--      - The number of lifeforms of this type on the team must be less than 30% of the team size,
--          round up.
-- Returns nil if no lifeforms satisfy the above criteria.
local function GetBestLifeformToDisplay(self)
    
    local player = Client.GetLocalPlayer()
    if not player then
        return nil -- player didn't exist for whatever reason (happens briefly sometimes).
    end
    
    local pres = PlayerUI_GetPlayerResources()
    local teamComposition = GetAlienTeamComposition()
    local lifeformLimit = GetLifeformLimit(teamComposition.total)
    
    -- Lua doesn't have a "continue" statement in loops, which is a real shame as it helps cut
    -- down on a lot of needless "if pyramids".  The following is a cheesey hack to simulate the
    -- desired behavior.  Just have two nested while loops with the same condition, and when you
    -- "break" out of the inner one, it simply falls through to the outer loop which contains the
    -- loop increment statement, after which it simply re-enters the inner loop.
    
    local i=1
    while i <= #kLifeformPriorities do
    while i <= #kLifeformPriorities do
        
        local lifeformName = kLifeformPriorities[i]
        local lifeformData = kLifeformData[lifeformName]
        assert(lifeformData)
        
        -- Ensure player can afford this lifeform.
        if lifeformData.cost > pres then
            break -- CONTINUE
        end
        
        -- Ensure X% of the team's players aren't already this lifeform.
        if (teamComposition[lifeformName] or 0) >= lifeformLimit then
            break -- CONTINUE
        end
        
        return lifeformName
        
    end
        i = i + 1
    end
    
    return nil
    
end

-- Returns the name of a new lifeform that can/should now be presented to the player.  Returns nil
-- if none was found.
local function GetLifeformToPresent(self)
    
    local player = Client.GetLocalPlayer()
    if not player then
        return
    end
    
    -- Don't show it while the player is dead.  Also, keep track of when the player dies, to ensure
    -- we only display the popup once per life.
    if player.GetIsAlive and not player:GetIsAlive() then
        self.shownThisLife = nil
        return
    end
    
    -- Don't show the popup more than once per life.
    if self.shownThisLife then
        return
    end
    
    -- Do not display if hud mode is not full.
    if Client.GetOptionInteger("hudmode", kHUDMode.Full) ~= kHUDMode.Full then
        return
    end
    
    -- Only display during the game.
    if not GetGameInfoEntity():GetGameStarted() then
        return
    end
    
    -- Do not display if round has not been going at least 30 seconds.  We don't want every alien
    -- player being told to gorge all at once!
    if PlayerUI_GetGameLengthTime() < kMinimumRoundTime then
        return
    end
    
    -- Do not display if player has buy menu open.
    if PlayerUI_GetBuyMenuDisplaying() then
        return
    end
    
    -- Don't display if client is spectating (we don't care if the person we're spectating should
    -- evolve... :P)
    if not Client.GetIsControllingPlayer() then
        return
    end
    
    -- Only display to un-evolved players.  We don't want to be telling players to evolve
    -- gorge --> lerk for example -- each lifeform has a role, shouldn't just pile onto the highest
    -- one you can afford.
    if not player:isa("Skulk") then
        return
    end
    
    -- Do not bother player while they are in combat.
    if player.GetIsInCombat and player:GetIsInCombat() then
        return
    end
    
    -- Don't present to the player if it's been longer than X seconds since they spawned.
    if player.creationTime and player.creationTime < Shared.GetTime() - kMaxTimeAfterSpawn then
        return
    end
    
    -- Don't present to the player until they've been spawned for at least X seconds (otherwise
    -- it's a lot of chaos, hard for the popup to stand out).
    if player.creationTime and player.creationTime > Shared.GetTime() - kMinTimeAfterSpawn then
        return
    end
    
    local bestLifeform = GetBestLifeformToDisplay(self)
    if not bestLifeform then
        -- Couldn't find a suitable lifeform.
        return
    end
    
    return bestLifeform
    
end

-- Returns true if it is okay for the currently displayed lifeform to remain displayed, false if it
-- should be hidden prematurely.
local function CheckVisibilityConditions(self)
    
    -- Do not display if hud mode is not full.
    if Client.GetOptionInteger("hudmode", kHUDMode.Full) ~= kHUDMode.Full then
        return false
    end
    
    -- Only display during the game.
    if not GetGameInfoEntity():GetGameStarted() then
        return false
    end
    
    -- Do not display if player has buy menu open.
    if PlayerUI_GetBuyMenuDisplaying() then
        return false
    end
    
    -- Don't display if client is spectating (we don't care if the person we're spectating should
    -- evolve... :P)
    if not Client.GetIsControllingPlayer() then
        return false
    end
    
    local player = Client.GetLocalPlayer()
    if not player then
        return false
    end
    
    -- Only display to un-evolved players.  We don't want to be telling players to evolve
    -- gorge --> lerk for example -- each lifeform has a role, shouldn't just pile onto the highest
    -- one you can afford.
    if not player:isa("Skulk") then
        return false
    end
    
    -- Do not bother player while they are in combat.
    if player.GetIsInCombat and player:GetIsInCombat() then
        return false
    end
    
    -- Don't show it while the player is dead.
    if player.GetIsAlive and not player:GetIsAlive() then
        return false
    end
    
    -- Ensure the player can still afford whatever lifeform is being displayed.
    local lifeformData = kLifeformData[self.currentLifeformName]
    assert(lifeformData)
    if PlayerUI_GetPlayerResources() < lifeformData.cost then
        return false
    end
    
    -- Ensure there is still a need -- player-count-wise -- for this lifeform on the team.
    local teamComposition = GetAlienTeamComposition()
    local lifeformLimit = GetLifeformLimit(teamComposition.total)
    if (teamComposition[self.currentLifeformName] or 0) >= lifeformLimit then
        return false
    end
    
    return true
    
end

-- Sets the lifeform, and begins the animation for presenting the lifeform suggestion.
local function PresentLifeform(self, lifeformName)
    
    self.shownThisLife = true
    self.state = "presenting"
    self.flyInFraction = 0.0
    self.presentTime = 0.0
    SetCurrentLifeform(self, lifeformName)
    SetUpdateInterval(self, kFastUpdateInterval) -- update fast for the animations.
    StartSoundEffect(kPopupSound)
    
end

local function StopPresenting(self)
    
    self.state = "hidden"
    SetUpdateInterval(self, kFastUpdateInterval) -- update fast for the animations.
    
end

local function UpdateFlyInAnimation(self, deltaTime)
    
    if self.flyInFraction < 1 then
        self.flyInFraction = Clamp(self.flyInFraction + (deltaTime / kAnimateInDuration), 0, 1)
        local t = math.sin(Clamp(self.flyInFraction, 0, 1) * math.pi * 0.5)
        self.background:SetPosition(Vector((1.0-t) * kFlyInXOffset, self.background:GetPosition().y, 0))
        return self.flyInFraction < 1 -- "keep animating if..."
    else
        return false
    end
    
end

local function UpdateFadeOutAnimation(self, goal, deltaTime)
    
    if goal == 1 and self.opacity ~= 1 then
        self.opacity = 1
    elseif goal == 0 and self.opacity > 0 then
        self.opacity = Clamp(self.opacity - (deltaTime / kAnimateOutDuration), 0, 1)
    else
        return false
    end
    
    self.background:SetColor(Color(1, 1, 1, self.opacity))
    return true
    
end

local function UpdateHiddenState(self, deltaTime)
    
    local flyInDone = not UpdateFlyInAnimation(self, deltaTime)
    local fadeInDone = not UpdateFadeOutAnimation(self, 0, deltaTime)
    if flyInDone and fadeInDone then
        -- If the animations are done, throttle it down again.
        SetUpdateInterval(self, kSlowUpdateInterval)
    end
    
    -- Check to see if we can/should present a new lifeform.  Kind of expensive, so throttle this.
    self.lifeformCheckThrottle = self.lifeformCheckThrottle - deltaTime
    if self.lifeformCheckThrottle <= 0 then
        self.lifeformCheckThrottle = self.lifeformCheckThrottle % kSlowUpdateInterval
        local lifeformName = GetLifeformToPresent(self)
        if lifeformName then
            PresentLifeform(self, lifeformName)
        end
    end
    
end

local function UpdatePresentingState(self, deltaTime)
    
    local flyInDone = not UpdateFlyInAnimation(self, deltaTime)
    local fadeInDone = not UpdateFadeOutAnimation(self, 1, deltaTime)
    if flyInDone and fadeInDone then
        -- If the animations are done, throttle it down again.
        SetUpdateInterval(self, kSlowUpdateInterval)
    end
    
    self.presentTime = self.presentTime + deltaTime
    
    if not CheckVisibilityConditions(self) or self.presentTime >= kHoldDuration then
        StopPresenting(self)
    end
    
end

local kStateUpdateFuncs =
{
    hidden = UpdateHiddenState,
    presenting = UpdatePresentingState,
}

function GUILifeformPopup:Update(deltaTime)
    
    local state = self.state
    local updateFunc = kStateUpdateFuncs[state]
    assert(updateFunc)
    
    updateFunc(self, deltaTime)
    
end
