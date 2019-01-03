-- add new tech id
PhoneMod:AddTechId("ARCSpeedBoost")

-- add activation to tech tree
PhoneMod:AddActivation(kTechId.ARCSpeedBoost, nil, nil)

-- add material offset
PhoneMod:AddTechIdToMaterialOffset(kTechId.ARCSpeedBoost, 111) -- onos charge :)

-- add tech data
PhoneMod:AddTech({
	    [kTechDataId] = kTechId.ARCSpeedBoost,
        [kTechDataCostKey] = kARCSpeedBoostCost,
        [kTechDataDisplayName] = "ARC Speed Boost",
        [kTechDataTooltipInfo] =  "ARC Speed Boost:  Temporarily increases the movement speed of this ARC by 20% for " .. ToString(kARCSpeedBoostDuration) .. "s seconds, also makes ARC immune to damage slowdown."
	})
