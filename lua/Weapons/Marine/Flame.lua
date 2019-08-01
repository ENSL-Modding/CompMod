--=============================================================================
--
-- lua\Weapons\Marine\Flame.lua
--
-- Created by Andreas Urwalek (andi@unknownworlds.com)
-- Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
--
--=============================================================================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/LOSMixin.lua")

PrecacheAsset("cinematics/vfx_materials/decals/flame_decal.surface_shader")

class 'Flame' (ScriptActor)

Flame.kMapName = "flame"
Flame.kFireEffect = PrecacheAsset("cinematics/marine/flamethrower/burning_surface.cinematic")
Flame.kFireWallEffect = PrecacheAsset("cinematics/marine/flamethrower/burning_vertical_surface.cinematic")
Flame.kDecalMaterial = PrecacheAsset("cinematics/vfx_materials/decals/flame_decal.material")
Flame.kDamageRadius = kFlameRadius
Flame.kLifeTime = 3.1
local kUpdateTime = 0.3
Flame.kDamage = 8

local networkVars = { }

AddMixinNetworkVars(TeamMixin, networkVars)

function Flame:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    
end

function Flame:UpdateLifetime()

    self.lifeTime = self.lifeTime - kUpdateTime

    self:Detonate(nil)

    if self.lifeTime <= 0 then

        DestroyEntity(self)

        return false

    end

    return true

end

function Flame:OnInitialized()

    ScriptActor.OnInitialized(self)

    if Server then

        -- intervall of dealing damage
        self.lifeTime = Flame.kLifeTime
        self:AddTimedCallback(self.UpdateLifetime, kUpdateTime)

    elseif Client then

        self.fireEffect = Client.CreateCinematic(RenderScene.Zone_Default)

        local cinematicName = Flame.kFireEffect
        self.fireEffect:SetCinematic(cinematicName)
        self.fireEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.fireEffect:SetIsVisible(self:GetIsVisible())

        local coords = Coords.GetIdentity()
        coords.origin = self:GetOrigin()
        self.fireEffect:SetCoords(coords)

        Client.CreateTimeLimitedDecal(Flame.kDecalMaterial , self:GetCoords(), 3, Flame.kLifeTime)

    end

end

function Flame:OverrideCheckVision()
    return false
end

function Flame:OnDestroy()

    if Client then
    
        Client.DestroyCinematic(self.fireEffect)
        self.fireEffect = nil
        
    end
    
    ScriptActor.OnDestroy(self)
    
end

function Flame:GetDeathIconIndex()
    return kDeathMessageIcon.Flamethrower
end

function Flame:GetDamageType()
    return kFlamethrowerDamageType
end

function Flame:GetShowHitIndicator()
    return false
end
    
if Server then

    function Flame:Detonate(targetHit)
    
        local player = self:GetOwner()
        local ents = GetEntitiesWithMixinWithinXZRange("Live", self:GetOrigin(), self.kDamageRadius)
        
        if targetHit then
            table.insert(ents, targetHit)
        end

        local gamerules = GetGamerules()
        local origin = self:GetOrigin()
        local abs = math.abs
        for i = 1, #ents do

            local ent = ents[i]
            local entOrigin = ent:GetModelOrigin()
            if abs(entOrigin.y - origin.y) <= self.kDamageRadius and
                    (ent ~= self:GetOwner() or gamerules:GetFriendlyFire()) then

                local toEnemy = GetNormalizedVector( entOrigin - origin )
                self:DoDamage(self.kDamage, ent, ent:GetModelOrigin(), toEnemy)
                
            end
            
        end
        
    end
    
elseif Client then

    function Flame:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
    
        if self.fireEffect then
            self.fireEffect:SetIsVisible(self:GetIsVisible())
        end
    
    end
    
end

Shared.LinkClassToMap("Flame", Flame.kMapName, networkVars)