-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModScreen.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A list of mod entries (viewable via the MANAGE MODS section in the mods menu).
--
--  Properties:
--      SortFunction        The function currently being used to sort the mod entries.
--      ModEntries          The unsorted list of mod entries that this screen contains.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")

Script.Load("lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModColumnHeader.lua")
Script.Load("lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModEntry.lua")
Script.Load("lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModEntryLayout.lua")

---@class GUIMenuModScreen : GUIObject
class "GUIMenuModScreen" (GUIObject)

local modsMenu
function GetModsMenu()
    return modsMenu
end

local kColumnHeaderHeight = 74

local function PrepareStringForSort(str)
    return (string.UTF8Lower(str))
end

local function SortByModTitle(a, b)
    return PrepareStringForSort(a:GetModTitle()) < PrepareStringForSort(b:GetModTitle())
end

local function SortByModTitleReversed(a, b)
    return PrepareStringForSort(a:GetModTitle()) > PrepareStringForSort(b:GetModTitle())
end

local function ClassifyModStatus(entry)
    
    local state = entry:GetModState()
    local subscribed = entry:GetSubscribed()
    if state == "available" then
        if subscribed then
            return 1
        else
            return 2
        end
    elseif state == "downloading" then
        return 3
    elseif state == "getting_info" then
        return 4
    elseif state == "unavailable" then
        return 5
    else
        return 6 -- unknown
    end
    
end

local function SortByModStatus(a, b)
    local statusA = ClassifyModStatus(a)
    local statusB = ClassifyModStatus(b)
    if statusA == statusB then
        return (SortByModTitle(a, b))
    else
        return statusA < statusB
    end
end

local function SortByModStatusReversed(a, b)
    local statusA = ClassifyModStatus(a)
    local statusB = ClassifyModStatus(b)
    if statusA == statusB then
        return (SortByModTitle(a, b))
    else
        return statusA > statusB
    end
end

local function SortByModActive(a, b)
    local activeA = a:GetActive() and 1 or 0
    local activeB = b:GetActive() and 1 or 0
    if activeA == activeB then
        return (SortByModTitle(a, b))
    else
        return activeA > activeB
    end
end

local function SortByModActiveReversed(a, b)
    local activeA = a:GetActive() and 1 or 0
    local activeB = b:GetActive() and 1 or 0
    if activeA == activeB then
        return (SortByModTitle(a, b))
    else
        return activeA < activeB
    end
end

local kColumnHeaderConfigs =
{
    { -- MOD TITLE
        name = "modTitle",
        class = GUIMenuModColumnHeader,
        params =
        {
            label = Locale.ResolveString("MODS_NAME"),
            sortFuncs = {SortByModTitle, SortByModTitleReversed},
            weight = 0.6,
        }
    },

    { -- MOD STATUS
        name = "modStatus",
        class = GUIMenuModColumnHeader,
        params =
        {
            label = Locale.ResolveString("MODS_STATE"),
            sortFuncs = {SortByModStatus, SortByModStatusReversed},
            weight = 0.2,
        }
    },
    
    { -- MOD ACTIVE
        name = "modActive",
        class = GUIMenuModColumnHeader,
        params =
        {
            label = Locale.ResolveString("MODS_ACTIVE"),
            sortFuncs = {SortByModActive, SortByModActiveReversed},
            weight = 0.2,
        }
    },
}

GUIMenuModScreen:AddClassProperty("SortFunction", SortByModActive)
GUIMenuModScreen:AddClassProperty("ModEntries", {}, true)

local function OnNumModsChanged(self, numMods)
    
    local modEntries = self:GetModEntries()
    local listChanged = false
    
    while #modEntries < numMods do
        local newEntry = CreateGUIObject("modEntry", GUIMenuModEntry, self.layout)
        newEntry:HookEvent(self.layout, "OnSizeChanged", newEntry.SetWidth)
        newEntry:SetWidth(self.layout:GetSize())
        modEntries[#modEntries+1] = newEntry
        listChanged = true
    end
    
    while #modEntries < numMods do
        local oldEntry = modEntries[#modEntries]
        modEntries[#modEntries] = nil
        oldEntry:Destroy()
        listChanged = true
    end
    
    assert(#modEntries == numMods)
    
    for i=1, #modEntries do
        local modEntry = modEntries[i]
        modEntry:SetModEngineId(i)
    end
    
    if listChanged then
        self:SetModEntries(modEntries)
    end
    
end

local function ReSortMods(self)
    
    local modEntries = self:GetModEntries()
    
    -- Sort a copy of the table, not the original.  The original is sorted according to engine id,
    -- and we don't want to change that.
    local sortedEntries = {}
    for i=1, #modEntries do
        sortedEntries[i] = modEntries[i]
    end
    table.sort(sortedEntries, self:GetSortFunction())
    
    -- Pause layout updates for the moment...
    self.layout:SetAutoArrange(false)
    
    for i=1, #sortedEntries do
        sortedEntries[i]:SetLayer(i)
    end
    
    -- Resume layout updates now that we're done changing layer numbers.
    self.layout:SetAutoArrange(true)
    
end

function GUIMenuModScreen:UpdateAllMods()
    
    local modEntries = self:GetModEntries()
    for i=1, #modEntries do
        local entry = modEntries[i]
        entry:UpdateData()
    end

end

local function OnSizeChanged(self)
    self.scrollPane:SetSize(self:GetSize().x, self:GetSize().y - self.header:GetSize().y)
end

local function MaybeRefreshIfFocused(self)
    
    local focused = Client.GetIsWindowFocused() and not Client.GetIsSteamOverlayActive()
    local optionsMenuVisible = GetScreenManager():GetCurrentScreenName() == "Options"
    local modsMenuVisible = optionsMenuVisible and GetOptionsMenu():GetActiveSubScreenName() == "Mods"
    
    if focused and modsMenuVisible then
        GetModDataManager():Refresh()
    end
    
end

function GUIMenuModScreen:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    assert(not modsMenu) -- should only ever be one.
    modsMenu = self
    
    -- Create column headers.
    self.header = CreateGUIObject("header", GUIFillLayout, self,
    {
        orientation = "horizontal",
        fixedMinorSize = true,
    })
    self.header:HookEvent(self, "OnSizeChanged", self.header.SetWidth)
    self.header:SetHeight(kColumnHeaderHeight)
    
    for i=1, #kColumnHeaderConfigs do
        local newColumnHeader = CreateGUIObjectFromConfig(kColumnHeaderConfigs[i], self.header)
        newColumnHeader:SetHeight(kColumnHeaderHeight)
    end
    
    -- Create the scroll pane contents.
    self.scrollPane = CreateGUIObject("scrollPane", GUIMenuScrollPane, self,
    {
        horizontalScrollBarEnabled = false,
        scrollSpeedMult = 1.5,
    })
    self.scrollPane:AlignBottom()
    
    self.layout = CreateGUIObject("layout", GUIMenuModEntryLayout, self.scrollPane,
    {
        orientation = "vertical",
        fixedMinorSize = true,
        frontPadding = 0,
        backPadding = 0,
        spacing = 0,
    })
    self.scrollPane:HookEvent(self.layout, "OnSizeChanged", self.scrollPane.SetPaneSize)
    self.layout:HookEvent(self.scrollPane, "OnContentsSizeChanged", self.layout.SetWidth)
    
    local modDataManager = GetModDataManager()
    assert(modDataManager)
    
    self:HookEvent(modDataManager, "OnNumModsChanged", OnNumModsChanged)
    self:HookEvent(self, "OnModEntriesChanged", ReSortMods)
    self:HookEvent(self, "OnSortFunctionChanged", ReSortMods)
    self:HookEvent(GetModDataManager(), "OnBeingRefreshedChanged",
    function(self, beingRefreshed)
        if beingRefreshed then
            if not self.sortWhileRefreshingCallback then
                self.sortWhileRefreshingCallback = self:AddTimedCallback(
                function(self)
                    ReSortMods(self)
                end, 0.25, true)
            end
        else
            ReSortMods(self)
            if self.sortWhileRefreshingCallback then
                self:RemoveTimedCallback(self.sortWhileRefreshingCallback)
                self.sortWhileRefreshingCallback = nil
            end
        end
    end)
    
    self:HookEvent(self, "OnSizeChanged", OnSizeChanged)
    self:HookEvent(self.header, "OnSizeChanged", OnSizeChanged)
    
    self:HookEvent(GetGlobalEventDispatcher(), "OnWindowFocusedChanged", MaybeRefreshIfFocused)
    self:HookEvent(GetGlobalEventDispatcher(), "OnSteamOverlayChanged", MaybeRefreshIfFocused)
    
end
