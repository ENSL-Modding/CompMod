-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\WelderVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

WelderVariantMixin = CreateMixin(WelderVariantMixin)
WelderVariantMixin.type = "WelderVariant"

local kDefaultVariantData = kWelderVariantData[ kDefaultWelderVariant ]

-- precache models for all variants
WelderVariantMixin.kModelNames = { welder = { } }

local function MakeModelPath( suffix )
    return "models/marine/welder/welder" .. suffix .. ".model"
end

for variant, data in pairs(kWelderVariantData) do
    WelderVariantMixin.kModelNames.welder[variant] = PrecacheAssetSafe( MakeModelPath( data.modelFilePart), MakeModelPath( kDefaultVariantData.modelFilePart) )
end

WelderVariantMixin.kDefaultModelName = WelderVariantMixin.kModelNames.welder[kDefaultWelderVariant]

WelderVariantMixin.kWelderAnimationGraph = PrecacheAsset("models/marine/welder/welder_view.animation_graph")

WelderVariantMixin.networkVars = 
{
    welderVariant = "enum kWelderVariant",
    clientUserId = "integer"
}

function WelderVariantMixin:__initmixin()
    
    PROFILE("WelderVariantMixin:__initmixin")
    
    self.welderVariant = kDefaultWelderVariant
    self.clientUserId = 0
    
end

function WelderVariantMixin:GetWelderVariant()
    return self.welderVariant
end

function WelderVariantMixin:GetClientId()
    return self.clientUserId
end

function WelderVariantMixin:GetVariantModel()
    return WelderVariantMixin.kModelNames.welder[ self.welderVariant ]
end

if Server then
    
    -- Usually because the client connected or changed their options.
    function WelderVariantMixin:UpdateWeaponSkins(client)
        local data = client.variantData
        if data == nil then
            return
        end
        
        if GetHasVariant(kWelderVariantData, data.welderVariant, client) or client:GetIsVirtual() then
            -- Cleared, pass info to clients.
            self.welderVariant = data.welderVariant
            self.clientUserId = client:GetUserId()
            
            assert(self.welderVariant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel( modelName )
            
        else
            Print("ERROR: Client tried to request Welder variant they do not have yet")
        end
    end
    
end

function WelderVariantMixin:OnUpdateRender()
    
    if self:GetRenderModel() ~= nil then
        self:GetRenderModel():SetMaterialParameter("textureIndex", self.welderVariant-1)
    end

    local player = self:GetParent()
    if player and player:GetIsLocalPlayer() then
        
        local viewModel = player:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() and player:isa("Marine") and player:GetActiveWeapon() == self then
            viewModel:GetRenderModel():SetMaterialParameter("textureIndex", self.welderVariant-1)
        end
        
    end
end