-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\AxeVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

AxeVariantMixin = CreateMixin(AxeVariantMixin)
AxeVariantMixin.type = "AxeVariant"

local kDefaultVariantData = kAxeVariantData[ kDefaultAxeVariant ]

-- precache models for all variants
AxeVariantMixin.kModelNames = { axe = { } }

local function MakeModelPath( suffix )
    return "models/marine/axe/axe"..suffix..".model"
end

for variant, data in pairs(kAxeVariantData) do
    AxeVariantMixin.kModelNames.axe[variant] = PrecacheAssetSafe( MakeModelPath( data.modelFilePart), MakeModelPath( kDefaultVariantData.modelFilePart) )
end

AxeVariantMixin.kDefaultModelName = AxeVariantMixin.kModelNames.axe[kDefaultAxeVariant]

AxeVariantMixin.kAxeAnimationGraph = PrecacheAsset("models/marine/axe/axe_view.animation_graph")

AxeVariantMixin.networkVars =
{
    axeVariant = "enum kAxeVariant",
    clientUserId = "integer"
}

function AxeVariantMixin:__initmixin()
    
    PROFILE("AxeVariantMixin:__initmixin")
    
    self.axeVariant = kDefaultAxeVariant
    self.clientUserId = 0
    
end

function AxeVariantMixin:GetAxeVariant()
    return self.axeVariant
end

function AxeVariantMixin:GetClientId()
    return self.clientUserId
end

function AxeVariantMixin:GetVariantModel()
    return AxeVariantMixin.kModelNames.axe[ self.axeVariant ]
end

if Server then

    -- Usually because the client connected or changed their options.
    function AxeVariantMixin:UpdateWeaponSkins(client)

        local data = client.variantData
        if data == nil then
            return
        end
        
        if GetHasVariant(kAxeVariantData, data.axeVariant, client) or client:GetIsVirtual() then
            -- Cleared, pass info to clients.
            self.axeVariant = data.axeVariant
            self.clientUserId = client:GetUserId()
            
            assert(self.axeVariant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel(modelName)
            
        else
            Print("ERROR: Client tried to request Axe variant they do not have yet")
        end
        
    end
    
end

function AxeVariantMixin:OnUpdateRender()
 
    if self:GetRenderModel() ~= nil then
        self:GetRenderModel():SetMaterialParameter("textureIndex", self.axeVariant-1)
    end
    
    local player = self:GetParent()
    if player and player:GetIsLocalPlayer() then
        
        local viewModel = player:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() and player:isa("Marine") and player:GetActiveWeapon() == self then
            viewModel:GetRenderModel():SetMaterialParameter("textureIndex", self.axeVariant-1)
        end
        
    end
end