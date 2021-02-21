-- Int for tunnel menu. 1 = structure menu, 2 = tunnel network selection, 3 = entrance/exit selection
local menuMode = 1

function GUIGorgeBuildMenu:Initialize()
    GUIAnimatedScript.Initialize(self)
    
    self.kSmokeyBackgroundSize = GUIScale(Vector(220, 400, 0))
    
    self.scale = Client.GetScreenHeight() / GUIGorgeBuildMenu.kBaseYResolution
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetColor(Color(0,0,0,0))
    
    self:SetMenuMode(1)
    -- The reset is handled above
    -- self.buttons = {}
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
        rowTable[kTechId.Web] = 5
        rowTable[kTechId.GorgeTunnelMenuBack] = 6
    end
    
    return rowTable[techId]
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
    table.insert(self.buttons, self:CreateButton(kTechId.GorgeTunnelMenuBack, self.scale, self.background, GorgeBuild_GetKeybindForIndex(1), 0))
    table.insert(self.buttons, self:CreateButton(kTechId.GorgeTunnelMenu, self.scale, self.background, GorgeBuild_GetKeybindForIndex(2), 1))
end

function GUIGorgeBuildMenu:CreateTunnelTypeButtons()
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
        self.buttons[i].background:Destroy() -- maybe?
    end
end

function GUIGorgeBuildMenu:SetMenuMode(mode)
    menuMode = mode

    if self.buttons then
        self:DestroyButtons()
    end

    self.buttons = {}
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
                self:SetMenuMode(2)

                selectPressed = false
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
        Move.SelectPrevWeapon
    }
    local exitRequested = false
    for i = 1, #exitMoves do
        if HasMoveCommand(input.commands, exitMoves[i]) then
            exitRequested = true
            break
        end
    end

    if exitRequested then
        print("Exiting menu")
        self:SetMenuMode(1)
    end

    return input, false
end

function GUIGorgeBuildMenu:InputTunnelTypeSelect(input)
    print("Checking input: InputTunnelTypeSelect")

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

function GorgeBuild_GetIsAbilityAvailable(index)
    if GorgeBuild_IsTunnelIndex(index) then
        return true
    end
    return DropStructureAbility.kSupportedStructures[index] and DropStructureAbility.kSupportedStructures[index]:IsAllowed(Client.GetLocalPlayer())
end

function GorgeBuild_GetCanAffordAbility(techId)
    if techId == kTechId.GorgeTunnelMenu then
        return true
    end

    local player = Client.GetLocalPlayer()
    local abilityCost = LookupTechData(techId, kTechDataCostKey, 0)
    local exceededLimit = not GorgeBuild_AllowConsumeDrop(techId) and GorgeBuild_GetNumStructureBuilt(techId) >= GorgeBuild_GetMaxNumStructure(techId)

    return player:GetResources() >= abilityCost and not exceededLimit
end

debug.setupvaluex(GUIGorgeBuildMenu.Update, "GetRowForTechId", GetRowForTechId, true)
