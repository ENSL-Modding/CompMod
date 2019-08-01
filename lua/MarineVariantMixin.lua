-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\MarineVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

MarineVariantMixin = CreateMixin(MarineVariantMixin)
MarineVariantMixin.type = "MarineVariant"

local kDefaultVariantData = kMarineVariantData[ kDefaultMarineVariant ]

-- Utiliy function for other models that are dependent on marine variant
function GenerateMarineViewModelPaths(weaponName)

    local viewModels = { male = { }, female = { } }

    local function MakePath( prefix, suffix )
        return "models/marine/"..weaponName.."/"..prefix..weaponName.."_view"..suffix..".model"
    end

    local defaultMale =  PrecacheAsset(MakePath("", kDefaultVariantData.viewModelFilePart) )
    local defaultFemale =  PrecacheAssetSafe( MakePath("female_", kDefaultVariantData.viewModelFilePart), defaultMale )
    for variant, data in pairs(kMarineVariantData) do
        viewModels.male[variant] = PrecacheAssetSafe( MakePath("", data.viewModelFilePart), defaultMale )
        viewModels.female[variant] = PrecacheAssetSafe( MakePath("female_", data.viewModelFilePart), defaultFemale )
    end

    return viewModels

end

-- precache models fror all variants
MarineVariantMixin.kModelNames = { male = { }, female = { } }

local function MakeModelPath( gender, suffix )
    return "models/marine/"..gender.."/"..gender..suffix..".model"
end

for variant, data in pairs(kMarineVariantData) do
    MarineVariantMixin.kModelNames.male[variant] = PrecacheAssetSafe( MakeModelPath("male", data.modelFilePart), MakeModelPath("male", kDefaultVariantData.modelFilePart) )
    MarineVariantMixin.kModelNames.female[variant] = PrecacheAssetSafe( MakeModelPath("female", data.modelFilePart), MakeModelPath("female", kDefaultVariantData.modelFilePart) )
end

MarineVariantMixin.kDefaultModelName = MarineVariantMixin.kModelNames.male[kDefaultMarineVariant]

MarineVariantMixin.kMarineAnimationGraph = PrecacheAsset("models/marine/male/male.animation_graph")

MarineVariantMixin.networkVars =
{
    shoulderPadIndex = string.format("integer (0 to %d)",  #kShoulderPad2ItemId),
    isMale = "boolean",
    variant = "enum kMarineVariant",
}

function MarineVariantMixin:__initmixin()
    
    self.isMale = true
    self.variant = kDefaultMarineVariant
    self.shoulderPadIndex = 0

end

function MarineVariantMixin:GetGenderString()
    return self.isMale and "male" or "female"
end

function MarineVariantMixin:GetIsMale()
    return self.isMale
end

function MarineVariantMixin:GetVariant()
    return self.variant
end

function MarineVariantMixin:GetEffectParams(tableParams)
    tableParams[kEffectFilterSex] = self:GetGenderString()
end

function MarineVariantMixin:GetVariantModel()
    return MarineVariantMixin.kModelNames[ self:GetGenderString() ][ self.variant ]
end

if Server then

    -- Usually because the client connected or changed their options.
    function MarineVariantMixin:OnClientUpdated(client)

        Player.OnClientUpdated(self, client)

        local data = client.variantData
        if data == nil then
            return
        end

        self.isMale = data.isMale

        self.shoulderPadIndex = 0

        local selectedIndex = client.variantData.shoulderPadIndex

        if GetHasShoulderPad(selectedIndex, client) then
            self.shoulderPadIndex = selectedIndex
        end

        -- Some entities using MarineVariantMixin don't care about model changes.
        if self.GetIgnoreVariantModels and self:GetIgnoreVariantModels() then
            return
        end

        if GetHasVariant(kMarineVariantData, data.marineVariant, client) or client:GetIsVirtual() then

            -- Cleared, pass info to clients.
            self.variant = data.marineVariant
            assert(self.variant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel(modelName, MarineVariantMixin.kMarineAnimationGraph)
        
        else
            Print("ERROR: Client tried to request marine variant they do not have yet")
        end
        
        -- Trigger a weapon skin update, to update the view model
        self:UpdateWeaponSkin(client)
    end

end

if Client then

    --FIXME No reason for this to function/event to even exist for this Mixin!
    function MarineVariantMixin:OnUpdateRender()    --FIXME This should NOT be on EVERY render call

        -- update player patch
        if self:GetRenderModel() ~= nil then
            self:GetRenderModel():SetMaterialParameter("patchIndex", self.shoulderPadIndex-2)
        end

    end

end

--Note: will likely have to change network var(s) to use single table  ...uh, it's already using an enum (same diff)
if Client then

PrecacheAsset("cinematics/vfx_materials/electrified.material")

local function RemoveOverrideMaterial(matIdx)

    Log("Removing Player model material...")

    matIdx = tonumber(matIdx)

    if type(matIdx) ~= "number" and matIdx >= 0 then
        Log("Invalid material index")
    end

    local player = Client.GetLocalPlayer()
    
    if player then

        if player.modelIndex ~= 0 and player._renderModel then
            
            Log("\t Removing material at Mat-index %d", matIdx)
            if not player._renderModel:RemoveOverrideMaterial( matIdx ) then
                Log("\t Remove material failed for Mat-index %d", matIdx)
                player._renderModel:LogAllMaterials();
            end

        else
            Log("No modelIndex found")
        end

    else
        Log("Only allowed for local clients")
    end

end
Event.Hook("Console_removematerial", RemoveOverrideMaterial)

local function OverridePlayerMaterial(matIdx, materialName)

    local overrideMatName = "cinematics/vfx_materials/nanoshield.material"
    if materialName and type(materialName) == "string" then
        overrideMatName = materialName
    end

    matIdx = tonumber(matIdx)

    if type(matIdx) ~= "number" and matIdx >= 0 then
        Log("Invalid material index")
    end

    local player = Client.GetLocalPlayer()

    if player then

        if player.modelIndex ~= 0 and player._renderModel then
            
            if player._renderModel:SetOverrideMaterial( matIdx, overrideMatName ) then
                Log("\t Overriding material at index %d", matIdx)
                player._renderModel:LogAllMaterials();
            else
                Log("\t Override material failed at index %d", matIdx)
            end

        else
            Log("No modelIndex found")
        end

    else
        Log("Only allowed for local clients")
    end

end
Event.Hook("Console_setmaterial", OverridePlayerMaterial)


local function ResetOverrideMaterials()
    local player = Client.GetLocalPlayer()

    if player then
        if player.modelIndex ~= 0 and player._renderModel then
            player._renderModel:ClearOverrideMaterials()
            Log("Reset materials to model default")
            player._renderModel:LogAllMaterials();
        end
    end
end
Event.Hook("Console_resetmaterials", ResetOverrideMaterials)

local function DumpMaterials(client)

    Log("Dumping Player model materials....")

    local player = Client.GetLocalPlayer()

    if player then
        if player.modelIndex ~= 0 and player._renderModel then
            player._renderModel:LogAllMaterials();
        else
            Log("No modelIndex or RenderModel found")
        end
    end
    
end
Event.Hook("Console_dumpmaterials", DumpMaterials)


end