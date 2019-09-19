-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/PlayerScreen/FriendsList/GUIMenuFriendsListEntry.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A single entry for a single friend for the GUIMenuFriendsList.
--
--  Parameters (* = required)
--     *friendName
--     *steamId64
--     *friendState
--     *serverAddress
--
--  Properties
--      FriendName      Name of the friend.
--      SteamID64       Steam id of the friend, in SteamID64 format (stored as a string).
--      FriendState     The steam friend state of this friend.  Can be any of the following:
--                          Client.FriendState_Offline
--                          Client.FriendState_Online
--                          Client.FriendState_Busy
--                          Client.FriendState_Away
--                          Client.FriendState_Snooze
--                          Client.FriendState_LookingTrade
--                          Client.FriendState_LookingPlay
--                          Client.FriendState_InGame
--      ServerAddress   The server address (IP:Port string) of the server the friend is playing on,
--                      or "" if they're not on a server.
--
--  Events
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")

Script.Load("lua/menu2/GUIMenuTruncatedText.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/PlayerScreen/FriendsList/GUIMenuAvatar.lua")
Script.Load("lua/menu2/GUIMenuFlashGraphic.lua")

Script.Load("lua/menu2/popup/GUIMenuPopupSimpleMessage.lua")

---@class GUIMenuFriendsListEntry : GUIObject
---@field public GetExpanded function @From Expandable wrapper
---@field public SetExpanded function @From Expandable wrapper
---@field public GetExpansion function @From Expandable wrapper
local baseClass = GUIObject
baseClass = GetExpandableWrappedClass(baseClass)
class "GUIMenuFriendsListEntry" (baseClass)

assert(Client.FriendState_Offline) -- this should be loaded by now... otherwise lots of stuff stops working...

GUIMenuFriendsListEntry:AddCompositeClassProperty("FriendName", "playerName", "Text")
GUIMenuFriendsListEntry:AddCompositeClassProperty("SteamID64", "avatar")
GUIMenuFriendsListEntry:AddClassProperty("FriendState", Client.FriendState_Offline)
GUIMenuFriendsListEntry:AddClassProperty("ServerAddress", "")

local kHeight = 120

local kAvatarSize = 96

local kEdgePadding = (kHeight - kAvatarSize) * 0.5
local kSpacing = 18 -- space between elements within the entry (eg between avatar and text).
local kFont = ReadOnly{ family = "Microgramma", size = 26}

local kInGameColor  = HexToColor("ade247")
local kOnlineColor  = HexToColor("68bdda")
local kAwayColor    = HexToColor("3f6a7e")
local kOfflineColor = HexToColor("7a7a7a")

local kButtonHeight = 64
local kJoinDimTexture = PrecacheAsset("ui/newMenu/join_friend_dim.dds")
local kJoinLitTexture = PrecacheAsset("ui/newMenu/join_friend_lit.dds")
local kInviteDimTexture = PrecacheAsset("ui/newMenu/invite_friend_dim.dds")
local kInviteLitTexture = PrecacheAsset("ui/newMenu/invite_friend_lit.dds")

-- Seconds between invites... steam doesn't throttle this at all, it would seem.
local kPlayerInviteCooldown = 5

local kFriendStateData =
{
    [Client.FriendState_Offline]        = {color = kOfflineColor, locale = Locale.ResolveString("FRIEND_STATE_OFFLINE"), },
    [Client.FriendState_Online]         = {color = kOnlineColor,  locale = Locale.ResolveString("FRIEND_STATE_ONLINE"), },
    [Client.FriendState_Busy]           = {color = kAwayColor,    locale = Locale.ResolveString("FRIEND_STATE_BUSY"), },
    [Client.FriendState_Away]           = {color = kAwayColor,    locale = Locale.ResolveString("FRIEND_STATE_AWAY"), },
    [Client.FriendState_Snooze]         = {color = kAwayColor,    locale = Locale.ResolveString("FRIEND_STATE_SNOOZE"), },
    [Client.FriendState_LookingTrade]   = {color = kOnlineColor,  locale = Locale.ResolveString("FRIEND_STATE_LOOKING_TRADE"), },
    [Client.FriendState_LookingPlay]    = {color = kOnlineColor,  locale = Locale.ResolveString("FRIEND_STATE_LOOKING_PLAY"), },
    [Client.FriendState_InGame]         = {color = kInGameColor,  locale = Locale.ResolveString("FRIEND_STATE_IN_GAME"), },
}

local function UpdateLayout(self)

    local width = self:GetSize().x
    width = width - kEdgePadding * 2
    width = width - kAvatarSize
    width = width - kSpacing
    
    local buttonOffset = -kEdgePadding
    if self.joinFriendButton:GetVisible() then
        width = width - kEdgePadding
        self.joinFriendButton:SetX(buttonOffset)
        local buttonWidth = self.joinFriendButton:GetSize().x * self.joinFriendButton:GetScale().x
        buttonWidth = buttonWidth + kSpacing
        buttonOffset = buttonOffset - buttonWidth
        width = width - buttonWidth
    end
    
    if self.inviteFriendButton:GetVisible() then
        self.inviteFriendButton:SetX(buttonOffset)
        local buttonWidth = self.inviteFriendButton:GetSize().x * self.joinFriendButton:GetScale().x
        buttonWidth = buttonWidth + kSpacing
        width = width - buttonWidth
    end
    
    -- Update the text holder sizes to use the remaining space.
    self.playerNameHolder:SetWidth(width)
    self.statusHolder:SetWidth(width)

end

local function UpdateFriendState(self)

    local friendState = self:GetFriendState()
    local serverAddress = self:GetServerAddress()
    
    -- See if we can figure out which server they're on.  If so, display that as their status
    -- instead of the more generic "In-Game".
    if friendState == Client.FriendState_InGame and serverAddress ~= "" then
        
        local serverBrowser = GetServerBrowser()
        assert(serverBrowser)
        local serverSet = serverBrowser:GetServerSet()
        assert(serverSet)
        local serverEntry = serverSet[serverAddress]
        if serverEntry then
        
            local serverName = serverEntry:GetServerName()
            local statusText = string.format(Locale.ResolveString("FRIEND_PLAYING_ON"), serverName)
            self.status:SetText(statusText)
            self.status:SetColor(kFriendStateData[Client.FriendState_InGame].color)
            return
        
        end
        
    end
    
    local friendStateData = kFriendStateData[friendState] or kFriendStateData[Client.FriendState_Offline]
    local stateLocale = friendStateData.locale
    local stateColor = friendStateData.color
    
    self.status:SetText(stateLocale)
    self.status:SetColor(stateColor)
    
end

local function InviteFriendCooldownFinished(self)
    self.inviteFriendButton:SetEnabled(true)
end

local function OnInviteFriendPressed(self)
    
    PlayMenuSound("ButtonClick")
    
    if not Client.GetIsConnected() then
        self.inviteFriendButton:SetVisible(false)
        Log("Attempted to invite player when not playing!  (Button should not have been visible!")
        return
    end
    
    local serverAddress = Client.GetConnectedServerAddress()
    local steamID64 = self:GetSteamID64()
    
    local connectString = string.format("+connect %s", serverAddress)
    Client.SendPlayerInvite(steamID64, connectString)
    
    -- Throttle invitation requests.  Too easy to spam, otherwise.
    self.inviteFriendButton:SetEnabled(false)
    self:AddTimedCallback(InviteFriendCooldownFinished, kPlayerInviteCooldown)
    
end

local joiningFriendEntry = nil
local function ClearJoiningFriendEntry(self)
    assert(joiningFriendEntry == self)
    joiningFriendEntry = nil
end

local function JoinFriendPostServerBrowserRefreshCallback(popup)
    
    popup:Close()
    
    -- Check if the entry still exists (possibly the friend went offline during the server
    -- browser refresh.
    local entry = joiningFriendEntry
    joiningFriendEntry = nil
    
    local address = ""
    if entry then
    
        entry:UnHookEvent(entry, "OnDestroy", ClearJoiningFriendEntry) -- cleanup destroy hook.
        
        -- Get the address again, since it may have changed since updating the server browser.
        address = entry:GetServerAddress()
    end
    
    -- If the address is invalid, cannot join friend.
    if address == "" then
        -- Inform the user that the friend they were attempting to join is no longer playing on any
        -- server.
        CreateGUIObject("popup", GUIMenuPopupSimpleMessage, nil,
        {
            title = Locale.ResolveString("FRIEND_JOINING_TITLE"),
            message = Locale.ResolveString("FRIEND_LEFT_SERVER"),
            buttonConfig = { GUIPopupDialog.OkayButton, },
        })
        return
    end
    
    local serverBrowser = GetServerBrowser()
    local serverEntry
    if serverBrowser then
        serverEntry = serverBrowser:GetServerEntryFromAddress(address)
    end
    
    if serverEntry then
        TryToJoinServer(address, nil)
    else
        -- Server entry for address wasn't found, even after refresh... just try to join.
        JoinServer(address, nil)
    end

end

local function OnJoinFriendPressed(self)
    
    PlayMenuSound("ButtonClick")
    
    local serverAddress = self:GetServerAddress()
    if serverAddress == "" then
        self.joinFriendButton:SetVisible(false)
        Log("Attempted to join player who wasn't connected to a server (Button should not have been visible!)")
        return
    end
    
    joiningFriendEntry = self
    -- Nil-out the above reference if the object is destroyed (we check for this).
    self:HookEvent(self, "OnDestroy", ClearJoiningFriendEntry)
    
    TryToJoinServer(serverAddress, nil, JoinFriendPostServerBrowserRefreshCallback)
    
end

local function GetIsOnSameServerTogether(self)
    
    if not Client.GetIsConnected() then
        return false -- Can't be on the same server together if we're not on a server!
    end
    
    local ourServerAddress = Client.GetConnectedServerAddress()
    local theirServerAddress = self:GetServerAddress()
    
    return ourServerAddress == theirServerAddress

end

local function UpdateInviteFriendButtonVisibility(self)
    
    if not Client.GetIsConnected() or GetIsOnSameServerTogether(self) then
        self.inviteFriendButton:SetVisible(false)
        return
    end
    
    local friendState = self:GetFriendState()
    if friendState == Client.FriendState_Offline then
        self.inviteFriendButton:SetVisible(false)
        return
    end
    
    self.inviteFriendButton:SetVisible(true)
    
end

local function UpdateJoinFriendButtonVisibility(self)
    
    if GetIsOnSameServerTogether(self) then
        self.joinFriendButton:SetVisible(false)
        return
    end
    
    local serverAddress = self:GetServerAddress()
    local friendState = self:GetFriendState()
    
    if serverAddress == "" or friendState == Client.FriendState_Offline then
        self.joinFriendButton:SetVisible(false)
        return
    end
    
    self.joinFriendButton:SetVisible(true)

end

function GUIMenuFriendsListEntry:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType("string", params.friendName, "params.friendName", errorDepth)
    RequireType("string", params.steamId64, "params.steamId64", errorDepth)
    RequireType("number", params.friendState, "params.friendState", errorDepth)
    if not kFriendStateData[params.friendState] then
        error(string.format("Invalid value of params.friendState.  Got %d.", params.friendState), errorDepth)
    end
    RequireType("string", params.serverAddress, "params.serverAddress", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.avatar = CreateGUIObject("avatar", GUIMenuAvatar, self)
    self.avatar:SetSize(kAvatarSize, kAvatarSize)
    self.avatar:AlignLeft()
    self.avatar:SetPosition(kEdgePadding, 0)
    
    self.playerNameHolder = CreateGUIObject("playerNameHolder", GUIMenuTruncatedText, self,
    {
        cls = GUIText,
        font = kFont,
        color = MenuStyle.kOptionHeadingColor,
        text = "",
    })
    self.playerName = self.playerNameHolder:GetObject()
    self.playerNameHolder:SetAnchor(0, 0.3333)
    self.playerNameHolder:SetHotSpot(0, 0.5)
    self.playerNameHolder:SetX(kEdgePadding + kAvatarSize + kSpacing)
    self.playerNameHolder:HookEvent(self.playerName, "OnSizeChanged", self.playerNameHolder.SetHeight)
    
    self.statusHolder = CreateGUIObject("statusHolder", GUIMenuTruncatedText, self,
    {
        cls = GUIText,
        font = kFont,
        color = MenuStyle.kOptionHeadingColor,
        text = "",
    })
    self.status = self.statusHolder:GetObject()
    self.statusHolder:SetAnchor(0, 0.6667)
    self.statusHolder:SetHotSpot(0, 0.5)
    self.statusHolder:SetX(kEdgePadding + kAvatarSize + kSpacing)
    self.statusHolder:HookEvent(self.status, "OnSizeChanged", self.playerNameHolder.SetHeight)
    
    local buttonClass = GUIMenuFriendsListEntryInviteFriendButton
    if not buttonClass then
        local cls = GUIMenuFlashGraphic
        cls = GetCursorInteractableWrappedClass(cls)
        cls = GetTooltipWrappedClass(cls)
        class "GUIMenuFriendsListEntryInviteFriendButton" (cls)
        GUIMenuFriendsListEntryInviteFriendButton:AddClassProperty("Enabled", true)
        buttonClass = GUIMenuFriendsListEntryInviteFriendButton
    end
    
    self.inviteFriendButton = CreateGUIObject("inviteFriendButton", buttonClass, self,
    {
        defaultTexture = kInviteDimTexture,
        hoverTexture = kInviteLitTexture,
        tooltip = Locale.ResolveString("FRIEND_INVITE_TT"),
    })
    local inviteScaleFactor = kButtonHeight / self.inviteFriendButton:GetSize().y
    self.inviteFriendButton:SetScale(inviteScaleFactor, inviteScaleFactor)
    self.inviteFriendButton:AlignRight()
    self:HookEvent(self.inviteFriendButton, "OnPressed", OnInviteFriendPressed)
    self:HookEvent(self, "OnServerAddressChanged", UpdateInviteFriendButtonVisibility)
    self:HookEvent(self, "OnFriendStateChanged", UpdateInviteFriendButtonVisibility)
    self:HookEvent(self.inviteFriendButton, "OnSizeChanged", UpdateLayout)
    self:HookEvent(self.inviteFriendButton, "OnScaleChanged", UpdateLayout)
    self:HookEvent(self.inviteFriendButton, "OnVisibleChanged", UpdateLayout)
    
    self.joinFriendButton = CreateGUIObject("joinFriendButton", buttonClass, self,
    {
        defaultTexture = kJoinDimTexture,
        hoverTexture = kJoinLitTexture,
        tooltip = Locale.ResolveString("FRIEND_JOIN_TT"),
    })
    local joinScaleFactor = kButtonHeight / self.joinFriendButton:GetSize().y
    self.joinFriendButton:SetScale(joinScaleFactor, joinScaleFactor)
    self.joinFriendButton:AlignRight()
    self:HookEvent(self.joinFriendButton, "OnPressed", OnJoinFriendPressed)
    self:HookEvent(self, "OnServerAddressChanged", UpdateJoinFriendButtonVisibility)
    self:HookEvent(self, "OnFriendStateChanged", UpdateJoinFriendButtonVisibility)
    self:HookEvent(self.joinFriendButton, "OnSizeChanged", UpdateLayout)
    self:HookEvent(self.joinFriendButton, "OnScaleChanged", UpdateLayout)
    self:HookEvent(self.joinFriendButton, "OnVisibleChanged", UpdateLayout)
    
    self:HookEvent(self, "OnSizeChanged", UpdateLayout)
    UpdateLayout(self)
    
    self:HookEvent(self, "OnFriendStateChanged", UpdateFriendState)
    self:HookEvent(self, "OnServerAddressChanged", UpdateFriendState)
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    self:HookEvent(serverBrowser, "OnServerSetChanged", UpdateFriendState)
    UpdateFriendState(self)
    
    self:SetFriendName(params.friendName)
    self:SetSteamID64(params.steamId64)
    self:SetFriendState(params.friendState)
    self:SetServerAddress(params.serverAddress)
    
    self:SetHeight(kHeight)
    
    UpdateJoinFriendButtonVisibility(self)
    UpdateInviteFriendButtonVisibility(self)
    
end
