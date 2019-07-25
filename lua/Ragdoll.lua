-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Ragdoll.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    A fake ragdoll that dissolves after kRagdollDuration.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Entity.lua")
Script.Load("lua/Mixins/ModelMixin.lua")

function CreateRagdoll(fromEntity)

    local useModelName = fromEntity:GetModelName()
    local useGraphName = fromEntity:GetGraphName()
    
    if useModelName and string.len(useModelName) > 0 and useGraphName and string.len(useGraphName) > 0 then

        local ragdoll = CreateEntity(Ragdoll.kMapName, fromEntity:GetOrigin())
        ragdoll:SetCoords(fromEntity:GetCoords())
        ragdoll:SetModel(useModelName, useGraphName)
        
        --McG: Could have lookup table per lifeform to set model mass (per rigidbody) here...

        if fromEntity.GetPlayInstantRagdoll and fromEntity:GetPlayInstantRagdoll() then
            ragdoll:SetPhysicsType(PhysicsType.Dynamic)
            ragdoll:SetPhysicsGroup(PhysicsGroup.RagdollGroup)
        else
            ragdoll:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)    
        end
        
        ragdoll:CopyAnimationState(fromEntity)

        if fromEntity.GetRagdollTextureIndex then
            ragdoll:SetTextureIndex( fromEntity:GetRagdollTextureIndex() )
        end
    end
    
end

class 'Ragdoll' (Entity)

local kRagdollTime = 1.5

Ragdoll.kMapName = "ragdoll"

local networkVars =
{
    dissolveStart = "time",
    textureIndex = "integer"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)

function Ragdoll:OnCreate()

    Entity.OnCreate(self)
    
    local now = Shared.GetTime()
    self.dissolveStart = now + kDissolveDelay
    self.dissolveAmount = 0
    
    self.textureIndex = 0

    if Server then
        self:AddTimedCallback(Ragdoll.TimeUp, kRagdollTime)
    end
    
    self:SetUpdates(true, kDefaultUpdateRate)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)  
    
    self:SetRelevancyDistance(kMaxRelevancyDistance)
end

function Ragdoll:SetTextureIndex( index )
    self.textureIndex = index
end

function Ragdoll:OnUpdateAnimationInput(modelMixin)
    PROFILE("Ragdoll:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("alive", false)  
    modelMixin:SetAnimationInput("built", true)
    modelMixin:SetAnimationInput("active", true)
end

function Ragdoll:OnUpdatePoseParameters()
    self:SetPoseParam("grow", 1 )
end

function Ragdoll:TimeUp()
    DestroyEntity(self)
end

function Ragdoll:OnUpdateRender()

    PROFILE("Ragdoll:OnUpdateRender")
    
    local now = Shared.GetTime()
    if self.dissolveStart < now then
        
        if self.dissolveAmount < 1 then
            local now = Shared.GetTime()
            local t = (now - self.dissolveStart) / kDissolveSpeed
            self.dissolveAmount = Clamp( 1 - (1-t)^3, 0.0, 1.0 )
        end
        
        self:SetOpacity( 1 - self.dissolveAmount, "dissolveAmount")
        
    end
    
    if self._renderModel then
        self._renderModel:SetMaterialParameter( "textureIndex", self.textureIndex )
    end

end

if Server then

    function Ragdoll:OnTag(tagName)
    
        PROFILE("Ragdoll:OnTag")
    
        if tagName == "death_end" then
            self:SetPhysicsType(PhysicsType.Dynamic)
            self:SetPhysicsGroup(PhysicsGroup.RagdollGroup)
        end
        
    end
    
end

Shared.LinkClassToMap("Ragdoll", Ragdoll.kMapName, networkVars)