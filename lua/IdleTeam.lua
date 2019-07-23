Script.Load("lua/Team.lua")
Script.Load("lua/TeamDeathMessageMixin.lua")

class 'IdleTeam' (Team)

function IdleTeam:Initialize(teamName, teamNumber)
    Team.Initialize(self, teamName, teamNumber)

    self:OnCreate()
end

function IdleTeam:Uninitialize()
    Team.Uninitialize(self)
end

function IdleTeam:OnInitialized()
    Team.OnInitialized(self)

    InitMixin(self, TeamDeathMessageMixin)
end

function IdleTeam:Reset()
    self:OnInitialized()

    Team.Reset(self)
end