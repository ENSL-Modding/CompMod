-- revert eggs
-- embryo hp depends on lifeform
-- hives dont heal eggs 

local kMinGestationTime = 1
local kUpdateGestationTime = 0.1

local function UpdateGestation(self)

    -- Cannot spawn unless alive.
    if self:GetIsAlive() and self.gestationClass ~= nil then

        if not self.gestateEffectsTriggered then

            self:TriggerEffects("player_start_gestate")
            self.gestateEffectsTriggered = true

        end

        -- Take into account catalyst effects
        local amount = GetAlienCatalystTimeAmount(kUpdateGestationTime, self)
        self.evolveTime = self.evolveTime + kUpdateGestationTime + amount

        self.evolvePercentage = Clamp((self.evolveTime / self.gestationTime) * 100, 0, 100)

        if self.evolveTime >= self.gestationTime then

            -- Replace player with new player
            local newPlayer = self:Replace(self.gestationClass)
            newPlayer:SetCameraDistance(0)

            local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
            local newAlienExtents = LookupTechData(newPlayer:GetTechId(), kTechDataMaxExtents)

            -- Add a bit to the extents when looking for a clear space to spawn.
            local spawnBufferExtents = Vector(0.1, 0.1, 0.1)

            --validate the spawn point before using it
            if self.validSpawnPoint and GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, self.validSpawnPoint + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterTwo(self, newPlayer)) then
                newPlayer:SetOrigin(self.validSpawnPoint)
            else
                for index = 1, 100 do

                    local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))

                    if spawnPoint then

                        newPlayer:SetOrigin(spawnPoint)
                        break

                    end

                end

            end

            newPlayer:DropToFloor()

            self:TriggerEffects("player_end_gestate")

            -- Now give new player all the upgrades they purchased
            local upgradesGiven = 0

            for index, upgradeId in ipairs(self.evolvingUpgrades) do

                if newPlayer:GiveUpgrade(upgradeId) then
                    upgradesGiven = upgradesGiven + 1
                end

            end

            local healthScalar = self.storedHealthScalar or 1
            local armorScalar = self.storedArmorScalar or 1

            newPlayer:SetHealth(healthScalar * LookupTechData(self.gestationTypeTechId, kTechDataMaxHealth))
            newPlayer:SetArmor(armorScalar * LookupTechData(self.gestationTypeTechId, kTechDataMaxArmor))

            newPlayer:UpdateArmorAmount()
            newPlayer:SetHatched()
            newPlayer:TriggerEffects("egg_death")

            if self.resOnGestationComplete then
                newPlayer:AddResources(self.resOnGestationComplete)
            end

            local newUpgrades = newPlayer:GetUpgrades()
            if #newUpgrades > 0 then
                local class = newPlayer:GetClassName()
                newPlayer.lastUpgradeList = newPlayer.lastUpgradeList or {}
                newPlayer.lastUpgradeList[class] = newPlayer:GetUpgrades()
            end

            -- Notify team

            local team = self:GetTeam()

            if team and team.OnEvolved then

                team:OnEvolved(newPlayer:GetTechId())

                for _, upgradeId in ipairs(self.evolvingUpgrades) do

                    if team.OnEvolved then
                        team:OnEvolved(upgradeId)
                    end

                end

            end

            -- Return false so that we don't get called again if the server time step
            -- was larger than the callback interval
            return false

        end

    end

    return true

end

function Embryo:SetGestationData(techIds, previousTechId, healthScalar, armorScalar)

    -- Save upgrades so they can be given when spawned
    self.evolvingUpgrades = {}
    table.copy(techIds, self.evolvingUpgrades)

    self.gestationClass = nil

    for i, techId in ipairs(techIds) do
        self.gestationClass = LookupTechData(techId, kTechDataGestateName)
        if self.gestationClass then
            -- Remove gestation tech id from "upgrades"
            self.gestationTypeTechId = techId
            table.removevalue(self.evolvingUpgrades, self.gestationTypeTechId)
            break
        end
    end

    -- Upgrades don't have a gestate name, we want to gestate back into the
    -- current alien type, previousTechId.
    if not self.gestationClass then
        self.gestationTypeTechId = previousTechId
        self.gestationClass = LookupTechData(previousTechId, kTechDataGestateName)
    end
    self.gestationStartTime = Shared.GetTime()

    local lifeformTime = ConditionalValue(self.gestationTypeTechId ~= previousTechId, self:GetGestationTime(self.gestationTypeTechId), 0)

    local newUpgradesAmount = 0
    local currentUpgrades = self:GetUpgrades()

    for _, upgradeId in ipairs(self.evolvingUpgrades) do

        if not table.icontains(currentUpgrades, upgradeId) then
            newUpgradesAmount = newUpgradesAmount + 1
        end

    end

    self.gestationTime = ConditionalValue(Shared.GetDevMode() or GetGameInfoEntity():GetWarmUpActive(), 1, lifeformTime + newUpgradesAmount * kUpgradeGestationTime)

    self.gestationTime = math.max(kMinGestationTime, self.gestationTime)

    if Embryo.gFastEvolveCheat then
        self.gestationTime = 5
    end

    self.evolveTime = 0

    local maxHealth = LookupTechData(self.gestationTypeTechId, kTechDataMaxHealth) * 0.3 + 100
    maxHealth = math.round(maxHealth * 0.1) * 10

    self:SetMaxHealth(maxHealth)
    self:SetHealth(maxHealth * healthScalar)
    self:SetMaxArmor(0)
    self:SetArmor(0)

    self.storedHealthScalar = healthScalar
    self.storedArmorScalar = armorScalar

    -- we reset the upgrades entirely and set them again, simplifies the code
    self:ClearUpgrades()

end

ReplaceLocals(Embryo.OnInitialized, {UpdateGestation = UpdateGestation})

function Egg:GetMaturityRate()
	return kEggMaturationTime
end

function Egg:GetMatureMaxHealth()
	return kMatureEggHealth
end

function Egg:GetMatureMaxArmor()
	return kMatureEggArmor
end

if Server then

	local function GestatePlayer(self, player, fromTechId)

   		player.oneHive = false
	    player.twoHives = false
	    player.threeHives = false

	    -- local playerHealthScalar = player:GetHealthScalar()
	    -- local playerArmorScalar = player:GetArmorScalar()
	    local newPlayer = player:Replace(Embryo.kMapName)
	    if not newPlayer:IsAnimated() then
	        newPlayer:SetDesiredCamera(1.1, { follow = true, tweening = kTweeningFunctions.easeout7 })
	    end
	    newPlayer:SetCameraDistance(kGestateCameraDistance)

	    -- Eliminate velocity so that we don't slide or jump as an egg
	    newPlayer:SetVelocity(Vector(0, 0, 0))

	    newPlayer:DropToFloor()

	    local techIds = { self:GetGestateTechId() }
	    -- newPlayer:SetGestationData(techIds, fromTechId, playerHealthScalar, playerArmorScalar)
	    newPlayer:SetGestationData(techIds, fromTechId, 1, 1)

	end

	ReplaceLocals(Egg.OnUse, {GestatePlayer = GestatePlayer})
end

local function UpdateHealing(self)

    if GetIsUnitActive(self) and not self:GetGameEffectMask(kGameEffect.OnFire) then

        if self.timeOfLastHeal == nil or Shared.GetTime() > (self.timeOfLastHeal + Hive.kHealthUpdateTime) then

            local players = GetEntitiesForTeam("Player", self:GetTeamNumber())
            for index, player in ipairs(players) do
                if player:GetIsAlive()and ((player:GetOrigin() - self:GetOrigin()):GetLength() < Hive.kHealRadius) then
                    player:AddHealth(math.max(10, player:GetMaxHealth() * Hive.kHealthPercentage), true)
                end
            end

            self.timeOfLastHeal = Shared.GetTime()

        end

    end

end

ReplaceLocals(Hive.OnUpdate, {UpdateHealing = UpdateHealing})
