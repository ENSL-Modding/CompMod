-- ======= Copyright (c) 2003-2018, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\AlienTunnelVariantMixin.lua
-- 
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")


AlienTunnelVariantMixin = CreateMixin(AlienTunnelVariantMixin)
AlienTunnelVariantMixin.type = "AlienTunnelVariant"

AlienTunnelVariantMixin.expectedMixins =
{
    Team = "For making friendly players visible"
}

AlienTunnelVariantMixin.networkVars =
{
    tunnelVariant = "enum kAlienTunnelVariants",
}

AlienTunnelVariantMixin.optionalCallbacks =
{
    SetupStructureEffects = "Special per-structure callback to handle dealing with effects specific per type",
    UpdateStructureEffects = "Same as setup but for regular updates"
}


local function UpdateTunnelSkin(self)

    local gameInfo = GetGameInfoEntity()
    if gameInfo then
        self.tunnelVariant = gameInfo:GetTeamSkinSpecial( self:GetTeamNumber() )
    end

    if self.UpdateStructureEffects then
        self:UpdateStructureEffects()
    end
end

function AlienTunnelVariantMixin:__initmixin()

    if self.SetupStructureEffects then
        self:SetupStructureEffects()
    end

    UpdateTunnelSkin(self)
    
    self:SetVariant(self.tunnelVariant)
end

function AlienTunnelVariantMixin:ForceStructureSkinsUpdate()
    UpdateTunnelSkin(self)
end

function AlienTunnelVariantMixin:OnUpdate(deltaTime)
    UpdateTunnelSkin(self)
end

function AlienTunnelVariantMixin:OnUpdateRender()
    if self:GetRenderModel() ~= nil then
        if self.tunnelVariant > 2 then
            self:GetRenderModel():SetMaterialParameter("textureIndex", self.tunnelVariant - 2) --Due to Shadow model usage
        else
            self:GetRenderModel():SetMaterialParameter("textureIndex", self.tunnelVariant - 1)
        end
    end
end