if Server then

    local kEchoDelay = 4 -- lowered from 5 seconds

    local gTeleportClassnames = nil
    local GetTeleportClassname = CompMod:GetLocalVariable(Shift.TriggerEcho, "GetTeleportClassname")

    function Shift:TriggerEcho(techId, position)

        local teleportClassname = GetTeleportClassname(techId)
        local teleportCost = LookupTechData(techId, kTechDataCostKey, 0)

        local success = false

        local validPos = GetIsBuildLegal(techId, position, 0, kStructureSnapRadius, self:GetOwner(), self)

        local builtStructures = {}
        local matureStructures = {}

        if validPos then

            local teleportAbles = GetEntitiesForTeamWithinXZRange(teleportClassname, self:GetTeamNumber(), self:GetOrigin(), kEchoRange)

            for index, entity in ipairs(teleportAbles) do
                if HasMixin(entity, "Construct") and entity:GetIsBuilt() then
                      table.insert(builtStructures, entity)
                      if HasMixin(entity, "Maturity") and entity:GetIsMature() then
                          table.insert(matureStructures, entity)
                      end
                end
            end

            if #matureStructures > 0 then
                teleportAbles = matureStructures
            elseif #builtStructures > 0 then
                teleportAbles = builtStructures
            end

            Shared.SortEntitiesByDistance(self:GetOrigin(), teleportAbles)

            for _, teleportAble in ipairs(teleportAbles) do

                if teleportAble:GetCanTeleport() then

                    teleportAble:TriggerTeleport(kEchoDelay, self:GetId(), position, teleportCost)

                    if HasMixin(teleportAble, "Orders") then
                        teleportAble:ClearCurrentOrder()
                    end

                    self:TriggerEffects("shift_echo")
                    success = true
                    self.echoActive = true
                    self.timeLastEcho = Shared.GetTime()
                    break

                end

            end

        end

        return success

    end
end
