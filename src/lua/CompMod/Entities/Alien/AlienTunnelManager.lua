local buttonIndexToNetVarMap = debug.getupvaluex(AlienTunnelManager.GetTechButtons, "buttonIndexToNetVarMap")

function AlienTunnelManager:GetTechDropped(techId)
    local techIndex = techId - kTechId.BuildTunnelEntryOne + 1
    if techIndex >= 1 and techIndex <= 8 then
        return self[buttonIndexToNetVarMap[techIndex]] ~= 0
    end

    return false
end

local networkToTechIds = {
    -- Network 1
    { kTechId.BuildTunnelEntryOne, kTechId.BuildTunnelExitOne },
    -- Network 2
    { kTechId.BuildTunnelEntryTwo, kTechId.BuildTunnelExitTwo },
    -- Network 3
    { kTechId.BuildTunnelEntryThree, kTechId.BuildTunnelExitThree },
    -- Network 4
    { kTechId.BuildTunnelEntryFour, kTechId.BuildTunnelExitFour },
}

function AlienTunnelManager:NetworkToTechId(networkNum, index)
    assert(networkNum)

    if index then
        return networkToTechIds[networkNum][index]
    else
        return networkToTechIds[networkNum]
    end
end

function AlienTunnelManager:IsNetworkAvailable(networkNum)
    self:GetTechButtons()
    local techIds = self:NetworkToTechId(networkNum)
    local valid = true

    for i = 1, #techIds do
        local techId = techIds[i]
        valid = valid and (self:GetTechDropped(techId) or self:GetTechAllowed(techId))
    end

    return valid
end
