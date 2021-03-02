local buttonIndexToNetVarMap = debug.getupvaluex(AlienTunnelManager.GetTechButtons, "buttonIndexToNetVarMap")

function AlienTunnelManager:GetTechDropped(techId)
    local techIndex = techId - kTechId.BuildTunnelEntryOne + 1
    if techIndex >= 1 and techIndex <= 8 then
        return self[buttonIndexToNetVarMap[techIndex]] ~= 0
    end

    return false
end

-- function AlienTunnelManager:GetTunnelEntrance(techId)
--     local techIndex = techId - kTechId.SelectTunnelEntryOne + 1
--     if techIndex > 8 then return end

--     local entranceId = self[buttonIndexToNetVarMap[techIndex]]
--     local entrance = (entranceId and entranceId ~= 0) and Shared.GetEntity(entranceId)

--     return entrance
-- end
