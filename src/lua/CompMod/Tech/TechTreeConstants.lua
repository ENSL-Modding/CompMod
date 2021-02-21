local newTechIds = {
    "AdvancedSwipe",
    "DemolitionsTech",
    "Neurotoxin",
    
    -- Gorge Tunnel menus
    "GorgeTunnelMenu",
    "GorgeTunnelMenuBack",
}

for _,v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end
