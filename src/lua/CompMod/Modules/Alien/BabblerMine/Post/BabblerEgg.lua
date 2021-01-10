if Server then
    function BabblerEgg:Explode()

        local dotMarker = CreateEntity(DotMarker.kMapName, self:GetOrigin(), self:GetTeamNumber())
        dotMarker:SetTechId(kTechId.BabblerEgg)
        dotMarker:SetDamageType(kBabblerEggDamageType)
        dotMarker:SetLifeTime(kBabblerEggDamageDuration)
        dotMarker:SetDamage(kBabblerEggDamage)
        dotMarker:SetRadius(kBabblerEggDamageRadius)
        dotMarker:SetDamageIntervall(kBabblerEggDotInterval)
        dotMarker:SetDotMarkerType(DotMarker.kType.Static)
        dotMarker:SetTargetEffectName("bilebomb_onstructure")
        dotMarker:SetDeathIconIndex(kDeathMessageIcon.BileBomb)
        dotMarker:SetOwner(self:GetOwner())

        local function NoFalloff()
            return 0
        end
        dotMarker:SetFallOffFunc(NoFalloff)

        dotMarker:TriggerEffects("bilebomb_hit")
        dotMarker.immuneCondition = function (self, entity, damage)
            if entity:GetHealth() - damage < 5 then
                return true
            end
            
            return false
        end

        DestroyEntity(self)
    end
end