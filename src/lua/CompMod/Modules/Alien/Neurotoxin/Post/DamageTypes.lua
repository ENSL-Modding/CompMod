local function ApplyNeurotoxinHit(attacker, target, tickDamage, neuroLevel)
    local dotMarker = CreateEntity(DotMarker.kMapName, target:GetOrigin(), attacker:GetTeamNumber())
    dotMarker:SetTechId(kTechId.Neurotoxin)
    dotMarker:SetDamageType(kDamageType.Gas)
    dotMarker:SetLifeTime(1 + neuroLevel)
    dotMarker:SetDamage(tickDamage)
    dotMarker:SetRadius(0)
    dotMarker:SetDamageIntervall(1)
    dotMarker:SetDotMarkerType(DotMarker.kType.SingleTarget)
    dotMarker:SetTargetEffectName("poison_dart_trail")
    dotMarker:SetDeathIconIndex(kDeathMessageIcon.Neurotoxin)
    dotMarker:SetIsAffectedByCrush(false)
    dotMarker:SetOwner(attacker)
    dotMarker:SetAttachToTarget(target, target:GetOrigin())

    dotMarker:SetDestroyCondition(
        function(self, target)
            return not target:GetIsAlive()
        end
    )
end

local oldGetUpgradedAlienDamage = NS2Gamerules_GetUpgradedAlienDamage
function NS2Gamerules_GetUpgradedAlienDamage( target, attacker, doer, damage, armorFractionUsed, _, damageType )
    damage, armorFractionUsed = oldGetUpgradedAlienDamage(target, attacker, doer, damage, armorFractionUsed, _, damageType)
    
    if not doer then return damage, armorFractionUsed end

    local isAffectedByNeurotoxin = doer.GetIsAffectedByNeurotoxin and attacker:GetHasUpgrade(kTechId.Neurotoxin) and doer:GetIsAffectedByNeurotoxin()

    if Server then
        if isAffectedByNeurotoxin then
            local neuroLevel = attacker:GetVeilLevel()
            if neuroLevel > 0 then
                if target:isa("Player") and target:GetTeamNumber() ~= attacker:GetTeamNumber() then
                    local tickDamage = doer:GetNeurotoxinTickDamage()
                    if tickDamage > 0 then
                        ApplyNeurotoxinHit(attacker, target, tickDamage, neuroLevel)
                    end
                end
            end
        end
    end

    return damage, armorFractionUsed
end
