-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\HMGVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

HMGVariantMixin = CreateMixin(HMGVariantMixin)
HMGVariantMixin.type = "HMGVariant"

local kDefaultVariantData = kHMGVariantData[ kDefaultHMGVariant ]

-- precache models for all variants
HMGVariantMixin.kModelNames = { hmg = { } }

local function MakeModelPath( suffix )
    return "models/marine/hmg/hmg"..suffix..".model"
end

for variant, data in pairs(kHMGVariantData) do
    HMGVariantMixin.kModelNames.hmg[variant] = PrecacheAssetSafe( MakeModelPath( data.modelFilePart), MakeModelPath( kDefaultVariantData.modelFilePart) )
end

HMGVariantMixin.kDefaultModelName = HMGVariantMixin.kModelNames.hmg[kDefaultHMGVariant]

HMGVariantMixin.kHMGAnimationGraph = PrecacheAsset("models/marine/hmg/hmg_view.animation_graph")

HMGVariantMixin.networkVars =
{
    hmgVariant = "enum kHMGVariant",
    clientUserId = "integer"
}

function HMGVariantMixin:__initmixin()
    
    PROFILE("HMGVariantMixin:__initmixin")
    
    self.hmgVariant = kDefaultHMGVariant
    self.clientUserId = 0
    
end

function HMGVariantMixin:GetHMGVariant()
    return self.hmgVariant
end

function HMGVariantMixin:GetClientId()
    return self.clientUserId
end

function HMGVariantMixin:GetVariantModel()
    return HMGVariantMixin.kModelNames.hmg[ self.hmgVariant ]
end

if Server then

    -- Usually because the client connected or changed their options.
    function HMGVariantMixin:UpdateWeaponSkins(client)

        local data = client.variantData
        if data == nil then
            return
        end
        
        if GetHasVariant(kHMGVariantData, data.hmgVariant, client) or client:GetIsVirtual() then
            -- Cleared, pass info to clients.
            self.hmgVariant = data.hmgVariant
            self.clientUserId = client:GetUserId()
            
            assert(self.hmgVariant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel(modelName)
            
        else
            Print("ERROR: Client tried to request HMG variant they do not have yet")
        end
        
    end
    
end

function HMGVariantMixin:OnUpdateRender()
 
    if self:GetRenderModel() ~= nil then
        self:GetRenderModel():SetMaterialParameter("textureIndex", self.hmgVariant-1)
    end


    local player = self:GetParent()
    if player and player:GetIsLocalPlayer() then
        
        local viewModel = player:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() and player:isa("Marine") and player:GetActiveWeapon() == self then
            viewModel:GetRenderModel():SetMaterialParameter("textureIndex", self.hmgVariant-1)
        end
        
    end
end