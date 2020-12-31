local function ApplyDamage(self, targetList)

    for index, targetEntry in ipairs(targetList) do
    
        local entity = Shared.GetEntity(targetEntry.id)     

        if entity and self.destroyCondition and self.destroyCondition(self, entity) then
            DestroyEntity(self)
            break
        end
        
        -- if entity and self.targetIds[entity:GetId()] and entity:GetCanTakeDamage() and (not self.immuneCondition or not self.immuneCondition(self, entity)) then
        -- CompMod: Fix bug with DotMarker and single targets
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

debug.setupvaluex(DotMarker.OnUpdate, "ApplyDamage", ApplyDamage)
