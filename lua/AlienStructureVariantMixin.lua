-- ======= Copyright (c) 2003-2018, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\AlienStructureVariantMixin.lua
-- 
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")


AlienStructureVariantMixin = CreateMixin(AlienStructureVariantMixin)
AlienStructureVariantMixin.type = "AlienStructureVariant"

AlienStructureVariantMixin.expectedMixins =
{
    Team = "For making friendly players visible"
}

AlienStructureVariantMixin.networkVars =
{
    structureVariant = "enum kAlienStructureVariants",
}

AlienStructureVariantMixin.optionalCallbacks =
{
    SetupStructureEffects = "Special per-structure callback to handle dealing with effects specific per type",
    UpdateStructureEffects = "Same as setup but for regular updates"
}


function AlienStructureVariantMixin:__initmixin()
    if Server then
        self.structureVariant = self:GetTeam():GetActiveTeamSkin()
    else
        self.structureVariant = kAlienStructureVariants.Default
    end

    if self.SetupStructureEffects then
        self:SetupStructureEffects()
    end
end

local function UpdateStructureSkin(self)
    local gameInfo = GetGameInfoEntity()
    if gameInfo then
        self.structureVariant = gameInfo:GetTeamSkin( self:GetTeamNumber() )
    else
        self.structureVariant = kAlienStructureVariants.Default
    end

    if self.UpdateStructureEffects then
        self:UpdateStructureEffects()
    end
end

function AlienStructureVariantMixin:ForceStructureSkinsUpdate()
    UpdateStructureSkin(self)
end

function AlienStructureVariantMixin:OnUpdate(deltaTime)
    UpdateStructureSkin(self)
end

function AlienStructureVariantMixin:OnUpdateRender()
    if self:GetRenderModel() ~= nil then
        self:GetRenderModel():SetMaterialParameter("textureIndex", self.structureVariant - 1)
    end
end