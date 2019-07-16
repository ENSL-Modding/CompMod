local kMaxSpeedPercentage = 0.90
local kSkulkModelPercentage = 0.90

Skulk.kXExtents = Skulk.kXExtents * kSkulkModelPercentage
Skulk.kYExtents = Skulk.kYExtents * kSkulkModelPercentage
Skulk.kZExtents = Skulk.kZExtents * kSkulkModelPercentage

local oldGetMaxSpeed = Skulk.GetMaxSpeed
function Skulk:GetMaxSpeed(possible)
    return oldGetMaxSpeed(self, possible) * kMaxSpeedPercentage
end

local oldGetMaxWallJumpSpeed = Skulk.GetMaxWallJumpSpeed
function Skulk:GetMaxWallJumpSpeed()
    return oldGetMaxWallJumpSpeed(self) * kMaxSpeedPercentage
end

local oldGetMaxBunnyHopSpeed = Skulk.GetMaxBunnyHopSpeed
function Skulk:GetMaxBunnyHopSpeed()
    return oldGetMaxBunnyHopSpeed(self) * kMaxSpeedPercentage
end

local oldModelCoords = Skulk.OnAdjustModelCoords
function Skulk:OnAdjustModelCoords(modelCoords)
    modelCoords = oldModelCoords(self, modelCoords)

    modelCoords.xAxis = modelCoords.xAxis * kSkulkModelPercentage
    modelCoords.yAxis = modelCoords.yAxis * kSkulkModelPercentage
    modelCoords.zAxis = modelCoords.zAxis * kSkulkModelPercentage

    return modelCoords
end
