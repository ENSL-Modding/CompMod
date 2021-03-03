local oldInit = TunnelEntrance.OnInitialized
function TunnelEntrance:OnInitialized()
    oldInit(self)
    self:UpgradeToTechId(kTechId.InfestedTunnel)
end

local oldCreate = TunnelEntrance.OnCreate
function TunnelEntrance:OnCreate()
    oldCreate(self)

    -- Needed for the minimap labels
    -- I know... Hopefully no one's walling :}}}
    self:SetRelevancyDistance(Math.infinity)
end
