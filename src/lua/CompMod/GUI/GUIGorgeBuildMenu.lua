local GorgeBuild_GetKeybindForIndex = debug.getupvaluex(GUIGorgeBuildMenu.Reset, "GorgeBuild_GetKeybindForIndex")

function GUIGorgeBuildMenu:Initialize()
    GUIAnimatedScript.Initialize(self)
    
    self.kSmokeyBackgroundSize = GUIScale(Vector(220, 400, 0))
    
    self.scale = Client.GetScreenHeight() / GUIGorgeBuildMenu.kBaseYResolution
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetColor(Color(0,0,0,0))
    
    self.buttons = {}

    -- The index of the selected network, 0 = no selection, 1-4 = networks 1-4
    self.selectedNetwork = 0

    -- Int for tunnel menu. 1 = structure menu, 2 = tunnel network selection, 3 = entrance/exit selection
    self.menuMode = 0
    self:SetMenuMode(1)
end

local rowTable
local function GetRowForTechId(techId)
    if not rowTable then
        rowTable = {}
        rowTable[kTechId.Hydra] = 1
        rowTable[kTechId.BabblerEgg] = 2
        rowTable[kTechId.Clog] = 3
        rowTable[kTechId.GorgeTunnelMenu] = 4
        rowTable[kTechId.GorgeTunnelMenuNetwork1] = 4
        rowTable[kTechId.GorgeTunnelMenuNetwork2] = 4
        rowTable[kTechId.GorgeTunnelMenuNetwork3] = 4
        rowTable[kTechId.GorgeTunnelMenuNetwork4] = 4

        -- TODO: New icons for entrances/exits (Probably borrow the icons from the commander :})
        rowTable[kTechId.GorgeTunnelMenuEntrance] = 4
        rowTable[kTechId.GorgeTunnelMenuExit] = 4
        rowTable[kTechId.Web] = 5
        rowTable[kTechId.GorgeTunnelMenuBack] = 6
    end
    
    return rowTable[techId]
end
debug.setupvaluex(GUIGorgeBuildMenu.Update, "GetRowForTechId", GetRowForTechId, true)

local oldCreateButton = GUIGorgeBuildMenu.CreateButton
function GUIGorgeBuildMenu:CreateButton(techId, scale, frame, keybind, position)
    local button = oldCreateButton(self, techId, scale, frame, keybind, position)

    -- In vanilla setting the texture pixel coords is only done in the update function, which is fine when the buttons are created in the constructor 
    -- However this causes graphical defects when creating buttons on the fly as the button can (somehow) be rendered before the update function is called
    -- This causes the entire icon grid to display for a single frame instead of the single icon we're after.
    -- Simple fix is to set the texture coordinates when creating the button, this does create duplicated code, but it'll do for now.
    local row = GetRowForTechId(button.techId)
    local col = 1

    if not self:GetCanAffordAbility(button.techId) then
        col = 2
    end
    
    if not self:GetIsAbilityAvailable(position + 1) then
        col = 3
    end
    button.graphicItem:SetTexturePixelCoordinates(GUIGetSprite(col, row, GUIGorgeBuildMenu.kPixelSize, GUIGorgeBuildMenu.kPixelSize))

    return button
end

function GorgeBuild_GetTunnelIndex()
    return #DropStructureAbility.kSupportedStructures + 1
end

function GorgeBuild_GetTunnelKeybind()
    return GorgeBuild_GetKeybindForIndex(GorgeBuild_GetTunnelIndex())
end

function GorgeBuild_IsTunnelIndex(index)
    return index == GorgeBuild_GetTunnelIndex()
end

function GUIGorgeBuildMenu:DestroyButtons()
    for i = 1, #self.buttons do
        self.buttons[i].background:Destroy()
    end

    self.buttons = {}
end

function GUIGorgeBuildMenu:SetMenuMode(mode)
    self.menuMode = mode
    self:DestroyButtons()
    self:Reset()
end

local function SendTunnelSelect(self, index)
    local player = Client.GetLocalPlayer()
    
    if player then
        local dropStructureAbility = player:GetWeapon(DropStructureAbility.kMapName)
        if dropStructureAbility and self.selectedNetwork > 0 then
            dropStructureAbility:SetActiveStructure(-index, self.selectedNetwork)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- Create Buttons                                                                                 --
----------------------------------------------------------------------------------------------------

function GUIGorgeBuildMenu:CreateStructureButtons()
    for index, structureAbility in ipairs(DropStructureAbility.kSupportedStructures) do
        -- TODO: pass keybind from options instead of index
        table.insert(self.buttons, self:CreateButton(structureAbility.GetDropStructureId(), self.scale, self.background, GorgeBuild_GetKeybindForIndex(index), index - 1))
    end

    table.insert(self.buttons, self:CreateButton(kTechId.GorgeTunnelMenu, self.scale, self.background, GorgeBuild_GetTunnelKeybind(), GorgeBuild_GetTunnelIndex() - 1))
end

function GUIGorgeBuildMenu:CreateNetworkButtons()
    table.insert(self.buttons, self:CreateButton(kTechId.GorgeTunnelMenuNetwork1,   self.scale, self.background, GorgeBuild_GetKeybindForIndex(1), 0))
    table.insert(self.buttons, self:CreateButton(kTechId.GorgeTunnelMenuNetwork2,   self.scale, self.background, GorgeBuild_GetKeybindForIndex(2), 1))
    table.insert(self.buttons, self:CreateButton(kTechId.GorgeTunnelMenuNetwork3,   self.scale, self.background, GorgeBuild_GetKeybindForIndex(3), 2))
    table.insert(self.buttons, self:CreateButton(kTechId.GorgeTunnelMenuNetwork4,   self.scale, self.background, GorgeBuild_GetKeybindForIndex(4), 3))
    table.insert(self.buttons, self:CreateButton(kTechId.GorgeTunnelMenuBack,       self.scale, self.background, GorgeBuild_GetKeybindForIndex(5), 4))
end

function GUIGorgeBuildMenu:CreateTunnelTypeButtons()
    table.insert(self.buttons, self:CreateButton(kTechId.GorgeTunnelMenuEntrance,   self.scale, self.background, GorgeBuild_GetKeybindForIndex(1), 0))
    table.insert(self.buttons, self:CreateButton(kTechId.GorgeTunnelMenuExit,       self.scale, self.background, GorgeBuild_GetKeybindForIndex(2), 1))
    table.insert(self.buttons, self:CreateButton(kTechId.GorgeTunnelMenuBack,       self.scale, self.background, GorgeBuild_GetKeybindForIndex(3), 2))
end

local createButtonsMenuModeMap = {
    GUIGorgeBuildMenu.CreateStructureButtons,
    GUIGorgeBuildMenu.CreateNetworkButtons,
    GUIGorgeBuildMenu.CreateTunnelTypeButtons
}
function GUIGorgeBuildMenu:Reset()
    self.background:SetUniformScale(self.scale)

    createButtonsMenuModeMap[self.menuMode](self)
    
    local backgroundXOffset = (#self.buttons * GUIGorgeBuildMenu.kButtonWidth) * -.5
    self.background:SetPosition(Vector(backgroundXOffset, GUIGorgeBuildMenu.kBackgroundYOffset, 0))
end

----------------------------------------------------------------------------------------------------
-- Input Handling                                                                                 --
----------------------------------------------------------------------------------------------------

function GUIGorgeBuildMenu:InputStructureMenu(input)
    -- Assume the user wants to switch the top-level weapons
    if HasMoveCommand(input.commands, Move.SelectNextWeapon) or HasMoveCommand(input.commands, Move.SelectPrevWeapon) then
        GorgeBuild_OnClose()
        GorgeBuild_Close()
        return input
    end

    local weaponSwitchCommands = { Move.Weapon1, Move.Weapon2, Move.Weapon3, Move.Weapon4, Move.Weapon5 }
    local selectPressed = false

    for index, weaponSwitchCommand in ipairs(weaponSwitchCommands) do
        if HasMoveCommand(input.commands, weaponSwitchCommand) then
            selectPressed = true

            if GorgeBuild_IsTunnelIndex(index) then
                selectPressed = false
                self:SetMenuMode(2)
                input.commands = RemoveMoveCommand(input.commands, weaponSwitchCommand)
            elseif self:GetIsAbilityAvailable(index) and self:GetCanAffordAbility(self.buttons[index].techId) then
                GorgeBuild_SendSelect(index)
                input.commands = RemoveMoveCommand(input.commands, weaponSwitchCommand)
            end
            
            break
        end
    end
    
    if selectPressed then
        GorgeBuild_OnClose()
        GorgeBuild_Close()
    elseif HasMoveCommand(input.commands, Move.SecondaryAttack) or HasMoveCommand(input.commands, Move.PrimaryAttack) then
        -- close menu
        GorgeBuild_OnClose()
        GorgeBuild_Close()

        -- leave the secondary attack command so the drop-ability can handle it
        input.commands = AddMoveCommand(input.commands, Move.SecondaryAttack)
        input.commands = RemoveMoveCommand(input.commands, Move.PrimaryAttack)
    end

    return input, selectPressed
end

function GUIGorgeBuildMenu:InputTunnelNetworkSelect(input)
    local exitMoves = {
        Move.PrimaryAttack,
        Move.SecondaryAttack,
        Move.SelectNextWeapon,
        Move.SelectPrevWeapon,
        Move.Weapon5
    }
    for i = 1, #exitMoves do
        if HasMoveCommand(input.commands, exitMoves[i]) then
            self:SetMenuMode(1)
            input.commands = RemoveMoveCommand(input.commands, exitMoves[i])
            return input, false
        end
    end

    local networkSelectors = {
        Move.Weapon1,
        Move.Weapon2,
        Move.Weapon3,
        Move.Weapon4,
    }
    for i = 1, #networkSelectors do
        if HasMoveCommand(input.commands, networkSelectors[i]) then
            if self:GetIsAbilityAvailable(i) then
                self.selectedNetwork = i
                self:SetMenuMode(3)
            end

            input.commands = RemoveMoveCommand(input.commands, networkSelectors[i])
            return input, false
        end
    end

    return input, false
end

function GUIGorgeBuildMenu:InputTunnelTypeSelect(input)
    local exitMoves = {
        Move.PrimaryAttack,
        Move.SecondaryAttack,
        Move.SelectNextWeapon,
        Move.SelectPrevWeapon,
        Move.Weapon3
    }
    for i = 1, #exitMoves do
        if HasMoveCommand(input.commands, exitMoves[i]) then
            self.selectedNetwork = 0
            self:SetMenuMode(2)
            input.commands = RemoveMoveCommand(input.commands, exitMoves[i])
            return input, false
        end
    end
    
    local tunnelSelectors = {
        Move.Weapon1,
        Move.Weapon2
    }
    local tunnelType = {
        kTechId.GorgeTunnelMenuEntrance,
        kTechId.GorgeTunnelMenuExit,
    }
    for i = 1, #tunnelSelectors do
        if HasMoveCommand(input.commands, tunnelSelectors[i]) then
            if self:GetIsAbilityAvailable(i) and self:GetCanAffordAbility(tunnelType[i]) then
                SendTunnelSelect(self, i)
            end

            input.commands = RemoveMoveCommand(input.commands, tunnelSelectors[i])
            self.selectedNetwork = 0
            self:SetMenuMode(1)

            return input, true
        end
    end

    return input, false
end

local overrideInputMenuModeFunctionMap = {
    GUIGorgeBuildMenu.InputStructureMenu,
    GUIGorgeBuildMenu.InputTunnelNetworkSelect,
    GUIGorgeBuildMenu.InputTunnelTypeSelect
}
function GUIGorgeBuildMenu:OverrideInput(input)
    return overrideInputMenuModeFunctionMap[self.menuMode](self, input)
end

----------------------------------------------------------------------------------------------------
-- GetAbilityAvailable Handling                                                                   --
----------------------------------------------------------------------------------------------------

local oldGorgeBuild_GetIsAbilityAvailable = GorgeBuild_GetIsAbilityAvailable
function GUIGorgeBuildMenu:GetIsAbilityAvailableStructures(index)
    if GorgeBuild_IsTunnelIndex(index) then
        return true
    end

    return oldGorgeBuild_GetIsAbilityAvailable(index)
end

function GUIGorgeBuildMenu:GetIsAbilityAvailableNetworks(index)
    if index >= 1 and index <= 4 then
        local teamInfo = GetTeamInfoEntity(kTeam2Index)
        local tunnelManager = teamInfo:GetTunnelManager()

        if tunnelManager then
            return tunnelManager:IsNetworkAvailable(index)
        else
            return false
        end
    end

    if index == 5 then -- back button
        return true
    end

    return false
end

function GUIGorgeBuildMenu:GetIsAbilityAvailableTunnels(index)
    if index >= 1 and index <= 2 then
        local teamInfo = GetTeamInfoEntity(kTeam2Index)
        local tunnelManager = teamInfo:GetTunnelManager()

        if tunnelManager and self.selectedNetwork > 0 then
            return tunnelManager:IsNetworkAvailable(self.selectedNetwork)
        else
            return false
        end
    end

    if index == 3 then -- back button
        return true
    end

    return false
end

local availableAbilityMenuModeFunctionMap = {
    GUIGorgeBuildMenu.GetIsAbilityAvailableStructures,
    GUIGorgeBuildMenu.GetIsAbilityAvailableNetworks,
    GUIGorgeBuildMenu.GetIsAbilityAvailableTunnels,
}
function GUIGorgeBuildMenu:GetIsAbilityAvailable(index)
    return availableAbilityMenuModeFunctionMap[self.menuMode](self, index)
end

local skipAffordCheckIds = {
    [kTechId.GorgeTunnelMenu] = true,
    [kTechId.GorgeTunnelMenuBack] = true,
    [kTechId.GorgeTunnelMenuNetwork1] = true,
    [kTechId.GorgeTunnelMenuNetwork2] = true,
    [kTechId.GorgeTunnelMenuNetwork3] = true,
    [kTechId.GorgeTunnelMenuNetwork4] = true,
}
function GUIGorgeBuildMenu:GetCanAffordAbility(techId)
    if skipAffordCheckIds[techId] then
        return true
    end

    local player = Client.GetLocalPlayer()
    local abilityCost = LookupTechData(techId, kTechDataCostKey, 0)
    local exceededLimit = not GorgeBuild_AllowConsumeDrop(techId) and self:GetNumStructureBuilt(techId) >= GorgeBuild_GetMaxNumStructure(techId)

    return player:GetResources() >= abilityCost and not exceededLimit
end

local oldGorgeBuild_GetNumStructureBuilt = GorgeBuild_GetNumStructureBuilt
function GUIGorgeBuildMenu:GetNumStructureBuilt(techId)
    local teamInfo = GetTeamInfoEntity(kTeam2Index)
    local tunnelManager = GetTeamInfoEntity(kTeam2Index):GetTunnelManager()

    if (techId == kTechId.GorgeTunnelMenuEntrance or techId == kTechId.GorgeTunnelMenuExit) and self.selectedNetwork > 0 then
        local techIndex = techId - kTechId.GorgeTunnelMenuEntrance + 1
        local commTechId = tunnelManager:NetworkToTechId(self.selectedNetwork, techIndex)
        return tunnelManager:GetTechDropped(commTechId) and 1 or 0
    end

    if techId >= kTechId.GorgeTunnelMenuNetwork1 and techId <= kTechId.GorgeTunnelMenuNetwork4 then
        local techIndex = techId - kTechId.GorgeTunnelMenuNetwork1 + 1
        local oldSelectedNetwork = self.selectedNetwork
        self.selectedNetwork = techIndex
        local entranceCount = self:GetNumStructureBuilt(kTechId.GorgeTunnelMenuEntrance)
        local exitCount = self:GetNumStructureBuilt(kTechId.GorgeTunnelMenuExit)
        self.selectedNetwork = oldSelectedNetwork -- this should always be 0 but just to be safe :)

        return entranceCount + exitCount
    end

    return oldGorgeBuild_GetNumStructureBuilt(techId)
end

local kDefaultStructureCountPos = Vector(-48, -24, 0)
local kCenteredStructureCountPos = Vector(0, -24, 0)
local function UpdateButton(self, button, index)
    local col = 1
    local color = GUIGorgeBuildMenu.kAvailableColor

    if not self:GetCanAffordAbility(button.techId) then
        col = 2
        color = GUIGorgeBuildMenu.kTooExpensiveColor
    end
    
    if not self:GetIsAbilityAvailable(index) then
        col = 3
        color = GUIGorgeBuildMenu.kUnavailableColor
    end
    
    local row = GetRowForTechId(button.techId)

    button.smokeyBackground:SetIsVisible(Client.GetHudDetail() ~= kHUDMode.Minimal)
    button.graphicItem:SetTexturePixelCoordinates(GUIGetSprite(col, row, GUIGorgeBuildMenu.kPixelSize, GUIGorgeBuildMenu.kPixelSize))
    button.description:SetColor(color)
    button.costIcon:SetColor(color)
    button.costText:SetColor(color)

    local numLeft = self:GetNumStructureBuilt(button.techId)
    if numLeft == -1 then
        button.structuresLeft:SetIsVisible(false)
    else
        button.structuresLeft:SetIsVisible(true)
        local amountString = ToString(numLeft)
        local maxNum = GorgeBuild_GetMaxNumStructure(button.techId)
        
        if maxNum > 0 then
            amountString = amountString .. "/" .. ToString(maxNum)
        end
        
        if numLeft >= maxNum then
            color = GUIGorgeBuildMenu.kTooExpensiveColor
        end
        
        button.structuresLeft:SetColor(color)
        button.structuresLeft:SetText(amountString)
    end    
    
    local cost = GorgeBuild_GetStructureCost(button.techId)
    if cost == 0 then        
        button.costIcon:SetIsVisible(false)
        button.structuresLeft:SetPosition(kCenteredStructureCountPos)
    else
        button.costIcon:SetIsVisible(true)
        button.costText:SetText(ToString(cost))
        button.structuresLeft:SetPosition(kDefaultStructureCountPos) 
    end
end

function GUIGorgeBuildMenu:Update(deltaTime)
    PROFILE("GUIGorgeBuildMenu:Update")
    GUIAnimatedScript.Update(self, deltaTime)

    for index, button in ipairs(self.buttons) do
        UpdateButton(self, button, index)
    end
end
