-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/ServerBrowserUtils.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Helpful utilities used by the server browser code.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

function SB_CompareValues(a, b)
    
    if a < b then
        return -1
    elseif a > b then
        return 1
    else
        return 0
    end
    
end

function SB_CompareBooleans(a, b)
    local x = a and 1 or 0
    local y = b and 1 or 0
    local result = SB_CompareValues(x, y)
    return result
end

function SB_CompareStrings(a, b)
    local x = string.UTF8Lower(a)
    local y = string.UTF8Lower(b)
    local result = SB_CompareValues(x,y)
    return result
end

local kBullshitStrings =
{
    "/", "\\", "|",
    "%[", "]",
    "{", "}",
    "~", "`", "!", "@", "#", "%$", "%%", "%^", "&", "%*", "%(", "%)", "%-", "%+", "_",
    " ", -- yea strip out spaces too...
    "<", ">", "%?",
    "%.", ",", ";", ":", "'", '"',
}
-- TODO probably missing quite a lot... Probably a better way to do this as well... but gotta keep
-- in mind the non-english speaking players... can't just filter by a-z...

function GetBullshitFreeServerName(str)
    
    -- Remove stupid bullshit like [-]=*&@#$ and other characters that don't contribute to the name,
    -- for the purposes of sorting.
    local result = string.UTF8Lower(str)
    for i=1, #kBullshitStrings do
        result = string.gsub(result, kBullshitStrings[i], "")
    end
    
    return result
    
end

function GetServerHasCustomNetVars(serverIndex)
    
    local tickrate = Client.GetServerPerformanceTickrate(serverIndex)
    local sendrate = Client.GetServerPerformanceSendrate(serverIndex)
    local moverate = Client.GetServerPerformanceMoverate(serverIndex)
    local interp = Client.GetServerPerformanceInterpMs(serverIndex)

    return tickrate ~= 30 or sendrate ~= 20 or moverate ~= 26 or interp ~= 100
    
end
