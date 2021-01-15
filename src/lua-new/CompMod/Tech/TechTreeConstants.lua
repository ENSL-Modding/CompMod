local newTechIds = {
    "AdvancedSwipe",
    "CyberneticBoots",
    "DemolitionsTech",
    "Neurotoxin",
}

for _,v in ipairs(newTechNames) do
    EnumUtils.AppendToEnum(kTechId, v)
end
