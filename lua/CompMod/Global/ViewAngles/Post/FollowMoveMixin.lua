local function ChangeTarget(self, reverse)

    local targets = self:GetTargetsToFollow()
    local numberOfTargets = table.icount(targets)
    local currentTargetIndex = table.find(targets, Shared.GetEntity(self.followedTargetId))
    local nextTargetIndex = currentTargetIndex

    if nextTargetIndex and reverse then
        nextTargetIndex = ((nextTargetIndex - 2) % numberOfTargets) + 1
    elseif nextTargetIndex then
        nextTargetIndex = (nextTargetIndex % numberOfTargets) + 1
    else
        nextTargetIndex = 1
    end

    if nextTargetIndex <= numberOfTargets then

        local cameraDistance = 5

        if self.GetFollowMoveCameraDistance then
            cameraDistance = self:GetFollowMoveCameraDistance()
        end

        self.followedTargetId = targets[nextTargetIndex]:GetId()
        self:SetDesiredCamera(0.0, { move = true}, targets[nextTargetIndex]:GetOrigin(), nil, cameraDistance)

    end

end

local function UpdateTarget(self, input)

    assert(Server)

    if self.imposedTargetId ~= Entity.invalidId then

        if self:GetIsValidTarget(Shared.GetEntity(self.imposedTargetId)) then
            return
        else
            self.imposedTargetId = Entity.invalidId
        end

    end

    local primaryAttack = bit.band(input.commands, Move.PrimaryAttack) ~= 0
    local secondaryAttack = bit.band(input.commands, Move.SecondaryAttack) ~= 0
    local isTargetValid = self:GetIsValidTarget(Shared.GetEntity(self.followedTargetId))
    local changeTargetAction = primaryAttack or secondaryAttack

    -- Require another click to change target.
    local changeTarget = (not self.changeTargetAction and changeTargetAction) or not isTargetValid
    self.changeTargetAction = changeTargetAction

    if changeTarget and secondaryAttack then
        ChangeTarget(self, true)
    elseif changeTarget then
        ChangeTarget(self, false)
    end

end

local function UpdateView(self, input)

    local viewAngles = Angles(input.pitch, input.yaw, 0)
    local targetId = self.imposedTargetId ~= Entity.invalidId and self.imposedTargetId or self.followedTargetId
    local targetEntity = Shared.GetEntity(targetId)
    local isTargetValid = self:GetIsValidTarget(targetEntity)

    if isTargetValid then
        self:SetOrigin(targetEntity:GetOrigin())
    end

    self:SetViewAngles(viewAngles)

end

function FollowMoveMixin:UpdateMove(input)

    if not self.followMoveEnabled then
        return
    end

    if Server then
        UpdateTarget(self, input)
    end
    UpdateView(self, input)

end