-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Scan.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
-- A Commander ability that gives LOS to marine team for a short time.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")
Script.Load("lua/MapBlipMixin.lua")

class 'Scan' (CommanderAbility)

Scan.kMapName = "scan"

Scan.kScanEffect = PrecacheAsset("cinematics/marine/observatory/scan.cinematic")
Scan.kScanSound = PrecacheAsset("sound/NS2.fev/marine/commander/scan")

Scan.kType = CommanderAbility.kType.Repeat
local kScanInterval = 0.2
Scan.kScanDistance = kScanRadius

local networkVars = { }

function Scan:OnCreate()

    CommanderAbility.OnCreate(self)
    
    if Server then
        StartSoundEffectOnEntity(Scan.kScanSound, self)
    end
    
end

function Scan:OnInitialized()

    CommanderAbility.OnInitialized(self)
    
    if Server then
    
        DestroyEntitiesWithinRange("Scan", self:GetOrigin(), Scan.kScanDistance * 0.5, EntityFilterOne(self)) 
    
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    end
    
end

function Scan:OverrideCheckVision()
    return true
end

function Scan:GetRepeatCinematic()
    return Scan.kScanEffect
end

function Scan:GetType()
    return Scan.kType
end

function Scan:GetLifeSpan()
    return kScanDuration
end

function Scan:GetUpdateTime()
    return kScanInterval
end

if Server then

    function Scan:ScanEntity(ent)
        if HasMixin(ent, "LOS") then
            ent:SetIsSighted(true)
        end

        if HasMixin(ent, "Detectable") then
            ent:SetDetected(true)
        end

        -- Allow entities to respond
        if ent.OnScan then
            ent:OnScan()
        end
    end

    function Scan:Perform()
    
        PROFILE("Scan:Perform")
        
        local inkClouds = GetEntitiesForTeamWithinRange("ShadeInk", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Scan.kScanDistance)

        if #inkClouds > 0 then
            
            for _, cloud in ipairs(inkClouds) do
                cloud:SetIsSighted(true)
            end

        else

            -- avoid scanning entities twice
            local scannedIdMap = {}
            local enemies = GetEntitiesWithMixinForTeamWithinXZRange("LOS", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Scan.kScanDistance)
            for _, enemy in ipairs(enemies) do

                local entId = enemy:GetId()
                scannedIdMap[entId] = true

                self:ScanEntity(enemy)

            end

            local detectable = GetEntitiesWithMixinForTeamWithinXZRange("Detectable", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Scan.kScanDistance)
            for _, enemy in ipairs(detectable) do

                local entId = enemy:GetId()
                if not scannedIdMap[entId] then
                    self:ScanEntity(enemy)
                end

            end
            
        end    
        
    end
    
    function Scan:OnDestroy()
    
        for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("LOS", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Scan.kScanDistance)) do
            entity.updateLOS = true
        end
        
        CommanderAbility.OnDestroy(self)
    
    end
    
end

Shared.LinkClassToMap("Scan", Scan.kMapName, networkVars)
