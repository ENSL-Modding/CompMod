-- Check tech id and create guides showing where extractors, harvesters, infantry portals, etc. go. Also draw
-- visual range for selected units if they are specified.
function Commander:UpdateGhostGuides()
    self:DestroyGhostGuides(true)
    self.selectedEntities = self:GetSelection()

    local techId = self.currentTechId
    if techId ~= nil and techId ~= kTechId.None then
        -- check if entity has a special ghost guide method
        local method = LookupTechData(techId, kTechDataGhostGuidesMethod, nil)

        if method then
            local entities, ranges = method(self)
            for _, entity in ipairs(entities) do
                local radius = ranges[entity]
                if radius then
                    self:AddGhostGuide(Vector(entity:GetOrigin()), radius)
                end
            end
        end

        -- No model for the ghost, but still want range indicator. (Observatory Scan, for example)
        if GhostModelUI_GetAlternativeGhostGuides() and not CommanderUI_GetMouseIsOverUI() then
            local radius = LookupTechData(techId, kVisualRange, nil)
            if radius then
                local xScalar, yScalar = Client.GetCursorPos()
                local x = xScalar * Client.GetScreenWidth()
                local y = yScalar * Client.GetScreenHeight()
                local targetTrace = GetCommanderPickTarget(self, CreatePickRay(self, x, y), false, true)
                local origin = Vector(targetTrace.endPoint)

                if type(radius) == "table" then
                    for i = 1, #radius do
                        self:AddGhostGuide(origin, radius[i])
                    end
                else
                    self:AddGhostGuide(origin, radius)
                end
            end
        end

        -- If entity can only be placed within range of attach structures, get all the ents that
        -- count for this and draw circles around them
        local ghostRadius = LookupTechData(techId, kStructureAttachRange, 0)
        if ghostRadius ~= 0 then
            -- Lookup attach entity
            local attachId = LookupTechData(techId, kStructureAttachId)

            -- Handle table of attach ids
            local supportingTechIds = {}
            if type(attachId) == "table" then
                for _, currentAttachId in ipairs(attachId) do
                    table.insert(supportingTechIds, currentAttachId)
                end
            else
                table.insert(supportingTechIds, attachId)
            end

            for _, ent in ipairs(GetEntsWithTechIdIsActive(supportingTechIds)) do
                self:AddGhostGuide(Vector(ent:GetOrigin()), ghostRadius)
            end
        else
            -- Otherwise, draw only the free attach entities for this build tech (this is the common case)
            for _, ent in ipairs(GetFreeAttachEntsForTechId(techId)) do
                self:AddGhostGuide(Vector(ent:GetOrigin()), kStructureSnapRadius)
            end
        end

        -- If attach range specified, then structures don't go on this attach point, but within this range of it
        self.attachRange = LookupTechData(techId, kStructureAttachRange, nil)
    end

    -- Now draw visual ranges for selected units
    for _, entity in ipairs(self.selectedEntities) do
        -- Draw visual range on structures that specify it (no building effects)
        -- if GetVisualRadius() returns an array of radiuses, draw them all
        local visualRadius = entity:GetVisualRadius()
        if visualRadius then
            if type(visualRadius) == "table" then
                for i = 1, #visualRadius do
                    local r = visualRadius[i]
                    self:AddGhostGuide(Vector(entity:GetOrigin()), r)
                end
            else
                local techId = entity:GetTechId()
                -- CompMod: Implement AdrenalineRush outlines
                if techId == kTechId.Crag then
                    self:AddGhostGuide(Vector(entity:GetOrigin()), entity:GetHealRadius())
                elseif techId == kTechId.Shade then
                    self:AddGhostGuide(Vector(entity:GetOrigin()), entity:GetCloakRadius())
                elseif techId == kTechId.Whip then
                    self:AddGhostGuide(Vector(entity:GetOrigin()), entity:GetWhipRange())
                else
                    self:AddGhostGuide(Vector(entity:GetOrigin()), visualRadius)
                    if techId == kTechId.Shift then
                        self:AddGhostGuide(Vector(entity:GetOrigin()), entity:GetEnergizeRange())
                    end
                end
            end
        end
    end
end