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

    if self:GetIsOnGround() and not self.crouching and not self.sprinting and self.walking then
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * 0.5
    end

end

function WalkMixin:HandleButtons(input)

    PROFILE("WalkMixin:HandleButtons")

    local walkDesired = bit.band(input.commands, Move.ReadyRoom) ~= 0
    local current_vm = Client and "Client" or Server and "Server" or Predict and "Predict" or "Unknown"
    print("(" .. current_vm .. ") walkDes:" .. (walkDesired and "yes" or "no"))
    if walkDesired == self.walking then
        return
    end

    if not walkDesired then
        self.walking = walkDesired
        self:UpdateControllerFromEntity()
    elseif self:GetIsOnGround() and not self.crouching and not self.sprinting then
        self.walking = walkDesired
        self:UpdateControllerFromEntity()
    end

end
