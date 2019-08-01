-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIInsight_PlayerHealthbars.lua
--
-- Created by: Jon 'Huze' Hughes (jon@jhuze.com)
--
-- Spectator: Displays player name and healthbars
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIInsight_PlayerHealthbars' (GUIScript)

local playerList, playerIds
local reusebackgrounds

local kPlayerHealthDrainRate = 0.75 --Percent per ???

local kFontName = Fonts.kInsight
local kPlayerHealthBarTexture = "ui/healthbarplayer.dds"
local kPlayerHealthBarTextureSize = Vector(100, 7, 0)

local kEnergyBarTexture = "ui/healthbarsmall.dds"
local kEnergyBarTextureSize = Vector(100, 6, 0)

local kNameFontScale
local kPlayerHealthBarSize
local kPlayerEnergyBGSize
local kPlayerEnergyBarSize
local kPlayerEnergyBarOffest
local kHealthbarOffset

-- Color constants.
local kDefaultColor = Color(0.5, 0.5, 0.5, 1)
local kTeamHealthColors = {[kMarineTeamType] = kBlueColor, [kAlienTeamType] = kRedColor}
local kTeamArmorColors = {[kMarineTeamType] = Color(0.5, 1, 1, 1), [kAlienTeamType] = Color(1,0.8,0,1)}

local kParasiteColor = Color(1, 1, 0, 1)
-- local kPoisonColor = Color(0, 1, 0, 1)
local kHealthDrainColor = Color(1, 0, 0, 1)
local kEnergyColor = Color(1,1,0,1)

GUIInsight_PlayerHealthbars.kAmmoColors = {
    ["rifle"] = Color(0,0,1,1), -- blue
    ["pistol"] = Color(0,1,1,1), -- teal
    ["axe"] = Color(1,1,1,1), -- white
    ["welder"] = Color(1,1,1,1), -- white
    ["builder"] = Color(1,1,1,1), -- white
    ["mine"] = Color(1,1,1,1), -- white
    ["shotgun"] = Color(0,1,0,1), -- green
    ["flamethrower"] = Color(1,1,0,1), -- yellow
    ["grenadelauncher"] = Color(1,0,1,1), -- magenta
    ["hmg"] = Color(1,0,0,1), -- red
    ["minigun"] = Color(1,0,0,1), -- red
    ["railgun"] = Color(1,0.5,0,1) -- orange
}

function GUIInsight_PlayerHealthbars:Initialize()

    self.updateInterval = 0

    kNameFontScale = GUIScale(Vector(1,1,1)) * 0.8
    kPlayerHealthBarSize = GUIScale(Vector(100, 7, 0))
    kPlayerEnergyBGSize = GUIScale(Vector(100, 6, 0))
    kPlayerEnergyBarSize = GUIScale(Vector(98, 5, 0))
    kPlayerEnergyBarOffest = GUIScale(Vector(1, 0, 0))
    kHealthbarOffset = Vector(0, -kPlayerHealthBarSize.y - GUIScale(16), 0)

    playerList = {}
    playerIds = {}
    reusebackgrounds = {}

    self.showHpText = false
end

function GUIInsight_PlayerHealthbars:Uninitialize()

    -- Players
    for _, id in ipairs(playerIds) do
        local player = playerList[id]
        GUI.DestroyItem(player.Background)
    end

    playerList = nil
    playerIds = nil

    -- Reuse items
    for _, background in ipairs(reusebackgrounds) do
        GUI.DestroyItem(background["Background"])
    end
    reusebackgrounds = nil

end

function GUIInsight_PlayerHealthbars:OnResolutionChanged()

    self:Uninitialize()
    kNameFontScale = GUIScale(Vector(1,1,1)) * 0.8
    kPlayerHealthBarSize = GUIScale(Vector(100, 7, 0))
    kPlayerEnergyBGSize = GUIScale(Vector(100, 6, 0))
    kPlayerEnergyBarSize = GUIScale(Vector(98, 5, 0))
    kPlayerEnergyBarOffest = GUIScale(Vector(1, 0, 0))
    kHealthbarOffset = Vector(0, -kPlayerHealthBarSize.y - GUIScale(16), 0)
    self:Initialize()

end

function GUIInsight_PlayerHealthbars:Update(deltaTime)

    PROFILE("GUIInsight_PlayerHealthbars:Update")

    local player = Client.GetLocalPlayer()
    if not player then
        return
    end

    self:UpdatePlayers(deltaTime)

end

function GUIInsight_PlayerHealthbars:UpdatePlayers(deltaTime)

    local players = Shared.GetEntitiesWithClassname("Player")

    -- Remove old players

    for i, id in ipairs(playerIds) do

        local player = playerList[id]
        local contains = false
        for _, newPlayer in ientitylist(players) do
            if id == newPlayer:GetId() then
                contains = true
            end
        end

        if not contains then

            -- Store unused elements for later
            player.Background:SetIsVisible(false)
            table.insert(reusebackgrounds, player)

            playerList[id] = nil
            table.remove(playerIds, i)
        end
    end

    -- Add new and Update all players

    for _, player in ientitylist(players) do

        local playerIndex = player:GetId()
        local relevant = player:GetIsVisible() and player:GetIsAlive() and not player:isa("Commander") and not player:isa("Spectator") and not player:isa("ReadyRoomPlayer")

        if relevant then

            local _, max = player:GetModelExtents()
            local nameTagWorldPosition = player:GetOrigin() + Vector(0, max.y, 0)

            local health = player:isa("Exo") and 0 or math.floor(player:GetHealth())
            local armor = player:GetArmor() * kHealthPointsPerArmor
            local maxHealth = player:isa("Exo") and 0 or player:GetMaxHealth()
            local maxArmor = player:GetMaxArmor() * kHealthPointsPerArmor
            local regen = HasMixin(player, "Regeneration") and player:GetRegeneratingHealth() or 0

            local regenFraction = regen/(maxHealth+maxArmor)
            local healthFraction = health/(maxHealth+maxArmor)
            local armorFraction = armor/(maxHealth+maxArmor)

            local nameTagInScreenspace = Client.WorldToScreen(nameTagWorldPosition) + kHealthbarOffset
            local textColor = Color(kNameTagFontColors[player:GetTeamType()] or kDefaultColor)
            local healthColor = Color(kTeamHealthColors[player:GetTeamType()] or kDefaultColor)
            local armorColor = Color(kTeamArmorColors[player:GetTeamType()] or kDefaultColor)
            local regenColor = Color(0/255, 255/255, 33/255, 1)

            -- local isPoisoned = player.poisoned
            local isParasited = player.parasited

            -- Get/Create Player GUI Item
            local playerGUI
            if not playerList[playerIndex] then -- Add new GUI for new players

                playerGUI = self:CreatePlayerGUIItem()
                playerGUI.StoredValues.TotalFraction = healthFraction+armorFraction
                table.insert(playerList, playerIndex, playerGUI)
                table.insert(playerIds, playerIndex)

            else

                playerGUI = playerList[playerIndex]

            end

            playerGUI.Background:SetIsVisible(true)

            -- Set player info --

            -- background
            local background = playerGUI.Background
            background:SetPosition(nameTagInScreenspace)

            -- name
            local nameItem = playerGUI.Name
            local name = player:GetName()
            nameItem:SetText(name)
            nameItem:SetColor(ConditionalValue(isParasited, kParasiteColor, textColor))


            -- hpText
            local hpText = playerGUI.HPText

            if self.showHpText then
                local offset = -(nameItem:GetTextHeight(name) * nameItem:GetScale().y) + GUIScale(5)
                nameItem:SetPosition(Vector(0,offset,0))

                local text = string.format("%s / %s", health, armor)
                if player:isa("Exo") then
                    text = tostring(math.max(armor, 1))
                end

                hpText:SetIsVisible(true)
                hpText:SetText(text)
                hpText:SetColor(textColor)
            else
                nameItem:SetPosition(Vector(0,0,0))
                hpText:SetIsVisible(false)
            end

            -- health bar
            local healthBar = playerGUI.HealthBar
            local healthBarSize = healthFraction * kPlayerHealthBarSize.x
            local healthBarTextureSize = healthFraction * kPlayerHealthBarTextureSize.x
            healthBar:SetTexturePixelCoordinates(0, 0, healthBarTextureSize, kPlayerHealthBarTextureSize.y)
            healthBar:SetSize(Vector(healthBarSize, kPlayerHealthBarSize.y, 0))
            healthBar:SetColor(healthColor)

            --regen bar
            local regenBar = playerGUI.RegenBar
            local regenBarSize = regenFraction * kPlayerHealthBarSize.x
            local regenTextureSize = regenFraction * kPlayerHealthBarTextureSize.x
            regenBar:SetTexturePixelCoordinates(healthBarTextureSize, 0, healthBarTextureSize + regenTextureSize, kPlayerHealthBarTextureSize.y)
            regenBar:SetSize(Vector(regenBarSize, kPlayerHealthBarSize.y, 0))
            regenBar:SetPosition(Vector(healthBarSize, 0, 0))
            regenBar:SetColor(regenColor)

            -- armor bar
            local armorBar = playerGUI.ArmorBar
            local armorBarSize = armorFraction * kPlayerHealthBarSize.x
            local armorBarTextureSize = armorFraction * kPlayerHealthBarTextureSize.x
            armorBar:SetTexturePixelCoordinates(healthBarTextureSize + regenTextureSize, 0, healthBarTextureSize + regenTextureSize + armorBarTextureSize, kPlayerHealthBarTextureSize.y)
            armorBar:SetSize(Vector(armorBarSize, kPlayerHealthBarSize.y, 0))
            armorBar:SetPosition(Vector(healthBarSize + regenBarSize, 0, 0))
            armorBar:SetColor(armorColor)

            -- health change bar
            local healthChangeBar = playerGUI.HealthChangeBar
            local totalFraction = healthFraction+armorFraction
            local prevTotalFraction = playerGUI.StoredValues.TotalFraction
            if prevTotalFraction > totalFraction then

                healthChangeBar:SetIsVisible(true)
                local changeBarSize = (prevTotalFraction - totalFraction) * kPlayerHealthBarSize.x
                local changeBarTextureSize = (prevTotalFraction - totalFraction) * kPlayerHealthBarTextureSize.x
                healthChangeBar:SetTexturePixelCoordinates(armorBarTextureSize+healthBarTextureSize, 0,  armorBarTextureSize+healthBarTextureSize + changeBarTextureSize, kPlayerHealthBarTextureSize.y)
                healthChangeBar:SetSize(Vector(changeBarSize, kPlayerHealthBarSize.y, 0))
                healthChangeBar:SetPosition(Vector(healthBarSize + armorBarSize, 0, 0))
                playerGUI.StoredValues.TotalFraction = math.max(totalFraction, prevTotalFraction - (deltaTime * kPlayerHealthDrainRate))

            else

                healthChangeBar:SetIsVisible(false)
                playerGUI.StoredValues.TotalFraction = totalFraction

            end

            local energyBG = playerGUI.EnergyBG
            local energyBar = playerGUI.EnergyBar
            local energyFraction = 1.0
            -- Energy bar for aliems
            if player:isa("Alien") then
                energyBG:SetIsVisible(true)
                energyFraction = player:GetEnergy() / player:GetMaxEnergy()
                energyBar:SetColor(kEnergyColor)
                -- Ammo bar for marimes
            else
                local activeWeapon = player:GetActiveWeapon()
                if activeWeapon then
                    local ammoColor = self.kAmmoColors[activeWeapon.kMapName] or kEnergyColor
                    if activeWeapon:isa("ClipWeapon") then
                        energyFraction = activeWeapon:GetClip() / activeWeapon:GetClipSize()
                    elseif activeWeapon:isa("ExoWeaponHolder") then
                        local leftWeapon = Shared.GetEntity(activeWeapon.leftWeaponId)
                        local rightWeapon = Shared.GetEntity(activeWeapon.rightWeaponId)
                        -- Exo weapons. Dual wield will just show as the averaged value for now. Maybe 2 bars eventually?
                        if rightWeapon:isa("Railgun") then
                            energyFraction = rightWeapon:GetChargeAmount()
                            if leftWeapon:isa("Railgun") then
                                energyFraction = (energyFraction + leftWeapon:GetChargeAmount()) / 2.0
                            end
                        elseif rightWeapon:isa("Minigun") then
                            energyFraction = rightWeapon.heatAmount
                            if leftWeapon:isa("Minigun") then
                                energyFraction = (energyFraction + leftWeapon.heatAmount) / 2.0
                            end
                            energyFraction = 1 - energyFraction
                        end
                        ammoColor = self.kAmmoColors[rightWeapon.kMapName]
                    end
                    energyBar:SetColor(ammoColor)
                end
            end
            energyBar:SetTexturePixelCoordinates(0, 0, energyFraction * kEnergyBarTextureSize.x, kEnergyBarTextureSize.y)
            energyBar:SetSize(Vector(kPlayerEnergyBarSize.x * energyFraction, kPlayerEnergyBarSize.y, 0))

        else -- No longer relevant, remove if necessary

            if playerList[playerIndex] then
                GUI.DestroyItem(playerList[playerIndex].Background)
                playerList[playerIndex] = nil
                table.removevalue(playerIds, playerIndex)
            end

        end

    end

end

function GUIInsight_PlayerHealthbars:CreatePlayerGUIItem()

    -- Reuse an existing healthbar item if there is one.
    if table.icount(reusebackgrounds) > 0 then
        local returnbackground = reusebackgrounds[1]
        table.remove(reusebackgrounds, 1)
        return returnbackground
    end

    local playerBackground = GUIManager:CreateGraphicItem()
    playerBackground:SetLayer(kGUILayerPlayerNameTags)
    playerBackground:SetColor(Color(0,0,0,0))

    local playerNameItem = GUIManager:CreateTextItem()
    playerNameItem:SetFontName(kFontName)
    playerNameItem:SetScale(kNameFontScale)
    playerNameItem:SetTextAlignmentX(GUIItem.Align_Center)
    playerNameItem:SetTextAlignmentY(GUIItem.Align_Max)
    GUIMakeFontScale(playerNameItem)
    playerBackground:AddChild(playerNameItem)

    local playerHPItem = GUIManager:CreateTextItem()
    playerHPItem:SetFontName(kFontName)
    playerHPItem:SetScale(kNameFontScale)
    playerHPItem:SetTextAlignmentX(GUIItem.Align_Center)
    playerHPItem:SetTextAlignmentY(GUIItem.Align_Max)
    playerBackground:AddChild(playerHPItem)

    local playerHealthBackground = GUIManager:CreateGraphicItem()
    playerHealthBackground:SetSize(Vector(kPlayerHealthBarSize.x, kPlayerHealthBarSize.y, 0))
    playerHealthBackground:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerHealthBackground:SetColor(Color(0,0,0,0.75))
    playerHealthBackground:SetPosition(Vector(-kPlayerHealthBarSize.x/2, 0, 0))
    playerBackground:AddChild(playerHealthBackground)

    local playerHealthBar = GUIManager:CreateGraphicItem()
    playerHealthBar:SetSize(kPlayerHealthBarSize)
    playerHealthBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerHealthBar:SetTexture(kPlayerHealthBarTexture)
    playerHealthBackground:AddChild(playerHealthBar)

    local playerRegenBar = GUIManager:CreateGraphicItem()
    playerRegenBar:SetSize(kPlayerHealthBarSize)
    playerRegenBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerRegenBar:SetTexture(kPlayerHealthBarTexture)
    playerHealthBackground:AddChild(playerRegenBar)

    local playerArmorBar = GUIManager:CreateGraphicItem()
    playerArmorBar:SetSize(kPlayerHealthBarSize)
    playerArmorBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerArmorBar:SetTexture(kPlayerHealthBarTexture)
    playerHealthBackground:AddChild(playerArmorBar)

    local playerHealthChangeBar = GUIManager:CreateGraphicItem()
    playerHealthChangeBar:SetSize(kPlayerHealthBarSize)
    playerHealthChangeBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerHealthChangeBar:SetTexture(kPlayerHealthBarTexture)
    playerHealthChangeBar:SetColor(kHealthDrainColor)
    playerHealthChangeBar:SetIsVisible(false)
    playerHealthBackground:AddChild(playerHealthChangeBar)

    local playerEnergyBackground = GUIManager:CreateGraphicItem()
    playerEnergyBackground:SetSize(kPlayerEnergyBGSize)
    playerEnergyBackground:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerEnergyBackground:SetColor(Color(0,0,0,0.75))
    playerEnergyBackground:SetPosition(Vector(-kPlayerEnergyBGSize.x/2, kPlayerHealthBarSize.y, 0))
    playerBackground:AddChild(playerEnergyBackground)

    local playerEnergyBar = GUIManager:CreateGraphicItem()
    playerEnergyBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerEnergyBar:SetTexture(kEnergyBarTexture)
    playerEnergyBar:SetPosition(kPlayerEnergyBarOffest)
    playerEnergyBackground:AddChild(playerEnergyBar)

    return { Background = playerBackground, Name = playerNameItem, HPText = playerHPItem, HealthBar = playerHealthBar, RegenBar = playerRegenBar, ArmorBar = playerArmorBar, HealthChangeBar = playerHealthChangeBar, EnergyBG = playerEnergyBackground, EnergyBar = playerEnergyBar, StoredValues = {TotalFraction = -1} }
end

function GUIInsight_PlayerHealthbars:SendKeyEvent(key, down)
    if GetIsBinding(key, "Use") and down
            and not ChatUI_EnteringChatMessage() and not MainMenu_GetIsOpened() then

        self.showHpText = not self.showHpText

        return true
    end
end
