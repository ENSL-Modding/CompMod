Script.Load("lua/CompMod/Weapons/Alien/TunnelEntranceAbility.lua")
Script.Load("lua/CompMod/Weapons/Alien/TunnelExitAbility.lua")

local tunnelDropAbilities = {
    TunnelEntranceAbility,
    TunnelExitAbility
}

function DropStructureAbility:GetActiveStructure()
    if self.activeStructure == nil then
        return nil
    end

    if self.activeStructure >= -2 and self.activeStructure <= -1 then
        return tunnelDropAbilities[-self.activeStructure]
    end

    return DropStructureAbility.kSupportedStructures[self.activeStructure]
end

local oldSetActiveStructure = DropStructureAbility.SetActiveStructure
function DropStructureAbility:SetActiveStructure(structureNum, tunnelNetwork)
    oldSetActiveStructure(self, structureNum)

    if self.activeStructure ~= nil and self.activeStructure < 0 then
        self:GetActiveStructure():SetNetwork(tunnelNetwork)
    end
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
function DropStructureAbility:GetNumStructuresBuilt(techId)
    if techId == kTechId.Hydra then
        return self.numHydrasLeft
    end

    if techId == kTechId.Clog then
        return self.numClogsLeft
    end

    if techId == kTechId.Web then
        return self.numWebsLeft
    end

    if techId == kTechId.BabblerEgg then
        return self.numBabblersLeft
    end

    if techId == kTechId.GorgeTunnelMenuEntrance or techId == kTechId.GorgeTunnelMenuExit then
        if self.activeStructure ~= nil then
            local network = self:GetActiveStructure():GetNetwork()
            local teamInfo = GetTeamInfoEntity(kTeam2Index)
            local tunnelManager = teamInfo:GetTunnelManager()
            local index = techId - kTechId.GorgeTunnelMenuEntrance + 1
            return tunnelManager:GetTechDropped(kGorgeTunnelIndexToCommTunnelTechIdMap[network][index]) and 1 or 0
        else
            return 0
        end
    end

    -- unlimited
    return -1
end

function DropStructureAbility:OnDropStructure(origin, direction, structureIndex, lastClickedPosition, lastClickedPositionNormal, tunnelNetwork)
    local player = self:GetParent()
    
    if player then
        local structureAbility
        if structureIndex < 0 then
            structureAbility = tunnelDropAbilities[-structureIndex]
            structureAbility:SetNetwork(tunnelNetwork)
        else
            structureAbility = DropStructureAbility.kSupportedStructures[structureIndex]
        end

        if structureAbility then
            self:DropStructure(player, origin, direction, structureAbility, lastClickedPosition, lastClickedPositionNormal)
        end
    end
end

function DropStructureAbility:PerformPrimaryAttack(player)
    if self.activeStructure == nil then
        return false
    end

    local success = false

    -- Ensure the current location is valid for placement.
    local coords, valid, _, normal = self:GetPositionForStructure(player:GetEyePos(), player:GetViewCoords().zAxis, self:GetActiveStructure(), self.lastClickedPosition, self.lastClickedPositionNormal)
    local secondClick = true

    if LookupTechData(self:GetActiveStructure().GetDropStructureId(), kTechDataSpecifyOrientation, false) then
        secondClick = self.lastClickedPosition ~= nil
    end

    if secondClick then
        if valid then
            -- Ensure they have enough resources.
            local cost = GetCostForTech(self:GetActiveStructure().GetDropStructureId())
            if player:GetResources() >= cost and not self:GetHasDropCooldown() then
                local activeStructure = self:GetActiveStructure()
                local network = activeStructure.GetNetwork and activeStructure:GetNetwork() or 0
                local message = BuildGorgeDropStructureMessage(player:GetEyePos(), player:GetViewCoords().zAxis, self.activeStructure, self.lastClickedPosition, self.lastClickedPositionNormal, network)
                Client.SendNetworkMessage("GorgeBuildStructure", message, true)
                self.timeLastDrop = Shared.GetTime()
                success = true
            end
        end

        self.lastClickedPosition = nil
        self.lastClickedPositionNormal = nil
    elseif valid then
        self.lastClickedPosition = Vector(coords.origin)
        self.lastClickedPositionNormal = normal
    end

    if not valid then
        player:TriggerInvalidSound()
    end

    return success
end
