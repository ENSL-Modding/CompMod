function MarineTeam:AddPlayer(player)
    PlayingTeam.AddPlayer(self, player)
end

function MarineTeam:SpawnInitialStructures(techPoint)

    self.warmupStructures = {}
    self.startTechPoint = techPoint
    self.spawnedInfantryPortal = 0
    takenInfantryPortalPoints = {}

    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)

    self:SpawnInfantryPortal(techPoint)

    if Shared.GetCheatsEnabled() and MarineTeam.gSandboxMode then
        MakeTechEnt(techPoint, AdvancedArmory.kMapName, 3.5, -2, kMarineTeamType)
        MakeTechEnt(techPoint, PrototypeLab.kMapName, -3.5, 2, kMarineTeamType)
    end

    return tower, commandStation

end