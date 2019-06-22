function Fade:GetCanJump()
    return self:GetIsOnGround() and not self:GetIsBlinking()
end