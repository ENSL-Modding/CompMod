-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GhostStructureMixin.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

GhostStructureMixin = CreateMixin(GhostStructureMixin)
GhostStructureMixin.type = "GhostStructure"

GhostStructureMixin.kGhostStructureCancelRange = 3

GhostStructureMixin.expectedMixins =
{
    Construct = "Makes no sense to use this mixin for non constructable units.",
    Team = "Required to identify enemies and to cancel ghost mode by onuse from friendly players"
}

GhostStructureMixin.networkVars =
{
    isGhostStructure = "boolean"
}

local kGhoststructureMaterial = PrecacheAsset("cinematics/vfx_materials/ghoststructure.material") 

if Client then
    PrecacheAsset("cinematics/vfx_materials/ghoststructure.surface_shader")
end

function GhostStructureMixin:__initmixin()
    
    PROFILE("GhostStructureMixin:__initmixin")
    
    -- init the entity in ghost structure mode
    self.isGhostStructure = true
end

function GhostStructureMixin:GetIsGhostStructure()
    return self.isGhostStructure
end

function GhostStructureMixin:OnInitialized()
    local coords = self:GetCoords()
    local extents = self:GetExtents()
    extents = extents * 4
    coords.origin.y = coords.origin.y + extents.y

    self.triggerBody = Shared.CreatePhysicsBoxBody(false, extents, 0, coords)
    self.triggerBody:SetTriggerEnabled(true)
    self.triggerBody:SetCollisionEnabled(false)

    local mixinConstants = self:GetMixinConstants()

    if mixinConstants.kPhysicsGroup then
        self.triggerBody:SetGroup(mixinConstants.kPhysicsGroup)
    end

    if mixinConstants.kFilterMask then
        self.triggerBody:SetGroupFilterMask(mixinConstants.kFilterMask)
    end

    self.triggerBody:SetEntity(self)
end

function GhostStructureMixin:OnDestroy()
    if self.triggerBody then

        Shared.DestroyCollisionObject(self.triggerBody)
        self.triggerBody = nil

    end
end

local function ClearGhostStructure(self)

    self.isGhostStructure = false
    self:TriggerEffects("ghoststructure_destroy")
    local cost = LookupTechData(self:GetTechId(), kTechDataCostKey, 0)
    self:GetTeam():AddTeamResources(cost)
    self:GetTeam():PrintWorldTextForTeamInRange(kWorldTextMessageType.Resources, cost, self:GetOrigin() + kWorldMessageResourceOffset, kResourceMessageRange)
    DestroyEntity(self)

end

function GhostStructureMixin:OnTriggerEntered(entity)

    if Server and self:GetIsGhostStructure() then
        if entity:GetIsAlive() and GetAreEnemies(self, entity) and
            (
                entity:isa("Player") or
                    entity:isa("Babbler") or
                    entity:isa("Drifter") or
                    entity:isa("Whip") or
                    entity:isa("Crag") or
                    entity:isa("Shift") or
                    entity:isa("Shade") or
                    entity:isa("Shade") or
                    entity:isa("MAC") or
                    entity:isa("ARC")
            ) then

            ClearGhostStructure(self)
        end
    end
end

function GhostStructureMixin:PerformAction(techNode, _)

    if techNode.techId == kTechId.Cancel and self:GetIsGhostStructure() then
    
        -- give back only 75% of resources to avoid abusing the mechanic
        self:TriggerEffects("ghoststructure_destroy")
        local cost = math.round(LookupTechData(self:GetTechId(), kTechDataCostKey, 0) * kRecyclePaybackScalar)
        self:GetTeam():AddTeamResources(cost)
        self:GetTeam():PrintWorldTextForTeamInRange(kWorldTextMessageType.Resources, cost, self:GetOrigin() + kWorldMessageResourceOffset, kResourceMessageRange)
        DestroyEntity(self)
        
    end
    
end

if Server then

    local function CheckGhostState(self, doer)

        if self:GetIsGhostStructure() and GetAreFriends(self, doer) then
            self.isGhostStructure = false
            if self.triggerBody then

                Shared.DestroyCollisionObject(self.triggerBody)
                self.triggerBody = nil

            end
        end

    end
    
    function GhostStructureMixin:OnTakeDamage()
    
        if self:GetIsGhostStructure() and self:GetHealthFraction() < 0.25 then        
            ClearGhostStructure(self)
        end
    
    end
    
    -- If we start constructing, make us no longer a ghost
    function GhostStructureMixin:OnConstruct(builder, _)
        CheckGhostState(self, builder)
    end
    
    function GhostStructureMixin:OnConstructionComplete()
        self.isGhostStructure = false
    end

    function GhostStructureMixin:OnTouchInfestation()

        if self:GetIsGhostStructure() and LookupTechData(self:GetTechId(), kTechDataNotOnInfestation, false) then
            ClearGhostStructure(self)
        end
        
    end

end

--
-- Do not allow nano shield on ghost structures.
--
function ConstructMixin:GetCanBeNanoShieldedOverride(resultTable)
    resultTable.shieldedAllowed = resultTable.shieldedAllowed and not self.isGhostStructure
end

-- Client only
if not Client then return end

local function SharedUpdate(self, _)
    PROFILE("GhostStructureMixin:OnUpdate")

    local model
    if HasMixin(self, "Model") then
        model = self:GetRenderModel()
    end

    if model then

        if self:GetIsGhostStructure() then

            self:SetOpacity(0, "ghostStructure")

            if not self.ghostStructureMaterial then
                self.ghostStructureMaterial = AddMaterial(model, kGhoststructureMaterial)
            end

        else

            self:SetOpacity(1, "ghostStructure")

            if RemoveMaterial(model, self.ghostStructureMaterial) then
                self.ghostStructureMaterial = nil
            end

        end

    end
    
end

function GhostStructureMixin:OnUpdate(deltaTime)
    SharedUpdate(self, deltaTime)
end

function GhostStructureMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end
