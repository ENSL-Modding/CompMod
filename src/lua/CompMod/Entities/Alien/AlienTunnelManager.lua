local buttonIndexToNetVarMap = debug.getupvaluex(AlienTunnelManager.GetTechButtons, "buttonIndexToNetVarMap")

function AlienTunnelManager:GetTunnelInfo(entId)
    PROFILE("AlienTunnelManager:GetTunnelInfo")
    for i = 1, 8 do
        if self[buttonIndexToNetVarMap[i]] == entId then
            local type = i > 4 and "Exit" or "Entry"
            local network = ((i-1) % 4)+1
            return type, network
        end
    end

    return nil, nil
end

function AlienTunnelManager:GetEntityId(techId)
    PROFILE("AlienTunnelManager:GetEntityId")
    local techIndex = techId - kTechId.BuildTunnelEntryOne
    return self[buttonIndexToNetVarMap[techIndex]]
end

function AlienTunnelManager:GetTechDropped(techId)
    PROFILE("AlienTunnelManager:GetTechDropped")
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
    PROFILE("AlienTunnelManager:NetworkToTechId")
    assert(networkNum)

    if index then
        return networkToTechIds[networkNum][index]
    else
        return networkToTechIds[networkNum]
    end
end

function AlienTunnelManager:IsNetworkAvailable(networkNum)
    PROFILE("AlienTunnelManager:IsNetworkAvailable")
    self:GetTechButtons()
    local techIds = self:NetworkToTechId(networkNum)
    local valid = true

    for i = 1, #techIds do
        local techId = techIds[i]
        valid = valid and (self:GetTechDropped(techId) or self:GetTechAllowed(techId))
    end

    return valid
end

function AlienTunnelManager:GetTunnelNameTag(id)
    PROFILE("AlienTunnelManager:GetTunnelNameTag")
    local type, network = self:GetTunnelInfo(id)
    if type and network then
        return string.format("%s %s", type, network)
    end

    return "Tunnel"
end
