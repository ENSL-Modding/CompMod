-- add neurotoxin data
CompMod:AddTechId("Neurotoxin")
CompMod:AddTech({
    [kTechDataId] = kTechId.Neurotoxin,
    [kTechDataCategory] = kTechId.ShadeHive,
    [kTechDataDisplayName] = "Neurotoxin",
    [kTechDataSponitorCode] = "N",
    [kTechDataTooltipInfo] = "Each hit inflicts a poison toxin, hurting marines over time.",
    [kTechDataCostKey] = kFocusCost,
})
CompMod:AddBuyNode(kTechId.Neurotoxin, kTechId.Veil, kTechId.None, kTechId.AllAliens)
CompMod:AddTechIdToMaterialOffset(kTechId.Neurotoxin, 174) -- 174 is the position for focus, which we replaced with neurotoxin
CompMod:ReplaceGUITexture("ui/buildmenu.dds", "ui/compmod_buildmenu.dds")
CompMod:ReplaceGUITexture("ui/inventory_icons.dds", "ui/compmod_inventory_icons.dds")

local techUpgradesTable = CompMod:GetLocalVariable(GetTechIdsFromBitMask, "techUpgradesTable")

for i,v in ipairs(techUpgradesTable) do
  if v == kTechId.Focus then
    techUpgradesTable[i] = kTechId.Neurotoxin
  end
end

local techUpgradesBitmask = CreateBitMask(techUpgradesTable)

ReplaceLocals(GetTechIdsFromBitMask, { techUpgradesTable = techUpgradesTable })
ReplaceLocals(PlayerInfoEntity.UpdateScore, { techUpgradesBitmask = techUpgradesBitmask })
ReplaceLocals(GetTechIdsFromBitMask, { techUpgradesBitmask = techUpgradesBitmask })

if Server then
  local kUpgradeStructureTable = CompMod:GetLocalVariable(AlienTeam.GetUpgradeStructureTable, "kUpgradeStructureTable")

  for ichamber,vchamber in pairs(kUpgradeStructureTable) do
    if vchamber.techId == kTechId.Veil then
      for iup,vup in ipairs(vchamber.upgrades) do
        if vup == kTechId.Focus then
          kUpgradeStructureTable[ichamber].upgrades[iup] = kTechId.Neurotoxin
        end
      end
    end
  end

  ReplaceLocals(AlienTeam.GetUpgradeStructureTable, { kUpgradeStructureTable = kUpgradeStructureTable })
end

-- Neurotoxin implementation
local function GetNeurotoxinDamage(weapon)
    local damageBonus = kSkulkNeuroToxinDamage
    if weapon == kTechId.Swipe or weapon == kTechId.Stab then
        damageBonus = kFadeNeuroToxinDamage
    elseif weapon == kTechId.LerkBite then
        damageBonus = kLerkNeuroToxinDamage
    elseif weapon == kTechId.Gore then
        damageBonus = kOnosNeuroToxinDamage
    elseif weapon == kTechId.Spit then
        damageBonus = kGorgeNeuroToxinDamage
    end

    return damageBonus
end

-- should probably move away from dotmarker in the future
local function SetNeurotoxic(attacker, target, dps, neuroLevel)

    local dotMarker = CreateEntity(DotMarker.kMapName, target:GetOrigin(), attacker:GetTeamNumber())
    dotMarker:SetTechId(kTechId.Neurotoxin)
    dotMarker:SetDamageType(kDamageType.Gas)
    dotMarker:SetLifeTime(0.1 + neuroLevel)
    dotMarker:SetDamage(dps)
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
function NS2Gamerules_GetUpgradedAlienDamage( target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint, weapon )
    damage, armorFractionUsed = oldGetUpgradedAlienDamage(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint, weapon)

    if not doer then return damage, armorFractionUsed end

    local isAffectedByNeurotoxin = doer.GetIsAffectedByNeurotoxin and attacker:GetHasUpgrade( kTechId.Neurotoxin ) and doer:GetIsAffectedByNeurotoxin()

    if Server then
        if isAffectedByNeurotoxin then
            local neuroLevel = attacker:GetVeilLevel()
            if neuroLevel > 0 then
                if target:isa("Player") then
                    local dps = GetNeurotoxinDamage(weapon)
                    if dps > 0 then
                        SetNeurotoxic(attacker, target, dps, neuroLevel)
                    end
                end
            end
        end
    end

    return damage, armorFractionUsed
end

-- add affectedby funcs

function Ability:GetIsAffectedByNeurotoxin()
    return false
end

function BiteLeap:GetIsAffectedByNeurotoxin()
    return self.primaryAttacking
end

function Gore:GetIsAffectedByNeurotoxin()
    return true
end

function LerkBite:GetIsAffectedByNeurotoxin()
    return self.primaryAttacking
end

function SpitSpray:GetIsAffectedByNeurotoxin()
    return self.primaryAttacking
end

function Spit:GetIsAffectedByNeurotoxin()
    return true
end

function StabBlink:GetIsAffectedByNeurotoxin()
    return self.primaryAttacking
end

function SwipeBlink:GetIsAffectedByNeurotoxin()
    return self.primaryAttacking
end

-- DotMarker bug fix
local function ApplyDamage(self, targetList)

    for index, targetEntry in ipairs(targetList) do

        local entity = Shared.GetEntity(targetEntry.id)

        if entity and self.destroyCondition and self.destroyCondition(self, entity) then
            DestroyEntity(self)
            break
        end

        if entity and (self.dotMarkerType == self.kType.SingleTarget and self.targetId == entity:GetId() or self.targetIds[entity:GetId()]) and entity:GetCanTakeDamage() and (not self.immuneCondition or not self.immuneCondition(self, entity)) then

            local worldImpactPoint = entity:GetCoords():TransformPoint(targetEntry.impactPoint)

            --local previousHealthScalar = entity:GetHealthScalar()
            -- we don't need to specify a surface here, since dot marker can only damage actual targets and ignores world geometry
            self:DoDamage(targetEntry.damage * self.damageIntervall, entity, worldImpactPoint, -targetEntry.impactPoint, "none")
            --local newHealthScalar = entity:GetHealthScalar()

            --entity:TriggerEffects(self.targetEffectName, { doer = self, effecthostcoords = Coords.GetTranslation(worldImpactPoint) })

        end

    end

end

ReplaceLocals(DotMarker.OnUpdate, {ApplyDamage = ApplyDamage})
