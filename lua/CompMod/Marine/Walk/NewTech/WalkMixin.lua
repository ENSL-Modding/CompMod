WalkMixin = CreateMixin(WalkMixin)
WalkMixin.type = "Walk"

WalkMixin.networkVars =
{
  walking = "compensated boolean"
}

function WalkMixin:__initmixin()

    PROFILE("WalkMixin:__initmixin")

    self.walking = false

end

function WalkMixin:GetWalking()
    return self.walking
end

function WalkMixin:ModifyMaxSpeed(maxSpeedTable)

    if self:CanWalk() and self:GetWalking() then
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * 0.5
    end

end

function WalkMixin:CanWalk()
  return self:GetIsOnGround() and not self.crouching and not self.sprinting
end

function WalkMixin:HandleButtons(input)

    PROFILE("WalkMixin:HandleButtons")

    local walkDesired = bit.band(input.commands, Move.Walk) ~= 0 and not self.crouching and self:GetIsOnGround() and not self.sprinting
    if walkDesired == self.walking then
        return
    end

    if not walkDesired then
        self.walking = walkDesired
        self:UpdateControllerFromEntity()
    elseif self:CanWalk() then
        self.walking = walkDesired
        self:UpdateControllerFromEntity()
    end

end
