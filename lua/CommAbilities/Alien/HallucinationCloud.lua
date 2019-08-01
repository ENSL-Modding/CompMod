-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CommAbilities\Alien\HallucinationCloud.lua
--
--      Created by: Andreas Urwalek (andi@unknownworlds.com)
--
--      Creates a hallucination of every affected alien.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'HallucinationCloud' (CommanderAbility)

HallucinationCloud.kMapName = "hallucinationcloud"

HallucinationCloud.kSplashEffect = PrecacheAsset("cinematics/alien/hallucinationcloud.cinematic")
HallucinationCloud.kType = CommanderAbility.kType.Instant

HallucinationCloud.kRadius = 8

local gTechIdToHallucinateTechId
function GetHallucinationTechId(techId)

    if not gTechIdToHallucinateTechId then
    
        gTechIdToHallucinateTechId = {}
        gTechIdToHallucinateTechId[kTechId.Drifter] = kTechId.HallucinateDrifter
        gTechIdToHallucinateTechId[kTechId.Skulk] = kTechId.HallucinateSkulk
        gTechIdToHallucinateTechId[kTechId.Gorge] = kTechId.HallucinateGorge
        gTechIdToHallucinateTechId[kTechId.Lerk] = kTechId.HallucinateLerk
        gTechIdToHallucinateTechId[kTechId.Fade] = kTechId.HallucinateFade
        gTechIdToHallucinateTechId[kTechId.Onos] = kTechId.HallucinateOnos
        
        gTechIdToHallucinateTechId[kTechId.Hive] = kTechId.HallucinateHive
        gTechIdToHallucinateTechId[kTechId.Whip] = kTechId.HallucinateWhip
        gTechIdToHallucinateTechId[kTechId.Shade] = kTechId.HallucinateShade
        gTechIdToHallucinateTechId[kTechId.Crag] = kTechId.HallucinateCrag
        gTechIdToHallucinateTechId[kTechId.Shift] = kTechId.HallucinateShift
        gTechIdToHallucinateTechId[kTechId.Harvester] = kTechId.HallucinateHarvester
        gTechIdToHallucinateTechId[kTechId.Hydra] = kTechId.HallucinateHydra
    
    end
    
    return gTechIdToHallucinateTechId[techId]

end

local networkVars = { }

function HallucinationCloud:OnInitialized()
    
    if Server then
        -- sound feedback
        self:TriggerEffects("enzyme_cloud")    
    end
    
    CommanderAbility.OnInitialized(self)

end

function HallucinationCloud:GetStartCinematic()
    return HallucinationCloud.kSplashEffect
end

function HallucinationCloud:GetType()
    return HallucinationCloud.kType
end

function HallucinationCloud:RegisterHallucination(entity)
    
    if not self.hallucinations then
        self.hallucinations = {}
    end
    
    table.insert(self.hallucinations, entity:GetId())
    
end

function HallucinationCloud:GetRegisteredHallucinations()
    return self.hallucinations or {}
end

local function AllowedToHallucinate(entity)

    local allowed = true
    if entity.timeLastHallucinated and entity.timeLastHallucinated + kHallucinationCloudCooldown > Shared.GetTime() then
        allowed = false
    else
        entity.timeLastHallucinated = Shared.GetTime()
    end    
    
    return allowed

end

if Server then

    -- sort by techId, so the higher life forms are prefered
    local function SortByTechIdAndInRange(alienOne, alienTwo)
        local inRangeOne = alienOne.__inHallucinationCloudRange
        if inRangeOne == alienTwo.__inHallucinationCloudRange then
            if inRangeOne then
                return alienOne:GetTechId() > alienTwo:GetTechId()
            else
                return alienOne:GetTechId() < alienTwo:GetTechId()
            end
        end

        return inRangeOne
    end

    local kHallucinationClassNameMap = {
        [Skulk.kMapName] = SkulkHallucination.kMapName,
        [Gorge.kMapName] = GorgeHallucination.kMapName,
        [Lerk.kMapName] = LerkHallucination.kMapName,
        [Fade.kMapName] = FadeHallucination.kMapName,
        [Onos.kMapName] = OnosHallucination.kMapName
    }
    
    function HallucinationCloud:Perform()

        -- kill all hallucinations before, to prevent unreasonable spam
        for _, hallucination in ipairs(GetEntitiesForTeam("Hallucination", self:GetTeamNumber())) do
            hallucination.consumed = true
            hallucination:Kill()
        end

        for _, playerHallucination in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do

            if playerHallucination.isHallucination then
                playerHallucination:TriggerEffects("death_hallucination")
                DestroyEntity(playerHallucination)
            end

        end

        local drifter = GetEntitiesForTeamWithinRange("Drifter", self:GetTeamNumber(), self:GetOrigin(), HallucinationCloud.kRadius)[1]
        if drifter then

            if AllowedToHallucinate(drifter) then

                local angles = drifter:GetAngles()
                angles.pitch = 0
                angles.roll = 0
                local origin = GetGroundAt(self, drifter:GetOrigin() + Vector(0, .1, 0), PhysicsMask.Movement, EntityFilterOne(drifter))

                local hallucination = CreateEntity(Hallucination.kMapName, origin, self:GetTeamNumber())
                self:RegisterHallucination(hallucination)
                hallucination:SetEmulation(GetHallucinationTechId(kTechId.Drifter))
                hallucination:SetAngles(angles)

                local randomDestinations = GetRandomPointsWithinRadius(drifter:GetOrigin(), 4, 10, 10, 1, 1, nil, nil)
                if randomDestinations[1] then
                    hallucination:GiveOrder(kTechId.Move, nil, randomDestinations[1], nil, true, true)
                end

            end

        end

        -- limit max num of hallucinations to 1/3 of team size
        local aliens = GetEntitiesForTeam("Player", self:GetTeamNumber())
        local teamSize = #aliens

        local origin = self:GetOrigin()
        local radius = HallucinationCloud.kRadius
        local radiusSquared = radius * radius

        for i = 1, teamSize do
            local alien = aliens[i]
            alien.__inHallucinationCloudRange = alien:GetIsAlive() and alien:GetDistanceSquared(origin) <= radiusSquared
        end
        table.sort(aliens, SortByTechIdAndInRange)

        local skulkExtends = Vector(Skulk.kXExtents, Skulk.kYExtents, Skulk.kZExtents)
        local maxAllowedHallucinations = math.max(1, math.floor(teamSize * kPlayerHallucinationNumFraction))
        for i = 1, maxAllowedHallucinations do
            local alien = aliens[i]
            if AllowedToHallucinate(alien) then
                local newAlienExtents = LookupTechData(alien:GetTechId(), kTechDataMaxExtents, skulkExtends)
                local alienOrigin = alien.__inHallucinationCloudRange and alien:GetModelOrigin() or origin

                local _, capsuleRadius = GetTraceCapsuleFromExtents(newAlienExtents)

                local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, alienOrigin, 0.5, 5)

                if spawnPoint then

                    local hallucinationClassName = kHallucinationClassNameMap[alien:GetMapName()] or SkulkHallucination.kMapName
                    local hallucination = CreateEntity(hallucinationClassName, spawnPoint, self:GetTeamNumber())
                    hallucination:SetEmulation(alien)

                    -- make drifter keep a record of any hallucinations created from its cloud, so they
                    -- die when drifter dies.
                    self:RegisterHallucination(hallucination)

                else
                    maxAllowedHallucinations = math.min(maxAllowedHallucinations + 1, teamSize)
                end

            else
                maxAllowedHallucinations = math.min(maxAllowedHallucinations + 1, teamSize)
            end
        end
        
        for _, resourcePoint in ipairs(GetEntitiesWithinRange("ResourcePoint", self:GetOrigin(), HallucinationCloud.kRadius)) do
        
            if resourcePoint:GetAttached() == nil and GetIsPointOnInfestation(resourcePoint:GetOrigin()) then
            
                local hallucination = CreateEntity(Hallucination.kMapName, resourcePoint:GetOrigin(), self:GetTeamNumber())
                self:RegisterHallucination(hallucination)
                hallucination:SetEmulation(kTechId.HallucinateHarvester)
                hallucination:SetAttached(resourcePoint)
                
            end
        
        end
        
        for _, techPoint in ipairs(GetEntitiesWithinRange("TechPoint", self:GetOrigin(), HallucinationCloud.kRadius)) do
        
            if techPoint:GetAttached() == nil then
            
                local coords = techPoint:GetCoords()
                coords.origin = coords.origin + Vector(0, 2.494, 0)
                local hallucination = CreateEntity(Hallucination.kMapName, techPoint:GetOrigin(), self:GetTeamNumber())
                self:RegisterHallucination(hallucination)
                hallucination:SetEmulation(kTechId.HallucinateHive)
                hallucination:SetAttached(techPoint)
                hallucination:SetCoords(coords)
                
            end
        
        end

    end

end

Shared.LinkClassToMap("HallucinationCloud", HallucinationCloud.kMapName, networkVars)