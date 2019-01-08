-- hallucinating a skulk requires a skulk to be there


if Server then

    local AllowedToHallucinate = CompMod:GetLocalVariable(HallucinationCloud.Perform, "AllowedToHallucinate")

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

        -- search for alien in range, cloak them and create a hallucination
        local hallucinatePlayers = {}
        local numHallucinatePlayers = 0
        for _, alien in ipairs(GetEntitiesForTeamWithinRange("Alien", self:GetTeamNumber(), self:GetOrigin(), HallucinationCloud.kRadius)) do

            if alien:GetIsAlive() and not alien:isa("Embryo") and not HasMixin(alien, "PlayerHallucination") then

                table.insert(hallucinatePlayers, alien)
                numHallucinatePlayers = numHallucinatePlayers + 1

            end

        end

        -- sort by techId, so the higher life forms are prefered
        local function SortByTechId(alienOne, alienTwo)
            return alienOne:GetTechId() > alienTwo:GetTechId()
        end

        table.sort(hallucinatePlayers, SortByTechId)

        -- limit max num of hallucinations to 1/3 of team size
        local teamSize = self:GetTeam():GetNumPlayers()
        local maxAllowedHallucinations = math.max(1, math.floor(teamSize * kPlayerHallucinationNumFraction))
        local hallucinationsCreated = 0

        for index, alien in ipairs(hallucinatePlayers) do

            if AllowedToHallucinate(alien) then

                local newAlienExtents = LookupTechData(alien:GetTechId(), kTechDataMaxExtents)
                local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(newAlienExtents)

                local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, alien:GetModelOrigin(), 0.5, 5)

                if spawnPoint then

                    local hallucinatedPlayer = CreateEntity(alien:GetMapName(), spawnPoint, self:GetTeamNumber())

                    -- make drifter keep a record of any hallucinations created from its cloud, so they
                    -- die when drifter dies.
                    self:RegisterHallucination(hallucinatedPlayer)

                    if alien:isa("Alien") then
                        hallucinatedPlayer:SetVariant(alien:GetVariant())
                    end
                    hallucinatedPlayer.isHallucination = true
                    InitMixin(hallucinatedPlayer, PlayerHallucinationMixin)
                    InitMixin(hallucinatedPlayer, SoftTargetMixin)
                    InitMixin(hallucinatedPlayer, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance })

                    hallucinatedPlayer:SetName(alien:GetName())
                    hallucinatedPlayer:SetHallucinatedClientIndex(alien:GetClientIndex())

                    hallucinationsCreated = hallucinationsCreated + 1

                end

            end

            if hallucinationsCreated >= maxAllowedHallucinations then
                break
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
