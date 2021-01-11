Alien.kScavengerMaxHealLookup = {
    ["Skulk"] = 0.4,
    ["Gorge"] = 0.3125,
    ["Lerk"] = 0.33333,
    ["Fade"] = 0.48,
    ["Onos"] = 0.4286,
}

function Alien:GetScavengerMaxScalar()
    return self:GetMaxHealth() * Alien.kScavengerMaxHealLookup[self:GetClassName()]
end

function Alien:ApplyScavengerHeal(healScalar)
    if not GetHasScavengerUpgrade(self) then
        return
    end

    local scavengerHealEntry = {}
    scavengerHealEntry.timesHealed = 0
    scavengerHealEntry.healAmount = (self:GetScavengerMaxScalar() * healScalar * (self:GetShellLevel() / 3)) / kScavengerHealCount
    table.insert(self.scavengerHealData, scavengerHealEntry)

    -- Set the next time if it's not been set
    if self.scavengerNextHealTime == 0 then
        self.scavengerNextHealTime = Shared.GetTime() + (kScavengerDuration / kScavengerHealCount)
    end
end

local oldOnProcessMove = Alien.OnProcessMove
function Alien:OnProcessMove(input)
    oldOnProcessMove(self, input)

    if not self:GetIsDestroyed() then
        -- Time to heal
        if self.scavengerNextHealTime > 0 and self.scavengerNextHealTime < Shared.GetTime() then
            if not GetHasScavengerUpgrade(self) then
                self.scavengerNextHealTime = 0
                self.scavengerHealData = {}
            else
                local fullHeal = 0
                local toRemove = {}
                for i, entry in ipairs(self.scavengerHealData) do
                    fullHeal = fullHeal + entry.healAmount
                    entry.timesHealed = entry.timesHealed + 1
                    if entry.timesHealed >= kScavengerHealCount then
                        table.insert(toRemove, i)
                    end
                end

                -- Remove expired entries
                local offset = 0
                for _, idx in ipairs(toRemove) do
                    table.remove(self.scavengerHealData, idx - offset)
                    offset = offset + 1
                end

                -- Ensure we don't heal over our maximum
                fullHeal = math.min(self:GetScavengerMaxScalar(), fullHeal)
                self:AddHealth(fullHeal, false, false, false, self, true)

                if #self.scavengerHealData == 0 then
                    self.scavengerNextHealTime = 0
                else
                    self.scavengerNextHealTime = Shared.GetTime() + (kScavengerDuration / kScavengerHealCount)
                end
            end
        end
    end
end
