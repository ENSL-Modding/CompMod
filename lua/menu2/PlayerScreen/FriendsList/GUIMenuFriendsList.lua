-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/PlayerScreen/FriendsList/GUIMenuFriendsList.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Widget that displays a list of friends of the player.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIText.lua")

Script.Load("lua/menu2/PlayerScreen/FriendsList/GUIMenuFriendsListEntry.lua")
Script.Load("lua/menu2/PlayerScreen/FriendsList/GUIMenuFriendsListSearchBox.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/widgets/GUIMenuScrollPane.lua")
Script.Load("lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModEntryLayout.lua")

---@class GUIMenuFriendsList : GUIObject
local baseClass = GUIObject
class "GUIMenuFriendsList" (baseClass)

local kVerticalSpacing = 8 -- vertical spacing between label, searchBox, and listBox.
local kPadding = 12 -- padding around edges of items.

local kLabelFont = ReadOnly{family = "Microgramma", size = 28}
local kLabelColor = HexToColor("e3fcff")

local kSearchBoxHeight = 73

local kMinListHeight = 32

-- Refresh friends list every 15 seconds.
local kFriendsListRefreshInterval = 15

local function UpdateLayout(self)
    
    local currentY = 0
    
    currentY = currentY + self.label:GetSize().y
    currentY = currentY + kVerticalSpacing
    
    self.searchBox:SetY(currentY)
    
    currentY = currentY + kSearchBoxHeight
    currentY = currentY + kVerticalSpacing
    
    self.searchBox:SetHeight(currentY - self.searchBox:GetPosition().y)
    self.listBox:SetY(currentY)
    
    local listHeight = self:GetSize().y - currentY
    listHeight = math.max(listHeight, kMinListHeight)
    self.listBox:SetHeight(listHeight)

end

local function UpdateSearchFilter(self)

    PROFILE("GUIMenuFriendsList_UpdateSearchFilter")
    
    local filterText = self.searchBox:GetValue()
    if filterText == "" then
        
        -- Skip filtering step if text is empty.
        for steamId64, entry in pairs(self.friendEntries) do -- JIT-SAFE pairs!  (OrderedIterableDict)
            entry:SetExpanded(true)
        end
    
    else
    
        for steamId64, entry in pairs(self.friendEntries) do -- JIT-SAFE pairs!  (OrderedIterableDict)
            local friendName = entry:GetFriendName()
            local expanded = SubStringInString(filterText, friendName)
            entry:SetExpanded(expanded)
        end
    
    end

end

local function RefreshFriendsList(self)
    Client.TriggerFriendsListUpdate()
end

local function OnSteamFriendsUpdated(self, friendsTbl)
    
    PROFILE("GUIMenuFriendsList_OnSteamFriendsUpdated")
    
    -- Update the friends objects, creating new ones if we don't have enough.
    local oldFriendEntries = self.friendEntries
    self.friendEntries = OrderedIterableDict()
    for i=1, #friendsTbl do
        
        local tableEntry = friendsTbl[i]
        
        local friendName = tableEntry[1]
        local steamId64 = tableEntry[2]
        local friendState = tableEntry[3]
        local serverAddress = tableEntry[4]
        
        local entryObj = oldFriendEntries[steamId64]
        if entryObj == nil then
            -- Entry for this friend not found, create a new one.
            local objName = "friendEntry"..tostring(#self.friendEntries + 1)
            entryObj = CreateGUIObject(objName, GUIMenuFriendsListEntry, self.listLayout,
            {
                friendName    = friendName,
                steamId64     = steamId64,
                friendState   = friendState,
                serverAddress = serverAddress,
            })
            entryObj:HookEvent(self.listLayout, "OnSizeChanged", entryObj.SetWidth)
        else
            -- Entry exists.  Update the existing data.
            entryObj:SetFriendName(friendName)
            entryObj:SetFriendState(friendState)
            entryObj:SetServerAddress(serverAddress)
        end
        
        entryObj:SetLayer(i) -- ensure they display in this order in the layout.
        
        self.friendEntries[steamId64] = entryObj
        oldFriendEntries[steamId64] = nil
    
    end
    
    -- Destroy old friend entries.
    for _, entry in pairs(oldFriendEntries) do -- JIT-SAFE pairs (OrderedIterableDict)
        entry:Destroy()
    end
    
    UpdateSearchFilter(self)

end

function GUIMenuFriendsList:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    -- Mapping of SteamID64 --> friend entry.  Order of elements will match the order of the entries
    -- in the last "OnSteamFriendsUpdated" event.
    self.friendEntries = OrderedIterableDict()
    
    self.label = CreateGUIObject("label", GUIText, self,
    {
        font = kLabelFont,
        text = string.upper(Locale.ResolveString("FRIENDS"))..":",
        color = kLabelColor,
    })
    self:HookEvent(self.label, "OnSizeChanged", UpdateLayout)
    
    self.searchBox = CreateGUIObject("searchBox", GUIMenuFriendsListSearchBox, self)
    self.searchBox:SetHeight(kSearchBoxHeight)
    self.searchBox:HookEvent(self, "OnSizeChanged", self.searchBox.SetWidth)
    self:HookEvent(self.searchBox, "OnValueChanged", UpdateSearchFilter)
    
    self.listBox = CreateGUIObject("listBox", GUIMenuBasicBox, self)
    self.listBox:HookEvent(self, "OnSizeChanged", self.listBox.SetWidth)
    
    self.listBoxScrollPane = CreateGUIObject("listBoxScrollPane", GUIMenuScrollPane, self.listBox)
    
    -- Scroll pane size is sync'd to the list box's size.
    self.listBoxScrollPane:HookEvent(self.listBox, "OnSizeChanged", self.listBoxScrollPane.SetSize)
    
    -- Scroll pane's pane size is sync'd to the width of the list box.
    self.listBoxScrollPane:HookEvent(self.listBox, "OnSizeChanged", self.listBoxScrollPane.SetPaneWidth)
    
    -- Create a vertical list layout to store the friends list entries.
    self.listLayout = CreateGUIObject("listLayout", GUIMenuModEntryLayout, self.listBoxScrollPane,
    {
        orientation = "vertical",
        fixedMinorSize = true,
    })
    
    -- List layout's width is sync'd to the contents width of the scroll pane.
    self.listLayout:HookEvent(self.listBoxScrollPane, "OnContentsSizeChanged", self.listLayout.SetWidth)
    self.listLayout:SetWidth(self.listBoxScrollPane:GetContentsSize())
    
    -- Scroll pane's pane-height is sync'd to the height of the layout.
    self.listBoxScrollPane:HookEvent(self.listLayout, "OnSizeChanged", self.listBoxScrollPane.SetPaneHeight)
    
    self:HookEvent(self, "OnSizeChanged", UpdateLayout)
    UpdateLayout(self)
    
    self:HookEvent(GetGlobalEventDispatcher(), "OnSteamFriendsUpdated", OnSteamFriendsUpdated)
    
    self:AddTimedCallback(RefreshFriendsList, kFriendsListRefreshInterval, true)
    RefreshFriendsList(self)
    
end
