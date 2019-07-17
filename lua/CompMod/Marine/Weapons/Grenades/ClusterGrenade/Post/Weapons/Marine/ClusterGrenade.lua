-- cluster grenades set stuff on fire
if Server then
    -- Cluster Grenades set structures and players on fire
    -- Thanks Dragon :)
    local function IgniteNearbyEntities(self, range)
        local hitEntities = GetEntitiesWithMixinWithinRange("Fire", self:GetOrigin(), range)
        local player = self:GetOwner()
        table.removevalue(hitEntities, self)
        if player then
            for _, hitEnt in ipairs(hitEntities) do
                if not hitEnt:isa("Marine") then
                    hitEnt:SetOnFire(player, self)
                end
            end
        end
    end

    -- Cluster Grenades burn and destroy abilities
    local function BurnNearbyAbilities(self, range)
        --TODO: should range be cluster size or individual cloud size?
        local grenadePos = self:GetOrigin()

        -- lerk spores
        local spores = GetEntitiesWithinRange("SporeCloud", grenadePos, range)

        -- lerk umbra
        local umbras = GetEntitiesWithinRange("CragUmbra", grenadePos, range)

        -- bilebomb (gorge and contamination), whip bomb
        local bombs = GetEntitiesWithinRange("Bomb", grenadePos, range)
        table.copy(GetEntitiesWithinRange("WhipBomb", grenadePos, range), bombs, true)

        for _, spore in ipairs(spores) do
            self:TriggerEffects("burn_spore", {effecthostcoords = Coords.GetTranslation(spore:GetOrigin())})
            DestroyEntity(spore)
        end

        for _, umbra in ipairs(umbras) do
            self:TriggerEffects("burn_umbra", {effecthostcoords = Coords.GetTranslation(umbra:GetOrigin())})
            DestroyEntity(umbra)
        end

        for _, bomb in ipairs(bombs) do
            self:TriggerEffects("burn_bomb", {effecthostcoords = Coords.GetTranslation(bomb:GetOrigin())})
            DestroyEntity(bomb)
        end
    end

    local oldClusterGrenadeDetonate = ClusterGrenade.Detonate
    function ClusterGrenade:Detonate(targetHit)
        IgniteNearbyEntities(self, kClusterGrenadeDamageRadius)
        BurnNearbyAbilities(self, kClusterGrenadeDamageRadius)

        oldClusterGrenadeDetonate(self, targetHit)
    end
end

ClusterFragment.MinDetonationTime = 0.7
ClusterFragment.MaxDetonationTime = 1.7

function ClusterFragment:OnCreate()

    Projectile.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, DamageMixin)

    if Server then
        self:AddTimedCallback(ClusterFragment.TimedDetonateCallback, math.random(self.MinDetonationTime, self.MaxDetonationTime))
    elseif Client then
        self:AddTimedCallback(ClusterFragment.CreateResidue, 0.06)
    end

end
