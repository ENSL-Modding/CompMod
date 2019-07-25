-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. ======
--
-- lua\menu\ServerEntry.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more inTableation, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/WindowUtility.lua")

kServerEntryHeight = 34 -- little bit bigger than highlight server
local kDefaultWidth = 350

local kFavoriteIconSize = Vector(26, 26, 0)
local kFavoriteIconPos = Vector(5, 4, 0)
local kFavoriteTexture = PrecacheAsset("ui/menu/favorite.dds")
local kNotFavoriteTexture = PrecacheAsset("ui/menu/nonfavorite.dds")

local kBlockedIconSize = Vector(26, 26, 0)
local kBlockedIconPos = Vector(5, 4, 0)
local kBlockedTexture = PrecacheAsset("ui/menu/blocked.dds")
local kNotBlockedTexture = PrecacheAsset("ui/menu/notblocked.dds")

local kFavoriteMouseOverColor = Color(1,1,0,1)
local kFavoriteColor = Color(1,1,1,0.9)

local kBlockedMouseOverColor = Color(1,1,0,1)
local kBlockedColor = Color(1,1,1,0.9)

local kPrivateIconSize = Vector(26, 26, 0)
local kPrivateIconTexture = PrecacheAsset("ui/lock.dds")

local kPingIconSize = Vector(37, 24, 0)
local kPingIconTextures = {
    {50,  PrecacheAsset("ui/icons/ping_5.dds")},
    {100, PrecacheAsset("ui/icons/ping_4.dds")},
    {150, PrecacheAsset("ui/icons/ping_3.dds")},
    {250, PrecacheAsset("ui/icons/ping_2.dds")},
    {math.huge, PrecacheAsset("ui/icons/ping_1.dds")},
}

local kPerfIconSize = Vector(26, 26, 0)
local kPerfIconTexture = PrecacheAsset("ui/icons/smiley_meh.dds")

local kSkillIconSize = Vector(81, 26, 0)
local kSkillIconTexture = PrecacheAsset("ui/skill_tier_icons.dds")

local kBlue = Color(0, 168/255 ,255/255)
local kGreen = Color(0, 208/255, 103/255)
local kYellow = kGreen --Color(1, 1, 0) --used for reserved full
local kGold = kBlue --Color(212/255, 175/255, 55/255) --used for ranked
local kRed = kBlue --Color(1, 0 ,0) --used for full
local kGray = Color(155/255, 166/255, 158/255)-- used for blocked server entries

function SelectServerEntry(entry)

    -- local height = entry:GetHeight()
    local topOffSet = entry:GetBackground():GetPosition().y + entry:GetParent():GetBackground():GetPosition().y
    entry.scriptHandle.selectServer:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
    entry.scriptHandle.selectServer:SetIsVisible(true)
    MainMenu_SelectServer(entry:GetId(), entry.serverData, entry)
    
end

class 'ServerEntry' (MenuElement)

function ServerEntry:Initialize()

    self:DisableBorders()
    
    MenuElement.Initialize(self)
    
    self.serverName = CreateTextItem(self, true)
    self.mapName = CreateTextItem(self, true)
    self.mapName:SetTextAlignmentX(GUIItem.Align_Center)

    self.ping = CreateGraphicItem(self, true)
    self.ping:SetTexture(kPingIconTextures[1][2])
    self.ping:SetSize(kPingIconSize)
    self.pingText = CreateTextItem(self, true)
    self.pingText:SetTextAlignmentX(GUIItem.Align_Min)

    self.tickRate = CreateGraphicItem(self, true)
    self.tickRate:SetTexture(kPerfIconTexture)
    self.tickRate:SetSize(kPerfIconSize)

    self.modName = CreateTextItem(self, true)
    self.modName:SetTextAlignmentX(GUIItem.Align_Center)

    self.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")

    self.playerCount = CreateTextItem(self, true)
    self.playerCount:SetTextAlignmentX(GUIItem.Align_Center)

    self.spectatorCount = CreateTextItem(self, true)
    self.spectatorCount:SetTextAlignmentX(GUIItem.Align_Center)

    self.rank = CreateTextItem(self, true)
    self.rank:SetTextAlignmentX(GUIItem.Align_Center)
    
    self.skill = CreateGraphicItem(self, true)
    self.skill:SetTexture(kSkillIconTexture)
    self.skill:SetSize(kSkillIconSize)
    
    self.favorite = CreateGraphicItem(self, true)
    self.favorite:SetSize(kFavoriteIconSize)
    self.favorite:SetPosition(kFavoriteIconPos)
    self.favorite:SetTexture(kNotFavoriteTexture)
    self.favorite:SetColor(kFavoriteColor)

    self.blocked = CreateGraphicItem(self, true)
    self.blocked:SetSize(kBlockedIconSize)
    self.blocked:SetPosition(kBlockedIconPos)
    self.blocked:SetTexture(kNotBlockedTexture)
    self.blocked:SetColor(kBlockedColor)
    
    self.private = CreateGraphicItem(self, true)
    self.private:SetSize(kPrivateIconSize)
    self.private:SetTexture(kPrivateIconTexture)
    
    self:SetFontName(Fonts.kAgencyFB_Small)
    
    self:SetTextColor(kWhite)
    self:SetHeight(kServerEntryHeight)
    self:SetWidth(kDefaultWidth)
    self:SetBackgroundColor(kNoColor)
    
    --Has no children, but just to keep sure, we do that.
    self:SetChildrenIgnoreEvents(true)
        
    local eventCallbacks =
    {
        OnMouseIn = function(_, _)
            MainMenu_OnMouseIn()
        end,
        
        OnMouseOver = function(self)
        
            -- local height = self:GetHeight()
            local topOffSet = self:GetBackground():GetPosition().y + self:GetParent():GetBackground():GetPosition().y
            self.scriptHandle.highlightServer:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
            self.scriptHandle.highlightServer:SetIsVisible(true)

            local cursorX, cursorY = Client.GetCursorPosScreen()
            
            if GUIItemContainsPoint(self.favorite, cursorX, cursorY) then
                self.favorite:SetColor(kFavoriteMouseOverColor)
            else
                self.favorite:SetColor(kFavoriteColor)
            end
            
            if GUIItemContainsPoint(self.blocked, cursorX, cursorY) then
                self.blocked:SetColor(kBlockedMouseOverColor)
            else
                self.blocked:SetColor(kBlockedColor)
            end
            
            if self.modName.tooltipText and GUIItemContainsPoint(self.modName, cursorX, cursorY) then
                self.tooltip:SetText(self.modName.tooltipText)
                self.tooltip:Show()
            elseif self.skill.tooltipText and GUIItemContainsPoint(self.skill, cursorX, cursorY) then
                self.tooltip:SetText(self.skill.tooltipText)
                self.tooltip:Show()
            else
                self.tooltip:Hide()
            end
        end,
        
        OnMouseOut = function(self)
        
            self.scriptHandle.highlightServer:SetIsVisible(false)
            self.favorite:SetColor(kFavoriteColor)
            self.blocked:SetColor(kBlockedColor)

            if self.lastOneClick then
                self.lastOneClick = nil

                --if self.scriptHandle.serverDetailsWindow:GetIsVisible() then
                --    self.scriptHandle.serverDetailsWindow:SetIsVisible(false)
                --end
            end
        
        end,
        
        OnMouseDown = function(self, _, doubleClick)
            
            local overFavorite = GUIItemContainsPoint(self.favorite, Client.GetCursorPosScreen())
            local overBlocked = GUIItemContainsPoint(self.blocked, Client.GetCursorPosScreen())
            
            if overFavorite or overBlocked then

                if overFavorite then
                    if not self.serverData.favorite then

                        self.favorite:SetTexture(kFavoriteTexture)
                        self.serverData.favorite = true

                        if self.serverData.blocked then
                            self.blocked:SetTexture(kNotBlockedTexture)
                            self.serverData.blocked = false
                            SetServerIsBlocked(self.serverData, false, true)
                        end

                        SetServerIsFavorite(self.serverData, true)

                    else

                        self.favorite:SetTexture(kNotFavoriteTexture)
                        self.serverData.favorite = false
                        SetServerIsFavorite(self.serverData, false)

                    end
                else
                    if not self.serverData.blocked then

                        self.blocked:SetTexture(kBlockedTexture)
                        self.serverData.blocked = true

                        if self.serverData.favorite then
                            self.favorite:SetTexture(kNotFavoriteTexture)
                            self.serverData.favorite = false
                            SetServerIsFavorite(self.serverData, false, true)
                        end

                        SetServerIsBlocked(self.serverData, true)

                    else

                        self.blocked:SetTexture(kNotBlockedTexture)
                        self.serverData.blocked = false
                        SetServerIsBlocked(self.serverData, false)

                    end
                end
                
                self.parentList:UpdateEntry(self.serverData, true)
                
            else
            
                SelectServerEntry(self)
                
                if doubleClick then
                
                    if (self.timeOfLastClick ~= nil and (Shared.GetTime() < self.timeOfLastClick + 0.3)) then
                        self.lastOneClick = nil
                        self.scriptHandle:ProcessJoinServer()
                    end
                    
                else

                    self.scriptHandle.serverDetailsWindow:SetServerData(self.serverData, self.serverData.serverId or -1)
                    self.lastOneClick = Shared.GetTime()
                    self.scriptHandle.serverDetailsWindow:SetIsVisible(true)
                    
                end
                
                self.timeOfLastClick = Shared.GetTime()
                
            end
            
        end
    }
    
    self:AddEventCallbacks(eventCallbacks)

end

function ServerEntry:SetParentList(parentList)
    self.parentList = parentList
end

function ServerEntry:SetFontName(fontName)

    self.serverName:SetFontName(fontName)
    self.serverName:SetScale(GetScaledVector())
    self.mapName:SetFontName(fontName)
    self.mapName:SetScale(GetScaledVector())
    self.modName:SetFontName(fontName)
    self.modName:SetScale(GetScaledVector())
    self.playerCount:SetFontName(fontName)
    self.playerCount:SetScale(GetScaledVector())
    self.spectatorCount:SetFontName(fontName)
    self.spectatorCount:SetScale(GetScaledVector())
    self.rank:SetFontName(fontName)
    self.rank:SetScale(GetScaledVector())
    self.pingText:SetFontName(fontName)
    self.pingText:SetScale(GetScaledVector())

end

function ServerEntry:SetTextColor(color)

    self.serverName:SetColor(color)
    self.mapName:SetColor(color)
    self.modName:SetColor(color)
    self.playerCount:SetColor(color)
    self.spectatorCount:SetColor(color)
    self.rank:SetColor(color)
    self.pingText:SetColor(color)

end

function ServerEntry:SetIsFiltered(filtered)
    self.filtered = filtered
end

function ServerEntry:GetIsFiltered()
    return self.filtered == true
end

--[[
-- Returns the local clients hive skill or -1 if the hive service is not avaible
 ]]
function Client.GetSkill()
    return tonumber(GetGUIMainMenu().playerSkill) or -1
end

function Client.GetScore()
    return GetGUIMainMenu().playerScore or -1
end

function Client.GetLevel()
    return GetGUIMainMenu().playerLevel or -1
end

function Client.GetSkillTier()
    return GetGUIMainMenu().skillTier or -1
end

function ServerEntry:SetServerData(serverData)

    PROFILE("ServerEntry:SetServerData")

    if self.serverData ~= serverData then
    
        local numReservedSlots = serverData.numRS or 0
        self.playerCount:SetText(string.format("%d/%d", math.max(0, serverData.numPlayers), math.max(0, (serverData.maxPlayers - numReservedSlots))))
        if serverData.numPlayers >= serverData.maxPlayers then
            self.playerCount:SetColor(kRed)
        elseif serverData.numPlayers >= serverData.maxPlayers - numReservedSlots then
            self.playerCount:SetColor(kYellow)
        else
            self.playerCount:SetColor(kWhite)
        end

        self.spectatorCount:SetText(string.format("%d/%d", serverData.numSpectators, serverData.maxSpectators ))
        if serverData.numSpectators >= serverData.maxSpectators then
            self.spectatorCount:SetColor(kRed)
        else
            self.spectatorCount:SetColor(kWhite)
        end

        self.rank:SetText(tostring(serverData.rank or 0))
     
        self.serverName:SetText(serverData.name)
        
        if serverData.rookieOnly then
            self.serverName:SetColor(kGreen)
        else
            self.serverName:SetColor(kWhite)
        end
        
        self.mapName:SetText(serverData.map)
        
        for _, pingTexture in ipairs(kPingIconTextures) do
            if serverData.ping < pingTexture[1] then
                self.ping:SetTexture(pingTexture[2])
                break
            end
        end

        self.pingText:SetText(tostring(serverData.ping))
        
        if serverData.performanceScore ~= nil then
            self.tickRate:SetTexture(ServerPerformanceData.GetPerformanceIcon(serverData.performanceQuality, serverData.performanceScore))
            -- Log("%s: score %s, q %s", serverData.name, serverData.performanceScore, serverData.performanceQuality)
        else
            self.tickRate:SetTexture(kPerfIconTexture)
        end

        self.private:SetIsVisible(serverData.requiresPassword)
        
        self.modName:SetText(serverData.mode)
        self.modName:SetColor(kWhite)
        self.modName.tooltipText = nil

        if serverData.mode == "ns2" and serverData.ranked then
            self.modName:SetColor(kGold)
            self.modName.tooltipText = Locale.ResolveString(string.format("SERVERBROWSER_RANKED_TOOLTIP"))
        end
        
        if serverData.favorite then
            self.favorite:SetTexture(kFavoriteTexture)
        else
            self.favorite:SetTexture(kNotFavoriteTexture)
        end

        if serverData.blocked then
            self.blocked:SetTexture(kBlockedTexture)
            self:SetTextColor(kGray)
        else
            self.blocked:SetTexture(kNotBlockedTexture)
        end
        
        local skillTier, tierName = GetPlayerSkillTier(serverData.numPlayers > 0  and serverData.playerSkill or -1, serverData.rookieOnly)

        local textureIndex = skillTier + 2
        self.skill:SetTexturePixelCoordinates(0, textureIndex * 32, 100, (textureIndex + 1) * 32 - 1)
        self.skill:SetIsVisible(true)
        self.skill.tooltipText = string.format(Locale.ResolveString("SKILLTIER_TOOLTIP"), Locale.ResolveString(tierName), skillTier)
        
        self:SetId(serverData.serverId)
        self.serverData = { }
        for name, value in pairs(serverData) do
            self.serverData[name] = value
        end
        
    end
    
end

function ServerEntry:SetWidth(width, isPercentage, time, animateFunc, callBack)

    if width ~= self.storedWidth then
        -- The percentages and padding for each column are defined in the CSS
        -- We can use them here to set the position correctly instead of guessing like previously
        MenuElement.SetWidth(self, width, isPercentage, time, animateFunc, callBack)
        local currentPos = 0
        local currentWidth = self.rank:GetSize().x
        local currentPercentage = width * 0.05
        local kPaddingSize = 4

        self.rank:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))

        currentPos = currentPercentage + kPaddingSize
        currentPercentage = width * 0.03
        currentWidth = self.favorite:GetSize().x
        self.favorite:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), GUIScale(2), 0))

        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.03
        currentWidth = self.blocked:GetSize().x
        self.blocked:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), GUIScale(2), 0))

        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.03
        currentWidth = self.private:GetSize().x
        self.private:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), GUIScale(2), 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.03
        currentWidth = self.skill:GetSize().x
        self.skill:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), GUIScale(2), 0))

        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.3
        self.serverName:SetPosition(Vector((currentPos + kPaddingSize), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.07
        currentWidth = GUIScale(self.modName:GetTextWidth(self.modName:GetText()))
        self.modName:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.15
        currentWidth = GUIScale(self.mapName:GetTextWidth(self.mapName:GetText()))
        self.mapName:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.07
        currentWidth = GUIScale(self.playerCount:GetTextWidth(self.playerCount:GetText()))
        self.playerCount:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0)) 
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.07
        currentWidth = GUIScale(self.spectatorCount:GetTextWidth(self.spectatorCount:GetText()))
        self.spectatorCount:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.07
        currentWidth = GUIScaleWidth(26)
        self.tickRate:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage
        currentPercentage = width * 0.05
        currentWidth = self.ping:GetSize().x
        self.ping:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/3), 2, 0))
        self.pingText:SetPosition(Vector((currentPos + currentPercentage/2 + 2*currentWidth/3), 0, 0))
        
        self.storedWidth = width
    
    end

end

function ServerEntry:UpdateVisibility(minY, maxY, desiredY)

    if not self:GetIsFiltered() then

        if not desiredY then
            desiredY = self:GetBackground():GetPosition().y
        end
        
        local yPosition = self:GetBackground():GetPosition().y
        local ySize = self:GetBackground():GetSize().y
        
        local inBoundaries = ((yPosition + ySize) > minY) and yPosition < maxY
        self:SetIsVisible(inBoundaries)
        
    else
        self:SetIsVisible(false)
    end    

end

function ServerEntry:SetBackgroundTexture()
    Print("ServerEntry:SetBackgroundTexture")
end

-- do nothing, save performance, save the world
function ServerEntry:SetCSSClass(_, _)
end

function ServerEntry:GetTagName()
    return "serverentry"
end

function ServerEntry:SetId(id)

    assert(type(id) == "number")
    self.rowId = id
    
end

function ServerEntry:GetId()
    return self.rowId
end