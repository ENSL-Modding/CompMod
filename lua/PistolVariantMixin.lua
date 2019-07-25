-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\PistolVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

PistolVariantMixin = CreateMixin(PistolVariantMixin)
PistolVariantMixin.type = "PistolVariant"

local kDefaultVariantData = kPistolVariantData[ kDefaultPistolVariant ]

-- precache models for all variants
PistolVariantMixin.kModelNames = { pistol = { } }

local function MakeModelPath( suffix )
    return "models/marine/pistol/pistol"..suffix..".model"
end

for variant, data in pairs(kPistolVariantData) do
    PistolVariantMixin.kModelNames.pistol[variant] = PrecacheAssetSafe( MakeModelPath( data.modelFilePart), MakeModelPath( kDefaultVariantData.modelFilePart) )
end

PistolVariantMixin.kDefaultModelName = PistolVariantMixin.kModelNames.pistol[kDefaultPistolVariant]

PistolVariantMixin.kPistolAnimationGraph = PrecacheAsset("models/marine/pistol/pistol_view.animation_graph")

PistolVariantMixin.networkVars =
{
    pistolVariant = "enum kPistolVariant",
    clientUserId = "integer"
}

function PistolVariantMixin:__initmixin()
    
    PROFILE("PistolVariantMixin:__initmixin")
    
    self.pistolVariant = kDefaultPistolVariant
    self.clientUserId = 0
    
end

function PistolVariantMixin:GetPistolVariant()
    return self.pistolVariant
end

function PistolVariantMixin:GetClientId()
    return self.clientUserId
end

function PistolVariantMixin:GetVariantModel()
    return PistolVariantMixin.kModelNames.pistol[ self.pistolVariant ]
end

if Server then

    -- Usually because the client connected or changed their options.
    function PistolVariantMixin:UpdateWeaponSkins(client)

        local data = client.variantData
        if data == nil then
            return
        end
        
        if GetHasVariant(kPistolVariantData, data.pistolVariant, client) or client:GetIsVirtual() then
            -- Cleared, pass info to clients.
            self.pistolVariant = data.pistolVariant
            self.clientUserId = client:GetUserId()
            
            assert(self.pistolVariant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel(modelName)
            
        else
            Print("ERROR: Client tried to request Pistol variant they do not have yet")
        end
        
    end
    
end

function PistolVariantMixin:OnUpdateRender()
 
    if self:GetRenderModel() ~= nil then
        self:GetRenderModel():SetMaterialParameter("textureIndex", self.pistolVariant-1)
    end


    local player = self:GetParent()
    if player and player:GetIsLocalPlayer() then
        
        local viewModel = player:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() and player:isa("Marine") and player:GetActiveWeapon() == self then
            viewModel:GetRenderModel():SetMaterialParameter("textureIndex", self.pistolVariant-1)
        end
        
    end
end