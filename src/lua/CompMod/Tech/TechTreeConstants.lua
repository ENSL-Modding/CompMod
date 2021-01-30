local newTechIds = {
    "AdvancedSwipe",
    "DemolitionsTech",
    "Neurotoxin",
}

for _,v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end
