local newTechIds = {
    "AdvancedSwipe",
    "CyberneticBoots",
    "DemolitionsTech",
    "Neurotoxin",
}

for _,v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end
