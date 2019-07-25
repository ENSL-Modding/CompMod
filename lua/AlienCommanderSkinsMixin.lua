-- ======= Copyright (c) 2003-2018, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\AlienCommanderSkinsMixin.lua
--
-- Just a data tracking mixin, separated by teams to eliminate network field per-team
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")


AlienCommanderSkinsMixin = CreateMixin(AlienCommanderSkinsMixin)
AlienCommanderSkinsMixin.type = "AlienCommanderSkins"


AlienCommanderSkinsMixin.expectedMixins =
{
    Team = "For making friendly players visible"
}

AlienCommanderSkinsMixin.networkVars =
{
    structureVariant = "enum kAlienStructureVariants",
    tunnelVariant = "enum kAlienTunnelVariants"
}


function AlienCommanderSkinsMixin:__initmixin()
    self.structureVariant = kDefaultAlienStructureVariant
    self.tunnelVariant = kDefaultAlienTunnelVariant
end

function AlienCommanderSkinsMixin:GetCommanderStructureSkin()
    return self.structureVariant
end

function AlienCommanderSkinsMixin:GetCommanderTunnelSkin()
    return self.tunnelVariant
end

if Server then

    function AlienCommanderSkinsMixin:OnClientUpdated(client)

        Player.OnClientUpdated(self, client)
        
        if not client.variantData or not client.variantData.alienStructuresVariant or not client.variantData.alienTunnelsVariant then
            return
        end

        self.structureVariant = client.variantData.alienStructuresVariant
        self.tunnelVariant = client.variantData.alienTunnelsVariant

        if GetGamerules():GetGameState() <= kGameState.PreGame then --FIXME This won't work for players shuffled INTO Commander role

            if GetHasVariant( kAlienStructureVariantsData, client.variantData.alienStructuresVariant and not client:GetIsVirtual() ) then
                self:GetTeam():SetTeamSkinVariant( client.variantData.alienStructuresVariant )
            end
            
            if GetHasVariant( kAlienTunnelVariantsData, client.variantData.alienTunnelsVariant and not client:GetIsVirtual() ) then
                self:GetTeam():SetTeamSkinSpecialVariant( client.variantData.alienTunnelsVariant )
            end

        end

    end

end