-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\BuilderVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

BuilderVariantMixin = CreateMixin(BuilderVariantMixin)
BuilderVariantMixin.type = "BuilderVariant"

local kDefaultVariantData = kWelderVariantData[ kDefaultWelderVariant ]

-- precache models for all variants
BuilderVariantMixin.kModelNames = { builder = { } }

local function MakeModelPath( suffix )
    return "models/marine/welder/builder" .. suffix .. ".model"
end

for variant, data in pairs(kWelderVariantData) do
    BuilderVariantMixin.kModelNames.builder[variant] = PrecacheAssetSafe( MakeModelPath( data.modelFilePart), MakeModelPath( kDefaultVariantData.modelFilePart) )
end

BuilderVariantMixin.kDefaultModelName = BuilderVariantMixin.kModelNames.builder[kDefaultWelderVariant]

BuilderVariantMixin.kBuilderAnimationGraph = PrecacheAsset("models/marine/welder/welder_view.animation_graph")

BuilderVariantMixin.networkVars = 
{
    builderVariant = "enum kWelderVariant",
    clientUserId = "integer"
}

function BuilderVariantMixin:__initmixin()
    
    PROFILE("BuilderVariantMixin:__initmixin")
    
    self.builderVariant = kDefaultWelderVariant
    self.clientUserId = 0
    
end

function BuilderVariantMixin:GetBuilderVariant()
    return self.builderVariant
end

function BuilderVariantMixin:GetClientId()
    return self.clientUserId
end

function BuilderVariantMixin:GetVariantModel()
    return BuilderVariantMixin.kModelNames.builder[ self.builderVariant ]
end

if Server then
    
    -- Usually because the client connected or changed their options.
    function BuilderVariantMixin:UpdateWeaponSkins(client)
        local data = client.variantData
        if data == nil then
            return
        end
        
        if GetHasVariant(kWelderVariantData, data.welderVariant, client) or client:GetIsVirtual() then
            -- Cleared, pass info to clients.
            self.builderVariant = data.welderVariant
            self.clientUserId = client:GetUserId()
            
            assert(self.builderVariant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel( modelName )
            
        else
            Print("ERROR: Client tried to request Welder/Builder variant they do not have yet")
        end
    end
    
end

function BuilderVariantMixin:OnUpdateRender()
    
    if self:GetRenderModel() ~= nil then
        self:GetRenderModel():SetMaterialParameter("textureIndex", self.builderVariant-1)
    end

    local player = self:GetParent()
    if player and player:GetIsLocalPlayer() then
        
        local viewModel = player:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() and player:isa("Marine") and player:GetActiveWeapon() == self then
            viewModel:GetRenderModel():SetMaterialParameter("textureIndex", self.builderVariant-1)
        end
        
    end
end