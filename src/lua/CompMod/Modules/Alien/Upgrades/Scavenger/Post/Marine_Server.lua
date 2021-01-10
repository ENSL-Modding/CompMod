-- TODO: All this should really be in a mixin
local logger = CompMod:GetModule('logger')

local oldOnTakeDamage = Marine.OnTakeDamage
function Marine:OnTakeDamage(damage, attacker, doer, point, direction, damageType, preventAlert)
    oldOnTakeDamage(self, damage, attacker, doer, point, direction, damageType, preventAlert)

    -- Add damage data for Scavenger upgrade
    if doer and attacker and attacker:isa("Player") and GetAreEnemies(self, attacker) then
        local attackerId = attacker:GetId()
        local damageEntry = {}
        damageEntry.attacker = attackerId
        damageEntry.damage = damage
        damageEntry.time = Shared.GetTime()
        damageEntry.shouldScavenge = doer.GetShouldScavenge and doer:GetShouldScavenge() or false
        table.insert(self.damageHistory, damageEntry)
    end
end

local oldPreOnKill = Marine.PreOnKill
function Marine:PreOnKill(attacker, doer, point, direction)
    oldPreOnKill(self, attacker, doer, point, direction)

    -- Apply health to attacking Lifeforms with Scavenger
    if #self.damageHistory > 50 then
        logger:PrintWarn("Processing %s entries for Marine")
    end

    -- Do a first pass over attackers:
    --   Find the total damage done to the Marine in the last kScavengerDamageTimeout seconds
    --   Create list of attackers and their damage, if valid for scavenger
    local totalDamage = 0
    local attackers = {} -- list of attacking entIds
    local attackerDamage = {} -- entId indexed list of damage
    local toRemove = {}
    local currentTime = Shared.GetTime()
    for i, damageEntry in ipairs(self.damageHistory) do
        -- If the entry has not expired
        if damageEntry.time + kScavengerDamageTimeout >= currentTime then
            totalDamage = totalDamage + damageEntry.damage

            if damageEntry.shouldScavenge then
                -- If we've not seen this attacker before, initialise it
                if not attackerDamage[damageEntry.attacker] then
                    attackerDamage[damageEntry.attacker] = 0
                    table.insert(attackers, damageEntry.attacker)
                end

                attackerDamage[damageEntry.attacker] = attackerDamage[damageEntry.attacker] + damageEntry.damage
            end
        end
    end

    -- Iterate over attackers and apply heals if possible
    for _, attackerId in ipairs(attackers) do 
        local ent = Shared.GetEntity(attackerId)
        if ent and ent.ApplyScavengerHeal then
            local healScalar = attackerDamage[attackerId] / totalDamage
            ent:ApplyScavengerHeal(healScalar)
        end
    end
end
