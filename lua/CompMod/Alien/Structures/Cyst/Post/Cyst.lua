local CreateBetween = CompMod:GetLocalVariable(CreateBetweenEntities, "CreateBetween", false)

--
-- Returns a parent and the track from that parent, or nil if none found.
--
function GetCystParentFromPoint(origin, normal, connectionMethodName, optionalIgnoreEnt, teamNumber)

    PROFILE("Cyst:GetCystParentFromPoint")

    local ents = GetSortedListOfPotentialParents(origin, teamNumber, kCystMaxParentRange, kHiveCystParentRange)

    if Client then
        MarkPotentialDeployedCysts(ents, origin)
    end

    teamNumber = teamNumber or kAlienTeamType
    for i = 1, #ents do
        local ent = ents[i]

        -- must be either a built hive or an cyst with a connected infestation
        if optionalIgnoreEnt ~= ent and
                ((ent:isa("Hive") and ent:GetIsBuilt()) or (ent:isa("Cyst") and ent[connectionMethodName](ent))) then

            local range = (origin - ent:GetOrigin()):GetLength()
            if range <= ent:GetCystParentRange() then
                -- check if we have a track from the entity to origin
                local endOffset = 0.00
                if ent:isa("Hive") then
                    endOffset = 3
                end

                -- The pathing somehow is able to return two different path ((A -> B) != (B -> A))
                -- Ex: Cysting in derelict between the RT in "Turbines" (a bit above the rt), and "Heat Transfer"
                --     You can check those path with a drifter, it will take two different route.
                local isReachable1, path1 = CreateBetween(origin, normal, ent:GetOrigin(), ent:GetCoords().yAxis, 0.00, endOffset)
                if isReachable1 and path1 then

                    -- Check that the total path length is within the range.
                    local pathLength1 = GetPointDistance(path1)
                    if pathLength1 <= ent:GetCystParentRange() then
                        return ent, path1
                    end

                    -- If the first path from A->B failed, we want to double check B->A and see if that worked.
                    local isReachable2, path2 = CreateBetween(ent:GetOrigin(), ent:GetCoords().yAxis, origin, normal, endOffset, 0.00)
                    if isReachable2 and path2 then
                        local pathLength2 = GetPointDistance(path2)
                        if pathLength2 <= ent:GetCystParentRange() then
                            local points = PointArray()
                            if cystChainDebug then
                                Log("GetCystParentFromPoint() Regular path didn't worked, using the reverse")
                            end

                            -- Reverse the path points so we still get an array of points from A to B
                            for j = 1, #path2 do
                                Pathing.InsertPoint(points, 1, path2[j])
                            end
                            return ent, points
                        end
                    end
                end
            end
        end
    end

    return nil, nil
end