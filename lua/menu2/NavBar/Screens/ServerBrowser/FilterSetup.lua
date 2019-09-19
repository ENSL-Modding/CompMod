-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/FilterSetup.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Contains all the various filter type information.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWCheckboxWidget.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWChoiceWidget.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWSliderWidget.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWTextEntryWidget.lua")

Script.Load("lua/menu2/wrappers/Tooltip.lua")

kFilterOptionPrefix = "server-browser/filters/"

local perfToRating =
{
    SERVER_PERF_BAD = 1,
    SERVER_PERF_LOADED = 2,
    SERVER_PERF_OK = 3,
    SERVER_PERF_GOOD = 4,
}
function PerformanceRatingToNumber(ratingString)
    assert(type(ratingString) == "string")
    return perfToRating[ratingString] or 4
end

-- Maximum value the user can limit ping to.  The slider is setup to go to one-past this value,
-- which represents unlimited.
kPingMaxValue = 500

-- List of filters for the filter window.
local filterInfo =
{
    { -- Server Name
        name = "serverName",
        class = GetAutoOptionWrappedClass(GMSBFWTextEntryWidget),
        params =
        {
            label = Locale.ResolveString("SERVERBROWSER_SERVERNAME"),
            
            optionPath = kFilterOptionPrefix.."serverName",
            optionType = "string",
            default = "",
        },
        
        func = function(serverEntry, value)
            local serverName = serverEntry:GetServerName()
            
            if value == "" then
                return true
            end
            
            local result = SubStringInString(value, serverName)
            return result
        end,
    },
    
    { -- Map Name
        name = "mapName",
        class = GetAutoOptionWrappedClass(GMSBFWTextEntryWidget),
        params =
        {
            label = Locale.ResolveString("SERVERBROWSER_MAPNAME"),
            
            optionPath = kFilterOptionPrefix.."mapName",
            optionType = "string",
            default = "",
        },
        
        func = function(serverEntry, value)
            local mapName = serverEntry:GetMapName()
            
            if value == "" then
                return true
            end
            
            local result = SubStringInString(value, mapName)
            return result
        end,
    },
    
    { -- Password
        name = "password",
        class = GetAutoOptionWrappedClass(GetTooltipWrappedClass(GMSBFWCheckboxWidget)),
        params =
        {
            label = Locale.ResolveString("SERVERBROWSER_PASSWORDED"),
            
            tooltip = Locale.ResolveString("SERVERBROWSER_PASSWORDED_FILTER_TOOLTIP"),

            optionPath = kFilterOptionPrefix.."password",
            optionType = "bool",
            default = true,
        },
        
        func = function(serverEntry, value)
            return (not serverEntry:GetPassworded()) or value
        end,
        
        postInit =
        {
            -- If the filter value is set outside of this widget, update the widget to match.
            function(widget)
                widget:HookEvent(GetServerBrowser(), "OnFilterValuepasswordChanged",
                    function(widget2, value, prevValue)
                        widget2:SetValue(value)
                    end)
            end,
        },
    },
    
    { -- Empty
        name = "empty",
        class = GetAutoOptionWrappedClass(GetTooltipWrappedClass(GMSBFWCheckboxWidget)),
        params =
        {
            label = Locale.ResolveString("SERVERBROWSER_SHOW_EMPTY"),
            
            tooltip = Locale.ResolveString("SERVERBROWSER_SHOW_EMPTY_TOOLTIP"),

            optionPath = kFilterOptionPrefix.."empty",
            optionType = "bool",
            default = true,
        },
        
        func = function(serverEntry, value)
            local isEmpty = serverEntry:GetPlayerCount() <= 0
            return (not isEmpty) or value
        end,
    },
    
    { -- Full
        name = "full",
        class = GetAutoOptionWrappedClass(GetTooltipWrappedClass(GMSBFWCheckboxWidget)),
        params =
        {
            label = Locale.ResolveString("SERVERBROWSER_SHOW_FULL"),
            
            tooltip = Locale.ResolveString("SERVERBROWSER_SHOW_FULL_TOOLTIP"),
            
            optionPath = kFilterOptionPrefix.."full",
            optionType = "bool",
            default = true,
        },
        
        func = function(serverEntry, value)
            local isFull = serverEntry:GetPlayerCount() >= serverEntry:GetPlayerMax()
            return (not isFull) or value
        end,
    },
    
    { -- Unranked
        name = "unranked",
        class = GetAutoOptionWrappedClass(GetTooltipWrappedClass(GMSBFWCheckboxWidget)),
        params =
        {
            label = Locale.ResolveString("SERVERBROWSER_SHOW_UNRANKED"),
            
            tooltip = Locale.ResolveString("SERVERBROWSER_FILTER_UNRANKED_TOOLTIP"),
            
            optionPath = kFilterOptionPrefix.."unranked",
            optionType = "bool",
            default = true,
        },
        
        func = function(serverEntry, value)
            return (serverEntry:GetRanked()) or value
        end,
        
        postInit =
        {
            -- If the filter value is set outside of this widget, update the widget to match.
            function(widget)
                widget:HookEvent(GetServerBrowser(), "OnFilterValueunrankedChanged",
                    function(widget2, value, prevValue)
                        widget2:SetValue(value)
                    end)
            end,
        },
    },
    
    { -- Rookie/bootcamp
        name = "bootcamp",
        class = GetAutoOptionWrappedClass(GetTooltipWrappedClass(GMSBFWCheckboxWidget)),
        params =
        {
            label = Locale.ResolveString("SERVERBROWSER_ROOKIEONLY"),
            
            tooltip = Locale.ResolveString("SERVERBROWSER_FILTER_BOOTCAMP_TOOLTIP"),
            
            optionPath = kFilterOptionPrefix.."bootcamp",
            optionType = "bool",
            default = true,
        },
        
        func = function(serverEntry, value)
            return (not serverEntry:GetRookieOnly()) or value
        end,
    },
    
    { -- Min. Performance
        name = "performance",
        class = GetAutoOptionWrappedClass(GetTooltipWrappedClass(GMSBFWChoiceWidget)),
        params =
        {
            label = Locale.ResolveString("SERVERBROWSER_PERF_MIN"),
            choices = 
            {
                { displayString = Locale.ResolveString("SERVER_PERF_BAD"),    value = "SERVER_PERF_BAD" },
                { displayString = Locale.ResolveString("SERVER_PERF_LOADED"), value = "SERVER_PERF_LOADED" },
                { displayString = Locale.ResolveString("SERVER_PERF_OK"),     value = "SERVER_PERF_OK" },
                { displayString = Locale.ResolveString("SERVER_PERF_GOOD"),   value = "SERVER_PERF_GOOD" },
            },
            
            tooltip = Locale.ResolveString("SERVERBROWSER_PERF_MIN_TOOLTIP"),

            optionPath = kFilterOptionPrefix.."performance",
            optionType = "string",
            default = "SERVER_PERF_BAD",
        },
        
        func = function(serverEntry, value)
            local serverPerf = PerformanceRatingToNumber(serverEntry:GetPerformanceRating())
            local filterPerf = PerformanceRatingToNumber(value)
            return serverPerf >= filterPerf
        end,
    },
    
    { -- Max Ping
        name = "ping",
        class = GetAutoOptionWrappedClass(GetTooltipWrappedClass(GMSBFWSliderWidget)),
        params =
        {
            label = Locale.ResolveString("SERVERBROWSER_MAXPING"),
            minimum = 25,
            maximum = kPingMaxValue + 1,
            
            tooltip = Locale.ResolveString("SERVERBROWSER_PING_TOOLTIP"),

            optionPath = kFilterOptionPrefix.."ping",
            optionType = "int",
            default = kPingMaxValue + 1,
        },
        postInit =
        {
            -- Setup 501 to read "Unlimited".
            function(self)
                
                local function OnPingValueChanged(self, value)
                    if value > kPingMaxValue then
                        self:SetValueDisplayOverride(Locale.ResolveString("FILTER_UNLIMTED"))
                    else
                        self:SetValueDisplayOverride(GMSBFWSliderWidget.NoOverride)
                    end
                end
                
                self:HookEvent(self, "OnValueChanged", OnPingValueChanged)
                OnPingValueChanged(self, self:GetValue())
                
            end,
        },
        
        func = function(serverEntry, value)
            local serverPing = serverEntry:GetPing()
            return serverPing <= value or value > kPingMaxValue
        end,
    },
    
    { -- Blocked Servers
        name = "blockedServers",
        class = GetAutoOptionWrappedClass(GetTooltipWrappedClass(GMSBFWChoiceWidget)),
        params =
        {
            label = Locale.ResolveString("SERVERBROWSER_BLOCKED_SERVERS"),
            choices =
            {
                { displayString = Locale.ResolveString("SERVERBROWSER_BLOCKED_SERVERS_HIDE"),     value = "hide" },
                { displayString = Locale.ResolveString("SERVERBROWSER_BLOCKED_SERVERS_SHOW"),     value = "show" },
                { displayString = Locale.ResolveString("SERVERBROWSER_BLOCKED_SERVERS_LIST_ALL"), value = "list_all" },
            },
            
            tooltip = Locale.ResolveString("SERVERBROWSER_BLOCKED_SERVERS_TOOLTIP"),

            optionPath = kFilterOptionPrefix.."blockedServers",
            optionType = "string",
            default = "hide",
        },
        
        func = function(serverEntry, value)
            local isBlocked = serverEntry:GetBlocked()
            
            if value == "hide" then
                -- Filter out if blocked.
                return not isBlocked
            else
                -- Show if set to show or list_all.  List_all will also have extra behavior
                -- implemented directly in the server browser to exclusively show these blocked
                -- servers.
                return true
            end
        end,
        
        postInit =
        {
            function(widget)
                
                -- If list_all is switched to, then set the server browser's view mode to
                -- "blocked", so we see all blocked servers, and no others.  If we switch
                -- off list_all, then set the server browser view back to default.
                widget:HookEvent(widget, "OnValueChangedByUser",
                    function(widget2, value, prevValue)
                        if value == "list_all" then
                            GetServerBrowser():SetCurrentView("blocked")
                        elseif prevValue == "list_all" then
                            widget2.changingView = true
                            GetServerBrowser():SetCurrentView("default")
                            widget2.changingView = nil
                        end
                    end)
                
                -- If the server browser's view mode is changed, and it _was_ "blocked", set this
                -- widget to "show".
                widget:HookEvent(GetServerBrowser(), "OnCurrentViewChanged",
                    function(widget2, value, prevValue)
                        if prevValue == "blocked" and not widget2.changingView then
                            widget2:SetValue("show")
                        end
                    end)
                
                -- If the filter value is set outside of this widget, update the widget to match.
                widget:HookEvent(GetServerBrowser(), "OnFilterValueblockedServersChanged",
                    function(widget2, value, prevValue)
                        widget2:SetValue(value)
                    end)
                
            end,
        }
    },
}

-- Global function so mods can modify the table returned.
function GetServerBrowserFilterConfiguration()
    return filterInfo
end










