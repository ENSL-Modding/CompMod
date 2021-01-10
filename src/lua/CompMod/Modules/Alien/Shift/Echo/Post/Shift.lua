function Shift:GetTechButtons(techId)
    local techButtons
                
    if techId == kTechId.ShiftEcho then
        techButtons = { kTechId.TeleportEgg, kTechId.TeleportWhip, kTechId.TeleportHarvester, kTechId.TeleportShift,
                        kTechId.TeleportCrag, kTechId.TeleportShade, kTechId.TeleportHive, kTechId.RootMenu }
        
        if self.veilInRange then
            techButtons[7] = kTechId.TeleportVeil
        elseif self.shellInRange then
            techButtons[7] = kTechId.TeleportShell
        elseif self.spurInRange then
            techButtons[7] = kTechId.TeleportSpur
        end
    else
        techButtons = { kTechId.ShiftEcho, kTechId.Move, kTechId.ShiftEnergize, kTechId.None,
                        kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
                        
        if self.moving then
            techButtons[2] = kTechId.Stop
        end
    end

    return techButtons
end