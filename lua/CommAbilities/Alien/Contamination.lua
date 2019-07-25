-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Contamination.lua
--
-- Created by: Andreas Urwalek (andi@unknownworlds.com)
--
-- Creates temporary infestation.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/Weapons/DotMarker.lua")

class 'Contamination' (ScriptActor)

Contamination.kMapName = "contamination"

Contamination.kModelName = PrecacheAsset("models/alien/contamination/contamination.model")
local kAnimationGraph = PrecacheAsset("models/alien/contamination/contamination.animation_graph")

local kContaminationSpreadEffect = PrecacheAsset("cinematics/alien/contamination_spread.cinematic")
local kPhysicsRadius = 0.67

local networkVars =
{
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)


function Contamination:TimeUp()
    self:Kill()
    return false
end

local function SineFalloff( distanceFraction )
    local piFraction = Clamp(distanceFraction, 0, 1) * math.pi / 2
    return math.cos(piFraction + math.pi) + 1 
end

function Contamination:SpewBile()

    if not self:GetIsAlive() or kContaminationBileSpewCount < 1 then
        return false
    end

    self.bileEmitCount = self.bileEmitCount + 1

    if not self:GetIsOnFire() then
        local dotMarker = CreateEntity( DotMarker.kMapName, self:GetOrigin(), self:GetTeamNumber() )
        dotMarker:SetDamageType( kBileBombDamageType )
        dotMarker:SetLifeTime( kBileBombDuration )
        dotMarker:SetDamage( kBileBombDamage )
        dotMarker:SetRadius( kBileBombSplashRadius )
        dotMarker:SetDamageIntervall( kBileBombDotInterval )
        dotMarker:SetDotMarkerType( DotMarker.kType.Static )
        dotMarker:SetTargetEffectName( "bilebomb_onstructure" )
        dotMarker:SetDeathIconIndex( kDeathMessageIcon.BileBomb )
        dotMarker:SetOwner( self:GetOwner() )
        dotMarker:SetFallOffFunc( SineFalloff )
        dotMarker:TriggerEffects( "bilebomb_hit" )
    end

    return self.bileEmitCount < kContaminationBileSpewCount

end


function Contamination:OnCreate()

    ScriptActor.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, IdleMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FireMixin)
    
    self.bileEmitCount = 0
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)

end

function Contamination:OnInitialized()

    ScriptActor.OnInitialized(self)

    InitMixin(self, InfestationMixin)
    
    self:SetModel(Contamination.kModelName, kAnimationGraph)

    local coords = Angles(0, math.random() * 2 * math.pi, 0):GetCoords()
    coords.origin = self:GetOrigin()
    
    if Server then
    
        InitMixin( self, StaticTargetMixin )
        self:SetCoords( coords )
        
        self:AddTimedCallback( self.TimeUp, kContaminationLifeSpan )
        self:AddTimedCallback( self.SpewBile, kContaminationBileInterval )
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        
        self.contaminationEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        self.contaminationEffect:SetCinematic(kContaminationSpreadEffect)
        self.contaminationEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.contaminationEffect:SetCoords(self:GetCoords())

        self.infestationDecal = CreateSimpleInfestationDecal(1, coords)
    
    end

end

function Contamination:OverrideCheckVision()
    return false
end

function Contamination:GetIsFlameAble()
    return false
end

function Contamination:GetReceivesStructuralDamage()
    return true
end    

function Contamination:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if Client then
    
        if self.contaminationEffect then
        
            Client.DestroyCinematic(self.contaminationEffect)
            self.contaminationEffect = nil
        
        end
        
        if self.infestationDecal then
        
            Client.DestroyRenderDecal(self.infestationDecal)
            self.infestationDecal = nil
        
        end
    
    end

end

function Contamination:GetInfestationRadius()
    return kInfestationRadius
end

function Contamination:GetInfestationMaxRadius()
    return kInfestationRadius
end

function Contamination:GetInfestationGrowthRate()
    return 0.5
end

function Contamination:GetPlayIdleSound()
    return self:GetCurrentInfestationRadiusCached() < 1
end

function Contamination:OnKill(attacker, doer, point, direction)

    self:TriggerEffects("death")
    self:SetModel(nil)

end 

function Contamination:GetSendDeathMessageOverride()
    return false
end

function Contamination:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function Contamination:GetCanBeHealedOverride()
    return false
end

local kTargetPointOffset = Vector(0, 0.18, 0)
function Contamination:GetEngagementPointOverride()
    return self:GetOrigin() + kTargetPointOffset
end

function Contamination:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    
    if not self:GetIsAlive() then
    
        if Server then
    
            local destructionAllowedTable = { allowed = true }
            if self.GetDestructionAllowed then
                self:GetDestructionAllowed(destructionAllowedTable)
            end
            
            if destructionAllowedTable.allowed then
                DestroyEntity(self)
            end
        
        end
        
        if Client then
        
            if self.contaminationEffect then
                
                Client.DestroyCinematic(self.contaminationEffect)
                self.contaminationEffect = nil
                
            end
            
            if self.infestationDecal then
            
                Client.DestroyRenderDecal(self.infestationDecal)
                self.infestationDecal = nil
            
            end
            
        end 
    
    end

end

Shared.LinkClassToMap("Contamination", Contamination.kMapName, networkVars)