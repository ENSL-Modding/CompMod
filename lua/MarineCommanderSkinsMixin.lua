-- ======= Copyright (c) 2003-2018, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\MarineCommanderSkinsMixin.lua
--
-- Just a data tracking mixin, separated by teams to eliminate network field per-team
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")


MarineCommanderSkinsMixin = CreateMixin(MarineCommanderSkinsMixin)
MarineCommanderSkinsMixin.type = "MarineCommanderSkins"


MarineCommanderSkinsMixin.expectedMixins =
{
    Team = "For making friendly players visible"
}

MarineCommanderSkinsMixin.networkVars =
{
    structureVariant = "enum kMarineStructureVariants"
}


function MarineCommanderSkinsMixin:__initmixin()
    self.structureVariant = kDefaultMarineStructureVariant
end

function MarineCommanderSkinsMixin:GetCommanderStructureSkin()
    return self.structureVariant
end

if Server then

    function MarineCommanderSkinsMixin:OnClientUpdated(client)
        
        Player.OnClientUpdated(self, client)
        
        if not client.variantData or not client.variantData.marineStructuresVariant then
            return
        end

        self.structureVariant = client.variantData.marineStructuresVariant
        
        --Allow skin changes in Pre-game but not afterwards (TODO needs to change to ON-SPAWN of entity so its consistent with everything else)
        if GetGamerules():GetGameState() <= kGameState.PreGame then

            if GetHasVariant( kMarineStructureVariantsData, client.variantData.marineStructuresVariant and not client:GetIsVirtual() ) then
                self:GetTeam():SetTeamSkinVariant( client.variantData.marineStructuresVariant )
            end

        end

    end

end