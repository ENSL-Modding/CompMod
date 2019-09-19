-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CommAbilities\Marine\EMPBlast.lua
--
--      Created by: Andreas Urwalek (andi@unknownworlds.com)
--
--      Takes kEMPBlastEnergyDamage energy away from all aliens in detonation radius.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'EMPBlast' (CommanderAbility)

EMPBlast.kMapName = "empblast"

local kSplashEffect = PrecacheAsset("cinematics/marine/mac/empblast.cinematic")
local kRadius = kPowerSurgeEMPDamageRadius
local kType = CommanderAbility.kType.Instant

local networkVars =
{
}

function EMPBlast:OnCreate()
    CommanderAbility.OnCreate(self)

    InitMixin(self, DamageMixin)
end

function EMPBlast:GetStartCinematic()
    return kSplashEffect
end

function EMPBlast:GetType()
    return kType
end

if Server then

    function EMPBlast:Perform()

        self:TriggerEffects("comm_powersurge", { effecthostcoords = self:GetCoords() }) --TODO Refactor CommanderAbility to use EffectsManager, update this called event once done (add sound)

        for _, alien in ipairs(GetEntitiesForTeamWithinRange("Alien", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kRadius)) do
            self:DoDamage(kPowerSurgeEMPDamage, alien, alien:GetOrigin(), GetNormalizedVector(alien:GetOrigin() - self:GetOrigin()), "none")
            alien:SetElectrified(kPowerSurgeEMPElectrifiedDuration)
            alien:TriggerEffects("emp_blasted")
        end

    end

end

function EMPBlast:GetDeathIconIndex()
    return kDeathMessageIcon.EMPBlast
end


if Server then

    local function OnCommandEmpAll(client, distance)

        if Shared.GetCheatsEnabled() then
            
            --heavy handed, meh, it's a cheat command
            local ents = GetEntitiesMatchAnyTypesForTeam({"ScriptActor"}, kMarineTeamType)

            local invalidClasses = 
            {
                "Marine", "JetpackMarine", "Jetpack", "Pistol", "Axe", "Exo",
                "Medpack", "Ammopack", "Catpack",
                "Shotgun", "Flamethrower", "Grenadelauncher",
                "Mine", "LayMines", "PulseGrenade", "GasGrenade",
                "Grenade", "ClusterGrenade", "Exosuit", "Rifle", "Flame",
                "HeavyMachineGun", "Minigun", "Railgun", "Welder", "Builder",
                "PowerPoint", "CommandStation", "ClusterFragment"
            }

            for _, building in ipairs(ents) do

                if not table.icontains(invalidClasses, building:GetClassName()) then
                    local values = { origin = building:GetOrigin(), teamNumber = kMarineTeamType }
                    local blast = CreateEntity( EMPBlast.kMapName, building:GetOrigin(), building:GetTeamNumber() )
                end
                
            end
            
        end
        
    end

    Event.Hook("Console_empall", OnCommandEmpAll)
    
end



Shared.LinkClassToMap("EMPBlast", EMPBlast.kMapName, networkVars)