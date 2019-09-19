-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/GUIMenuGameNavBar.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    In-game variant of the nav bar.  Last two options are different.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/GUIMenuGameNavBar.lua")

Script.Load("lua/menu2/NavBar/Screens/Vote/GUIMenuVote.lua")

---@class GUIMenuGameNavBar : GUIMenuNavBar
class "GUIMenuGameNavBar" (GUIMenuNavBar)

local function Disconnect()
    Shared.ConsoleCommand("disconnect")
end

function GUIMenuGameNavBar:OnDisconnectClicked()
    
    local currentScreen = GetScreenManager():GetCurrentScreen()
    if not currentScreen then
        Disconnect()
        return
    end
    
    if currentScreen:RequestHide(Disconnect) then
        Disconnect()
    end
    
end

local kButtonData = 
{
    [3] = 
    {
        name = "vote",
        buttonText = "VOTE",
        screenName = "Vote",
    },
    
    [4] = 
    {
        name = "disconnect",
        buttonText = "QUIT_CAPS",
        screenName = false, -- omitted for this option.  Nil would cause it to fall through.
        buttonFunction = GUIMenuGameNavBar.OnDisconnectClicked,
    },
}

-- Extend base class function to use this data when available, otherwise fall back to base class
-- data.
function GUIMenuGameNavBar.GetData(dataIndex, fieldName)
    
    local data = kButtonData[dataIndex]
    if data ~= nil and data[fieldName] ~= nil then
        return data[fieldName]
    end
    
    -- this field name for this index was not overwritten.
    local result = GUIMenuNavBar.GetData(dataIndex, fieldName)
    return result
    
end

function GUIMenuGameNavBar:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuNavBar.Initialize(self, params, errorDepth)
    
    -- vote menu (in-game only).
    self.voteMenu = CreateGUIObject("voteMenu", GUIMenuVote, self.childWindows)
    self.voteMenu:SetHotSpot(0.5, self.voteMenu:GetHotSpot().y)
    self.voteMenu:SetAnchor(0.5, 0)
    self:HookEvent(self.voteMenu, "OnScreenDisplay", function(self) self:SetGlowingButtonIndex(nil) end)
    self:HookEvent(self.voteMenu, "OnScreenHide", function(self) self:SetGlowingButtonIndex(nil) end)
    
end
