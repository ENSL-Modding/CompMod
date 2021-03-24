local networkVars =
{
    adrenalineRushActive = "boolean"
}

Shift.kAdrenalineRushDuration = 5.0

local oldOnCreate = Shift.OnCreate
function Shift:OnCreate()
    oldOnCreate(self)
    
    self.adrenalineRushActive = false

    if Server then
        self.timeLastAdrenalineRush = 0
    end
end

function Shift:OnUpdate(deltaTime)
    PROFILE("Shift:OnUpdate")

    ScriptActor.OnUpdate(self, deltaTime)
    UpdateAlienStructureMove(self, deltaTime)        

    if Server then
        if not self.timeLastButtonCheck or self.timeLastButtonCheck + 2 < Shared.GetTime() then
            self.timeLastButtonCheck = Shared.GetTime()
            UpdateShiftButtons(self)
        end
        
        self.echoActive = self.timeLastEcho + kEchoCooldown > Shared.GetTime()
        self.adrenalineRushActive = self.timeLastAdrenalineRush + Shift.kAdrenalineRushDuration and self.timeLastAdrenalineRush > 0
    end
end

function Shift:EnergizeInRange()
    if self:GetIsBuilt() and not self:GetIsOnFire() then
        local energizeAbles = GetEntitiesWithMixinForTeamWithinXZRange("Energize", self:GetTeamNumber(), self:GetOrigin(), kEnergizeRange)
        for _, entity in ipairs(energizeAbles) do
            if entity ~= self then
                entity:Energize(self)
            end 
        end

        local adrenalineRushAbles = GetEntitiesWithMixinForTeamWithinXZRange("AdrenalineRush", self:GetTeamNumber(), self:GetOrigin(), kEnergizeRange)
        for _, entity in ipairs(adrenalineRushAbles) do
            if entity ~= self then
                entity:AdrenalineRush(self)
            end
        end
    end
    
    return self:GetIsAlive() 
end

if Server then
    function Shift:PerformActivation(techId, position, normal, commander)
        local success = false
        local continue = true
        
        if GetIsTeleport(techId) then
            success = self:TriggerEcho(techId, position)
            if success then
                UpdateShiftButtons(self)
                Shared.PlayPrivateSound(commander, Shift.kShiftEchoSound2D, nil, 1.0, self:GetOrigin())                
            end
        elseif techId == kTechId.AdrenalineRush then
            success = self:TriggerAdrenalineRush(commander)
        end
        
        return success, continue
    end

    function Shift:TriggerAdrenalineRush(commander)
        self.timeLastAdrenalineRush = Shared.GetTime()
        return true
    end
end

function Shift:GetTechButtons(techId)
    local techButtons
                
    if techId == kTechId.ShiftEcho then
        techButtons = { kTechId.TeleportEgg,    kTechId.TeleportWhip,   kTechId.TeleportHarvester,  kTechId.TeleportShift, 
                        kTechId.TeleportCrag,   kTechId.TeleportShade,  kTechId.None,               kTechId.RootMenu }
        
        if self.veilInRange then
            techButtons[7] = kTechId.TeleportVeil
        elseif self.shellInRange then
            techButtons[7] = kTechId.TeleportShell
        elseif self.spurInRange then
            techButtons[7] = kTechId.TeleportSpur
        end
    else
        techButtons = { kTechId.ShiftEcho,  kTechId.Move,   kTechId.AdrenalineRush,  kTechId.ShiftEnergize, 
                        kTechId.None,       kTechId.None,   kTechId.None,           kTechId.Consume }
                        
        if self.moving then
            techButtons[2] = kTechId.Stop
        end
    end

    return techButtons
end

function Shift:GetTechAllowed(techId, techNode, player)
    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player) 
    
    allowed = allowed and not self:GetIsOnFire()

    if GetIsTeleport(techId) then
        allowed = allowed and not self.echoActive
    end
    
    if allowed then
        if techId == kTechId.TeleportHydra then
            allowed = self.hydraInRange
        elseif techId == kTechId.TeleportWhip then
            allowed = self.whipInRange
        elseif techId == kTechId.TeleportTunnel then
            allowed = self.tunnelInRange
        elseif techId == kTechId.TeleportCrag then
            allowed = self.cragInRange
        elseif techId == kTechId.TeleportShade then
            allowed = self.shadeInRange
        elseif techId == kTechId.TeleportShift then
            allowed = self.shiftInRange
        elseif techId == kTechId.TeleportVeil then
            allowed = self.veilInRange
        elseif techId == kTechId.TeleportSpur then
            allowed = self.spurInRange
        elseif techId == kTechId.TeleportShell then
            allowed = self.shellInRange
        elseif techId == kTechId.TeleportHive then
            allowed = self.hiveInRange
        elseif techId == kTechId.TeleportEgg then
            allowed = self.eggInRange
        elseif techId == kTechId.TeleportHarvester then
            allowed = self.harvesterInRange
        end
    end
    
    return allowed, canAfford 
end

Shared.LinkClassToMap("Shift", Shift.kMapName, networkVars)