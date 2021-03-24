local newTechIds = {
    "AdrenalineRush",
    "AdvancedSwipe",
    "DemolitionsTech",
    "Neurotoxin",
    
    -- Gorge Tunnel menus
    "GorgeTunnelMenu",
    "GorgeTunnelMenuBack",
    "GorgeTunnelMenuNetwork1",
    "GorgeTunnelMenuNetwork2",
    "GorgeTunnelMenuNetwork3",
    "GorgeTunnelMenuNetwork4",
    "GorgeTunnelMenuEntrance",
    "GorgeTunnelMenuExit",
}

for _,v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end
