--cysts take damage when not connected
local function ServerUpdate(self, deltaTime)
    if not self:GetIsAlive() then
        return
    end

    if self.bursted then
        self.bursted = self.timeBursted + Cyst.kBurstDuration > Shared.GetTime()
    end

    local now = Shared.GetTime()

    if now > self.nextUpdate then

        local connectedNow = self:GetIsActuallyConnected()

        -- the very first time we are placed, we try to connect
        if not self.madeInitialConnectAttempt then

            if not connectedNow then
                connectedNow = self:TryToFindABetterParent()
            end

            self.madeInitialConnectAttempt = true

        end

        -- try a single reconnect when we become disconnected
        if self.connected and not connectedNow then
            connectedNow = self:TryToFindABetterParent()
        end

        -- if we become connected, see if we have any unconnected cysts around that could use us as their parents
        if not self.connected and connectedNow then
            self:ReconnectOthers()
        end

        if connectedNow ~= self.connected then
            self.connected = connectedNow
            self:MarkBlipDirty()
        end

        -- avoid clumping; don't use now when calculating next think time (large kThinkTime)
        self.nextUpdate = self.nextUpdate + Cyst.kThinkTime

        -- become immature quickly if parents aren't around... that makes sense on so many levels ;)
        -- self:SetMaturityStarvation(not connectedNow)

        if not self.connected then
            self:TriggerDamage()
        end
    end
end

ReplaceLocals(Cyst.OnUpdate, {ServerUpdate = ServerUpdate})

if Server then
    function Cyst:TriggerDamage()

        if self:GetCystParent() == nil then

            -- Increase damage over time the longer it hasn't been connected if alien "islands" are
            -- being kept alive undesirably long by Crags, Gorges and such
            local damage = kCystUnconnectedDamage * Cyst.kThinkTime
            self:DeductHealth(damage)

        end

    end
end
