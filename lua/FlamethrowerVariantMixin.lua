-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\FlamethrowerVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

FlamethrowerVariantMixin = CreateMixin(FlamethrowerVariantMixin)
FlamethrowerVariantMixin.type = "FlamethrowerVariant"

local kDefaultVariantData = kFlamethrowerVariantData[ kDefaultFlamethrowerVariant ]

-- precache models for all variants
FlamethrowerVariantMixin.kModelNames = { flamethrower = { } }

local function MakeModelPath( suffix )
    return "models/marine/flamethrower/flamethrower"..suffix..".model"
end

for variant, data in pairs(kFlamethrowerVariantData) do
    FlamethrowerVariantMixin.kModelNames.flamethrower[variant] = PrecacheAssetSafe( MakeModelPath( data.modelFilePart), MakeModelPath( kDefaultVariantData.modelFilePart) )
end

FlamethrowerVariantMixin.kDefaultModelName = FlamethrowerVariantMixin.kModelNames.flamethrower[kDefaultFlamethrowerVariant]

FlamethrowerVariantMixin.kFlamethrowerAnimationGraph = PrecacheAsset("models/marine/flamethrower/flamethrower_view.animation_graph")

FlamethrowerVariantMixin.networkVars =
{
    flamethrowerVariant = "enum kFlamethrowerVariant",
    clientUserId = "integer"
}

function FlamethrowerVariantMixin:__initmixin()
    
    PROFILE("FlamethrowerVariantMixin:__initmixin")
    
    self.flamethrowerVariant = kDefaultFlamethrowerVariant
    self.clientUserId = 0
    
end

function FlamethrowerVariantMixin:GetFlamethrowerVariant()
    return self.flamethrowerVariant
end

function FlamethrowerVariantMixin:GetClientId()
    return self.clientUserId
end

function FlamethrowerVariantMixin:GetVariantModel()
    return FlamethrowerVariantMixin.kModelNames.flamethrower[ self.flamethrowerVariant ]
end

if Server then

    -- Usually because the client connected or changed their options.
    function FlamethrowerVariantMixin:UpdateWeaponSkins(client)

        local data = client.variantData
        if data == nil then
            return
        end
        
        if GetHasVariant(kFlamethrowerVariantData, data.flamethrowerVariant, client) or client:GetIsVirtual() then
            -- Cleared, pass info to clients.
            self.flamethrowerVariant = data.flamethrowerVariant
            self.clientUserId = client:GetUserId()
            
            assert(self.flamethrowerVariant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel(modelName)
            
        else
            Print("ERROR: Client tried to request Flamethrower variant they do not have yet")
        end
        
    end
    
end

function FlamethrowerVariantMixin:OnUpdateRender()
 
    if self:GetRenderModel() ~= nil then
        self:GetRenderModel():SetMaterialParameter("textureIndex", self.flamethrowerVariant-1)
    end


    local player = self:GetParent()
    if player and player:GetIsLocalPlayer() then
        
        local viewModel = player:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() and player:isa("Marine") and player:GetActiveWeapon() == self then
            viewModel:GetRenderModel():SetMaterialParameter("textureIndex", self.flamethrowerVariant-1)
        end
        
    end
end