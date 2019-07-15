Lerk.roostInterval = 1 -- roost interval in seconds
Lerk.roostHealRate = 5 --hp healed / second while roosting

local networkVars =
{
    gliding = "private compensated boolean",
    glideAllowed = "private compensated boolean",
    lastTimeFlapped = "compensated time",
    -- Wall grip. time == 0 no grip, > 0 when grip started.
    wallGripTime = "private compensated time",
    -- the normal that the model will use. Calculated the same way as the skulk
    wallGripNormalGoal = "private compensated vector",
    wallGripAllowed = "private compensated boolean",
    flapPressed = "private compensated boolean",
    timeOfLastPhase = "private time",
    flySoundId = "entityid",

    lastTimeRoost = "compensated time"
}

local oldOnCreate = Lerk.OnCreate
function Lerk:OnCreate()
    oldOnCreate(self)

    if Server then
        self.lastTimeRoost = 0
    end
end

function Lerk:OnProcessMove(input)
    Alien.OnProcessMove(self, input)

    self:UpdateRoostHeal()
end

function Lerk:UpdateRoostHeal()
    if not self:GetIsDestroyed() then
        local roostAllowed = Shared.GetTime() > self.lastTimeRoost + self.roostInterval

        if self:GetIsWallGripping() and GetHasTech(self, kTechId.Roost, true) and roostAllowed then
            self:AddHealth(self.roostHealRate, false, false)
            self.lastTimeRoost = Shared.GetTime()
        end
    end
end

Shared.LinkClassToMap("Lerk", Lerk.kMapName, networkVars, true)
