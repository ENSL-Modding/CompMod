local oldInit = TunnelEntrance.OnInitialized
function TunnelEntrance:OnInitialized()
    oldInit(self)
    self:UpgradeToTechId(kTechId.InfestedTunnel)
end

local oldCreate = TunnelEntrance.OnCreate
function TunnelEntrance:OnCreate()
    oldCreate(self)

    -- Needed for the minimap labels
    self:SetRelevancyDistance(Math.infinity)
    self:SetExcludeRelevancyMask(bit.bor(kRelevantToReadyRoom, kRelevantToTeam2Unit, kRelevantToTeam2Commander))
end

function TunnelEntrance:GetNametag()
    PROFILE("TunnelEntrance:GetNameTag")
    local id = self:GetId()
    local tunnelManager = GetTeamInfoEntity(kTeam2Index):GetTunnelManager()
    if tunnelManager then
        local type, network = tunnelManager:GetTunnelInfo(id)
        if type and network then
            return string.format("%s %s", type, network)
        end
    end

    return "Tunnel"
end
