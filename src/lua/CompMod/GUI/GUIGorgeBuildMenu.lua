-- Int for tunnel menu. 1 = structure menu, 2 = tunnel network selection, 3 = entrance/exit selection
local menuMode = 1

-- The index of the selected network, 0 = no selection, 1-4 = networks 1-4
local selectedNetwork = 0

function GUIGorgeBuildMenu:Initialize()
    GUIAnimatedScript.Initialize(self)
    
    self.kSmokeyBackgroundSize = GUIScale(Vector(220, 400, 0))
    
    self.scale = Client.GetScreenHeight() / GUIGorgeBuildMenu.kBaseYResolution
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetColor(Color(0,0,0,0))
    
    self.buttons = {}
    self:SetMenuMode(1)
    -- The reset is handled above
    -- self:Reset()
end

local function GorgeBuild_GetKeybindForIndex(index)
    return "Weapon" .. ToString(index)
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

local oldCreateButton = GUIGorgeBuildMenu.CreateButton
function GUIGorgeBuildMenu:CreateButton(techId, scale, frame, keybind, position)
    local button = oldCreateButton(self, techId, scale, frame, keybind, position)

    -- In vanilla setting the texture pixel coords is only done in the update function, which is fine when the buttons are created in the constructor 
    -- However this causes graphical defects when creating buttons on the fly as the button can (somehow) be rendered before the update function is called
    -- This causes the entire icon grid to display for a single frame instead of the single icon we're after.
    -- Simple fix is to set the texture coordinates when creating the button, this does create duplicated code, but it'll do for now.
    local row = GetRowForTechId(button.techId)
    local col = 1

    if not GorgeBuild_GetCanAffordAbility(button.techId) then
        col = 2
    end
    
    if not GorgeBuild_GetIsAbilityAvailable(position + 1) then
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

local createButtons = {
    GUIGorgeBuildMenu.CreateStructureButtons,
    GUIGorgeBuildMenu.CreateNetworkButtons,
    GUIGorgeBuildMenu.CreateTunnelTypeButtons
}
function GUIGorgeBuildMenu:Reset()
    self.background:SetUniformScale(self.scale)

    createButtons[menuMode](self)
    
    local backgroundXOffset = (#self.buttons * GUIGorgeBuildMenu.kButtonWidth) * -.5
    self.background:SetPosition(Vector(backgroundXOffset, GUIGorgeBuildMenu.kBackgroundYOffset, 0))
end

function GUIGorgeBuildMenu:DestroyButtons()
    for i = 1, #self.buttons do
        self.buttons[i].background:Destroy()
    end

    self.buttons = {}
end

function GUIGorgeBuildMenu:SetMenuMode(mode)
    menuMode = mode
    self:DestroyButtons()
    self:Reset()
end

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
            elseif GorgeBuild_GetIsAbilityAvailable(index) and GorgeBuild_GetCanAffordAbility(self.buttons[index].techId) then
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
            if GorgeBuild_GetIsAbilityAvailable(i) then
                selectedNetwork = i
                self:SetMenuMode(3)
            end

            input.commands = RemoveMoveCommand(input.commands, networkSelectors[i])
            return input, false
        end
    end

    return input, false
end

local function SendTunnelSelect(index)
    local player = Client.GetLocalPlayer()
    
    if player then
        local dropStructureAbility = player:GetWeapon(DropStructureAbility.kMapName)
        if dropStructureAbility and selectedNetwork > 0 then
            dropStructureAbility:SetActiveStructure(-index, selectedNetwork)
        end
    end
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
            selectedNetwork = 0
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
            if GorgeBuild_GetIsAbilityAvailable(i) and GorgeBuild_GetCanAffordAbility(tunnelType[i]) then
                SendTunnelSelect(i)
            end

            input.commands = RemoveMoveCommand(input.commands, tunnelSelectors[i])
            selectedNetwork = 0
            self:SetMenuMode(1)

            return input, true
        end
    end

    return input, false
end

local menuModeFunctionMap = {
    GUIGorgeBuildMenu.InputStructureMenu,
    GUIGorgeBuildMenu.InputTunnelNetworkSelect,
    GUIGorgeBuildMenu.InputTunnelTypeSelect
}
function GUIGorgeBuildMenu:OverrideInput(input)
    return menuModeFunctionMap[menuMode](self, input)
end

local oldGorgeBuild_GetIsAbilityAvailable = GorgeBuild_GetIsAbilityAvailable
function GorgeBuild_GetIsAbilityAvailableStructures(index)
    if GorgeBuild_IsTunnelIndex(index) then
        return true
    end

    return oldGorgeBuild_GetIsAbilityAvailable(index)
end

local kNetworkIndexToCommTunnelTechIdMap = {
    kTechId.BuildTunnelEntryOne,
    kTechId.BuildTunnelEntryTwo,
    kTechId.BuildTunnelEntryThree,
    kTechId.BuildTunnelEntryFour,
}
function GorgeBuild_GetIsAbilityAvailableNetworks(index)
    if index >= 1 and index <= 4 then
        local teamInfo = GetTeamInfoEntity(kTeam2Index)
        local tunnelManager = teamInfo:GetTunnelManager()

        if tunnelManager then
            local allowed = tunnelManager:GetTechAllowed(kNetworkIndexToCommTunnelTechIdMap[index])
            return allowed
        else
            return false
        end
    end

    if index == 5 then -- back button
        return true
    end

    return false
end

local kGorgeTunnelIndexToCommTunnelTechIdMap = {
    -- Network 1
    { kTechId.BuildTunnelEntryOne, kTechId.BuildTunnelExitOne },
    -- Network 2
    { kTechId.BuildTunnelEntryTwo, kTechId.BuildTunnelExitTwo },
    -- Network 3
    { kTechId.BuildTunnelEntryThree, kTechId.BuildTunnelExitThree },
    -- Network 4
    { kTechId.BuildTunnelEntryFour, kTechId.BuildTunnelExitFour },
}
function GorgeBuild_GetIsAbilityAvailableTunnels(index)
    if index >= 1 and index <= 2 then
        local teamInfo = GetTeamInfoEntity(kTeam2Index)
        local tunnelManager = teamInfo:GetTunnelManager()

        if tunnelManager and selectedNetwork > 0 then
            local techId = kGorgeTunnelIndexToCommTunnelTechIdMap[selectedNetwork][index]
            local allowed = tunnelManager:GetTechAllowed(techId)
            -- return allowed
            return true
        else
            return false
        end
    end

    if index == 3 then -- back button
        return true
    end

    return false
end

local AvailableAbilityFunctionMap = {
    GorgeBuild_GetIsAbilityAvailableStructures,
    GorgeBuild_GetIsAbilityAvailableNetworks,
    GorgeBuild_GetIsAbilityAvailableTunnels,
}
function GorgeBuild_GetIsAbilityAvailable(index)
    return AvailableAbilityFunctionMap[menuMode](index)
end

local skipAffordCheckIds = {
    [kTechId.GorgeTunnelMenu] = true,
    [kTechId.GorgeTunnelMenuBack] = true,
    [kTechId.GorgeTunnelMenuNetwork1] = true,
    [kTechId.GorgeTunnelMenuNetwork2] = true,
    [kTechId.GorgeTunnelMenuNetwork3] = true,
    [kTechId.GorgeTunnelMenuNetwork4] = true,
    -- [kTechId.GorgeTunnelMenuEntrance] = true,
    -- [kTechId.GorgeTunnelMenuExit] = true,
}
local oldGorgeBuild_GetCanAffordAbility = GorgeBuild_GetCanAffordAbility
function GorgeBuild_GetCanAffordAbility(techId)
    return skipAffordCheckIds[techId] or oldGorgeBuild_GetCanAffordAbility(techId)
end

local oldGorgeBuild_GetNumStructureBuilt = GorgeBuild_GetNumStructureBuilt
function GorgeBuild_GetNumStructureBuilt(techId)
    local teamInfo = GetTeamInfoEntity(kTeam2Index)
    local tunnelManager = GetTeamInfoEntity(kTeam2Index):GetTunnelManager()

    if techId == kTechId.GorgeTunnelMenuEntrance or techId == kTechId.GorgeTunnelMenuExit and selectedNetwork > 0 then
        local techIndex = techId - kTechId.GorgeTunnelMenuEntrance + 1
        local commTechId = kGorgeTunnelIndexToCommTunnelTechIdMap[selectedNetwork][techIndex]
        return tunnelManager:GetTechDropped(commTechId) and 1 or 0
    end

    if techId >= kTechId.GorgeTunnelMenuNetwork1 and techId <= kTechId.GorgeTunnelMenuNetwork4 then
        local techIndex = techId - kTechId.GorgeTunnelMenuNetwork1 + 1
        local oldSelectedNetwork = selectedNetwork
        selectedNetwork = techIndex
        local entranceCount = GorgeBuild_GetNumStructureBuilt(kTechId.GorgeTunnelMenuEntrance)
        local exitCount = GorgeBuild_GetNumStructureBuilt(kTechId.GorgeTunnelMenuExit)
        selectedNetwork = oldSelectedNetwork -- this should always be 0 but just to be safe :)

        return entranceCount + exitCount
    end

    return oldGorgeBuild_GetNumStructureBuilt(techId)
end

debug.setupvaluex(GUIGorgeBuildMenu.Update, "GetRowForTechId", GetRowForTechId, true)
