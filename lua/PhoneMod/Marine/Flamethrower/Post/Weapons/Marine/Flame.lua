if Server then

    function Flame:Detonate(targetHit)
    
        local player = self:GetOwner()
        local ents = GetEntitiesWithMixinWithinXZRange("Live", self:GetOrigin(), self.kDamageRadius)

        if targetHit then
            table.insert(ents, targetHit)
        end

        local gamerules = GetGamerules()
        local origin = self:GetOrigin()
        local abs = math.abs
        for i = 1, #ents do

            local ent = ents[i]
            local entOrigin = ent:GetModelOrigin()
            if abs(entOrigin.y - origin.y) <= self.kDamageRadius and
                    (ent ~= self:GetOwner() or gamerules:GetFriendlyFire()) and
                    (GetAreEnemies(self:GetOwner(), ent)) then -- stop flame puddles melting your friendly neighbourhood marines

                local toEnemy = GetNormalizedVector( entOrigin - origin )
                self:DoDamage(self.kDamage, ent, ent:GetModelOrigin(), toEnemy)
                
            end
            
        end
        
    end
end
