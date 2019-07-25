-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\GrenadeLauncherVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

GrenadeLauncherVariantMixin = CreateMixin(GrenadeLauncherVariantMixin)
GrenadeLauncherVariantMixin.type = "GrenadeLauncherVariant"

local kDefaultVariantData = kGrenadeLauncherVariantData[ kDefaultGrenadeLauncherVariant ]

-- precache models for all variants
GrenadeLauncherVariantMixin.kModelNames = { grenadeLauncher = { } }

local function MakeModelPath( suffix )
    return "models/marine/grenadelauncher/grenadelauncher" .. suffix .. ".model"
end

for variant, data in pairs(kGrenadeLauncherVariantData) do
    GrenadeLauncherVariantMixin.kModelNames.grenadeLauncher[variant] = PrecacheAssetSafe( MakeModelPath( data.modelFilePart), MakeModelPath( kDefaultVariantData.modelFilePart) )
end

GrenadeLauncherVariantMixin.kDefaultModelName = GrenadeLauncherVariantMixin.kModelNames.grenadeLauncher[kDefaultGrenadeLauncherVariant]

GrenadeLauncherVariantMixin.kGrenadeLauncherAnimationGraph = PrecacheAsset("models/marine/grenadelauncher/grenadelauncher_view.animation_graph")

GrenadeLauncherVariantMixin.networkVars = 
{
    grenadeLauncherVariant = "enum kGrenadeLauncherVariant",
    clientUserId = "integer"
}

function GrenadeLauncherVariantMixin:__initmixin()
    
    PROFILE("GrenadeLauncherVariantMixin:__initmixin")
    
    self.grenadeLauncherVariant = kDefaultGrenadeLauncherVariant
    self.clientUserId = 0
    
end

function GrenadeLauncherVariantMixin:GetGrenadeLauncherVariant()
    return self.grenadeLauncherVariant
end

function GrenadeLauncherVariantMixin:GetClientId()
    return self.clientUserId
end

function GrenadeLauncherVariantMixin:GetVariantModel()
    return GrenadeLauncherVariantMixin.kModelNames.grenadeLauncher[ self.grenadeLauncherVariant ]
end

if Server then
    
    -- Usually because the client connected or changed their options.
    function GrenadeLauncherVariantMixin:UpdateWeaponSkins(client)
        local data = client.variantData
        if data == nil then
            return
        end
        
        if GetHasVariant(kGrenadeLauncherVariantData, data.grenadeLauncherVariant, client) or client:GetIsVirtual() then
            -- Cleared, pass info to clients.
            self.grenadeLauncherVariant = data.grenadeLauncherVariant
            self.clientUserId = client:GetUserId()
            
            assert(self.grenadeLauncherVariant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel( modelName )
            
        else
            Print("ERROR: Client tried to request Grenade Launcher variant they do not have yet")
        end
    end
    
end

function GrenadeLauncherVariantMixin:OnUpdateRender()
    
    if self:GetRenderModel() ~= nil then
        self:GetRenderModel():SetMaterialParameter("textureIndex", self.grenadeLauncherVariant-1)
    end

    local player = self:GetParent()
    if player and player:GetIsLocalPlayer() then
        
        local viewModel = player:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() and player:isa("Marine") and player:GetActiveWeapon() == self then
            viewModel:GetRenderModel():SetMaterialParameter("textureIndex", self.grenadeLauncherVariant-1)
        end
        
    end
end