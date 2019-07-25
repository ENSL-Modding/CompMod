-- ======= Copyright (c) 2003-2018, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\MarineStructureVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")


MarineStructureVariantMixin = CreateMixin(MarineStructureVariantMixin)
MarineStructureVariantMixin.type = "MarineStructureVariant"

MarineStructureVariantMixin.expectedMixins =
{
    Team = "For making friendly players visible"
}

MarineStructureVariantMixin.networkVars =
{
    structureVariant = "enum kMarineStructureVariants",
}

function MarineStructureVariantMixin:__initmixin()
    if Server then
        self.structureVariant = self:GetTeam():GetActiveTeamSkin()
    else
        self.structureVariant = kAlienStructureVariants.Default
    end
end

local function UpdateStructureSkin(self)
    local gameInfo = GetGameInfoEntity()
    if gameInfo then
        self.structureVariant = gameInfo:GetTeamSkin( self:GetTeamNumber() )
    else
        self.structureVariant = kAlienStructureVariants.Default
    end
end

function MarineStructureVariantMixin:OnUpdate(deltaTime)
    UpdateStructureSkin(self)
end

function MarineStructureVariantMixin:OnUpdateRender()
    if self:GetRenderModel() ~= nil then
        self:GetRenderModel():SetMaterialParameter("textureIndex", self.structureVariant - 1)
    end
end