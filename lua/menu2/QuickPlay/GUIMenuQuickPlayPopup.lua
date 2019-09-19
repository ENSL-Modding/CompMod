-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/QuickPlay/GUIMenuQuickPlayPopup.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Window that pops up and runs QuickPlay logic.
--
--  Parameters (* = required)
--      gameMode        Game mode to use, if other than "ns2".  Used for special occasions (eg to
--                      play infested marines on halloween).
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/popup/GUIMenuPopupSimpleMessage.lua")

---@class GUIMenuQuickPlayPopup : GUIMenuPopupSimpleMessage
local baseClass = GUIMenuPopupSimpleMessage
class "GUIMenuQuickPlayPopup" (baseClass)

local kQuickPlayParams =
{
    buttonConfig = { GUIMenuPopupDialog.CancelButton, },
}

local kMaxDots = 4
local kRecentConnectTime = 600 -- 10 minutes is considered recently connected to.

local quickPlayPopup = nil
function GetQuickPlayPopup()
    return quickPlayPopup
end

local function StopUpdateLoops(self)
    
    if self.mainUpdateCallback then
        self:RemoveTimedCallback(self.mainUpdateCallback)
        self.mainUpdateCallback = nil
    end
    
    if self.dotsUpdateCallback then
        self:RemoveTimedCallback(self.dotsUpdateCallback)
        self.dotsUpdateCallback = nil
    end
    
end

local function UpdateMessageText(self)
    
    local dots = string.rep(".", self.dotCount)
    
    -- Print nothing for the first line if it's our first attempt, otherwise, say we failed, and
    -- this is attempt X.
    local message
    if self.attempts > 1 then
        local attemptsString
        if self.attempts <= 9 then
            attemptsString = tostring(self.attempts)
        else
            attemptsString = "9+"
        end
        message = StringReformat(Locale.ResolveString("QUICK_PLAY_STATUS_FAILED_RETRYING"), {attempts = attemptsString}).."\n"
    else
        message = "" -- no newline, so the status appears on the first line.
    end
    
    -- Print what we're doing on this attempt on the next line.
    if self.status == "refreshing" then
        message = message..Locale.ResolveString("QUICK_PLAY_STATUS_REFRESHING")..dots
    elseif self.status == "checking" then
        message = message..StringReformat(Locale.ResolveString("QUICK_PLAY_STATUS_CHECKING"), {count = #self.eligibleServers})..dots
    elseif self.status == "joining" then
        message = message..StringReformat(Locale.ResolveString("QUICK_PLAY_STATUS_JOINING"), {serverName = self.joiningServerName})..dots
    end
    
    self:SetMessage(message)
    
end

local function UpdateNumberOfDots(self)
    self.dotCount = (self.dotCount % kMaxDots) + 1
    UpdateMessageText(self)
end

-- Returns 2 if server is eligible to be joined, 1 if the server is eligible to be joined but was
-- already attempted recently, and 0 if server is ineligible for quickplay.
local function GetServerEligibility(self, serverEntry)
    
    if serverEntry:GetBlocked()                     then return 0 end -- Skip blocked
    if not serverEntry:GetExists()                  then return 0 end -- Skip pure-history
    if serverEntry:GetGameMode() ~= self.gameMode   then return 0 end -- Skip wrong game mode
    if not serverEntry:GetQuickPlayReady()          then return 0 end -- Skip opted-out
    if serverEntry:GetPassworded()                  then return 0 end -- Skip passworded
    
    -- Skip full
    if serverEntry:GetPlayerCount() >= (serverEntry:GetPlayerMax() - serverEntry:GetReservedSlotCount()) then
        return 0
    end
    
    -- Don't put non-rookies on rookie-only servers.
    local localPlayerData = GetLocalPlayerProfileData()
    assert(localPlayerData)
    local clientIsRookie = localPlayerData:GetIsRookie()
    if serverEntry:GetRookieOnly() and not clientIsRookie then
        return 0
    end
    
    -- Prefer not to connect to servers that we already attempted to connect to recently.
    local now = Shared.GetSystemTime()
    if serverEntry:GetHistorical() and now - serverEntry:GetLastConnect() <= kRecentConnectTime then
        return 1
    end
    
    return 2
    
end

local function EligibleServerSort(a, b)
    return a:GetRanking() > b:GetRanking()
end

local function OnRefreshFinished(self)
    
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    self:UnHookEvent(serverBrowser, "OnRefreshFinished", OnRefreshFinished)
    
    local preferredServerEntries = {}
    local backupServerEntries = {}
    local serverSet = serverBrowser:GetServerSet()
    for address, serverEntry in pairs(serverSet) do -- JIT-SAFE pairs! (IterableDict)
    
        local eligibility = GetServerEligibility(self, serverEntry)
        if eligibility == 2 then
            table.insert(preferredServerEntries, serverEntry)
        elseif eligibility == 1 then
            table.insert(backupServerEntries, serverEntry)
        end
    
    end
    
    self.eligibleServers = nil
    if #preferredServerEntries > 0 then
        self.eligibleServers = preferredServerEntries
    elseif #backupServerEntries > 0 then
        self.eligibleServers = backupServerEntries
    end
    
    -- If no eligible servers were found, try searching again.
    if not self.eligibleServers then
        -- No eligible servers found!
        self.status = "init"
        self.attempts = self.attempts + 1
        return
    end
    
    -- Sort the servers.
    table.sort(self.eligibleServers, EligibleServerSort)
    
    self.status = "checking"
    self.currentIndex = 1
    
end

local function ConfirmServer()
    
    local self = GetQuickPlayPopup()
    if not self then
        return
    end
    
    local entry = self.confirmingServer
    self.confirmingServer = nil
    if not entry then
        return
    end
    
    local eligibility = GetServerEligibility(self, entry)
    if eligibility > 0 then
    
        -- Give player achievement for using QuickPlay.
        Client.SetAchievement("First_0_2")
        
        -- Join Server.
        self.status = "joining"
        self.joiningServerName = entry:GetServerName()
        
        JoinServer(entry:GetAddress())
    
    end
    
end

local function AttemptToJoinServer(self, entry)
    
    if not self.confirmingServer then
        
        if entry then
            
            self.confirmingServer = entry
            Client.RefreshServer(entry:GetIndex(), ConfirmServer)
            
        end
        
        self.currentIndex = self.currentIndex + 1
        
    end

end

local function UpdateQuickPlayPopup(self)
    
    if self.status == "init" then
    
        -- Popup was just created.  Get the server browser refreshing... should be available.
        local serverBrowser = GetServerBrowser and GetServerBrowser()
        if not serverBrowser then
            self.status = "noServerBrowser"
            StopUpdateLoops(self)
        end
        self.status = "refreshing"
        self:HookEvent(serverBrowser, "OnRefreshFinished", OnRefreshFinished)
        serverBrowser:RefreshServerList()
    
        UpdateMessageText(self)
    
    elseif self.status == "checking" then
    
        -- Restart the whole process if we didn't have any eligible servers, or we exhausted the
        -- list.
        if not self.confirmingServer and (not self.eligibleServers or self.currentIndex > #self.eligibleServers) then
            self.status = "init"
            self.attempts = self.attempts + 1
        else
            AttemptToJoinServer(self, self.eligibleServers[self.currentIndex])
        end
    
        UpdateMessageText(self)
    
    end
    
end

local function OnDestroy(self)
    if quickPlayPopup == self then
        quickPlayPopup = nil
    end
end

function GUIMenuQuickPlayPopup:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    assert(not quickPlayPopup)
    quickPlayPopup = self
    
    RequireType({"string", "nil"}, params.gameMode, "params.gameMode", errorDepth)
    
    baseClass.Initialize(self, kQuickPlayParams, errorDepth)
    
    self:HookEvent(self, "OnDestroy", OnDestroy)
    
    self.gameMode = params.gameMode or "ns2"
    
    self:SetTitle(Locale.ResolveString("PLAY_MENU_QUICK_PLAY"))
    
    -- Start update loop so the dots count out to show that it's working (. .. ... .... . .. ...)
    self.dotCount = 1
    self.dotsUpdateCallback = self:AddTimedCallback(UpdateNumberOfDots, 0.5, true)
    
    -- Start main update loop.
    self.status = "init"
    self.attempts = 1
    self.mainUpdateCallback = self:AddTimedCallback(UpdateQuickPlayPopup, 0, true)
    
end

