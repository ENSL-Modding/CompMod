-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/OptionSavingManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Implements functionality that ensures option values are saved to disk quickly to ensure that
--    a crash doesn't result in lost data.  At the same time, it also implements a throttle, to
--    prevent the save routine from triggering rapidly.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

local kSaveThrottle = 5

local optionsStale = false
local lastSaveTime

local function MaybeSaveOptions()
    
    -- Don't save if no unsaved changes.
    if not optionsStale then
        return
    end
    
    -- Don't save too frequently.
    local now = Shared.GetSystemTime()
    if lastSaveTime and now - lastSaveTime < kSaveThrottle then
        return
    end
    
    -- Can't save if the function to do so hasn't been loaded yet.
    if not Client.SaveOptions then
        return
    end
    
    -- Save the options.
    lastSaveTime = now
    optionsStale = false
    
    Client.SaveOptions()
    
end

-- Keep trying to save options.  This is so if the user is dragging a slider, we're not saving every
-- single frame, but we save at the _next_ 5 second interval after the change has been made.
Event.Hook("UpdateClient", MaybeSaveOptions)

local function SetOptionsStale()
    optionsStale = true
    MaybeSaveOptions()
end

local kInsaneChars =
{
    { "+",      "_plus",    },
    { "<",      "_lt",      },
    { ">",      "_gt",      },
    { "|",      "_pipe",    },
    { "\\",     "_bckslsh", },
    -- TODO far from a complete list...
}
local function ReplaceAllCharsInStringWith(str, char, repWith)
    
    local outString = str
    local idx = 1
    while idx <= #outString do
        local findIdx = string.find(outString, char, idx)
        if findIdx == nil then
            break
        end
        
        outString = string.format("%s%s%s", string.sub(outString, idx, findIdx - 1), repWith, string.sub(outString, findIdx+1, #outString))
    end
    
    return outString
    
end

local function SanitizePathStringForOptionName(str)
    
    -- Add something to end if the last element is blank.
    local lastChar = string.sub(str, #str, #str)
    if lastChar == "" or lastChar == "/" then
        str = str .. "__blank"
    end
    
    -- Replace disallowed characters.
    for i=1, #kInsaneChars do
        local char = kInsaneChars[i][1]
        local repWith = kInsaneChars[i][2]
        str = ReplaceAllCharsInStringWith(str, char, repWith)
    end
    
    return str

end

-- Replace the 4 Client.GetOption_____ functions with ones that sanitize the paths.
local old_Client_GetOptionBoolean = Client.GetOptionBoolean
local old_Client_GetOptionFloat = Client.GetOptionFloat
local old_Client_GetOptionInteger = Client.GetOptionInteger
local old_Client_GetOptionString = Client.GetOptionString

assert(old_Client_GetOptionBoolean)
assert(old_Client_GetOptionFloat)
assert(old_Client_GetOptionInteger)
assert(old_Client_GetOptionString)

Client.GetOptionBoolean = function(path, default)
    assert(type(path) == "string")
    assert(type(default) == "boolean")
    path = SanitizePathStringForOptionName(path)
    return (old_Client_GetOptionBoolean(path, default))
end

Client.GetOptionFloat = function(path, default)
    assert(type(path) == "string")
    assert(type(default) == "number")
    path = SanitizePathStringForOptionName(path)
    return (old_Client_GetOptionFloat(path, default))
end

Client.GetOptionInteger = function(path, default)
    assert(type(path) == "string")
    assert(type(default) == "number")
    path = SanitizePathStringForOptionName(path)
    return (old_Client_GetOptionInteger(path, default))
end

Client.GetOptionString = function(path, default)
    assert(type(path) == "string")
    assert(type(default) == "string")
    path = SanitizePathStringForOptionName(path)
    return (old_Client_GetOptionString(path, default))
end

-- Client.SetOption____() aren't always defined in the beginning, so we have to wrap these up once
-- they are.
Event.Hook("LoadComplete", function()
    
    local old_Client_SetOptionBoolean = Client.SetOptionBoolean
    local old_Client_SetOptionFloat = Client.SetOptionFloat
    local old_Client_SetOptionInteger = Client.SetOptionInteger
    local old_Client_SetOptionString = Client.SetOptionString
    
    assert(old_Client_SetOptionBoolean)
    assert(old_Client_SetOptionFloat)
    assert(old_Client_SetOptionInteger)
    assert(old_Client_SetOptionString)
    
    Client.SetOptionBoolean = function(path, value)
        assert(type(path) == "string")
        assert(type(value) == "boolean")
        SetOptionsStale()
        path = SanitizePathStringForOptionName(path)
        old_Client_SetOptionBoolean(path, value)
    end
    
    Client.SetOptionFloat = function(path, value)
        assert(type(path) == "string")
        assert(type(value) == "number")
        SetOptionsStale()
        path = SanitizePathStringForOptionName(path)
        old_Client_SetOptionFloat(path, value)
    end
    
    Client.SetOptionInteger = function(path, value)
        assert(type(path) == "string")
        assert(type(value) == "number")
        SetOptionsStale()
        path = SanitizePathStringForOptionName(path)
        old_Client_SetOptionInteger(path, value)
    end
    
    Client.SetOptionString = function(path, value)
        assert(type(path) == "string")
        assert(type(value) == "string")
        SetOptionsStale()
        path = SanitizePathStringForOptionName(path)
        old_Client_SetOptionString(path, value)
    end
    
    -- Some options have probably been saved between the first "LoadComplete" hook call, and this
    -- one.
    SetOptionsStale()

end)
