local gTierThreeTech
function GetAlienTierThreeFor(techId)

    if not gTierThreeTech then

        gTierThreeTech = {}

        gTierThreeTech[kTechId.Skulk] = kTechId.Xenocide
        gTierThreeTech[kTechId.Gorge] = kTechId.WebTech
        gTierThreeTech[kTechId.Lerk] = kTechId.Umbra
        gTierThreeTech[kTechId.Fade] = kTechId.AdvancedSwipe
        gTierThreeTech[kTechId.Onos] = kTechId.Stomp

    end

    return gTierThreeTech[techId]

end
