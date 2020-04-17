function Armory:OnResearchComplete(researchId)

    if researchId == kTechId.AdvancedArmoryUpgrade then

        self:SetTechId(kTechId.AdvancedArmory)

    end

end