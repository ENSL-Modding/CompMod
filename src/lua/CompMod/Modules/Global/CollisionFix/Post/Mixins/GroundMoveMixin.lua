-- local logger = CompMod:GetModule('logger')
local DoStepMove = debug.getupvaluex(GroundMoveMixin.UpdatePosition, "DoStepMove")
local kStepHeight = debug.getupvaluex(DoStepMove, "kStepHeight")
local kDownSlopeFactor = debug.getupvaluex(DoStepMove, "kDownSlopeFactor")
local GetIsCloseToGround = debug.getupvaluex(DoStepMove, "GetIsCloseToGround")

local function CheckForInvalidEntityStep(self, hitEntities)
    if hitEntities then
        for i = 1, #hitEntities do
            if not self:GetCanStepOver(hitEntities[i]) then
                return hitEntities[i]
            end
        end
    end

    return nil
end

local function AbortDoStepMove(self, oldOrigin, oldVelocity, velocity, deltaTime, slowDownFraction, deflectMove)
    self:SetOrigin(oldOrigin)
    VectorCopy(oldVelocity, velocity)
    self:PerformMovement(velocity * deltaTime, 3, velocity, true, slowDownFraction, deflectMove)
end

-- Fix teleporting on top of players
-- Check for entities in both the step up and step down traces, abort if we're stepping on top of entities we shouldn't be
local function DoStepMove(self, _, velocity, deltaTime)

    PROFILE("GroundMoveMixin:DoStepMove")
    
    local oldOrigin = Vector(self:GetOrigin())
    local oldVelocity = Vector(velocity)
    local success = false
    local stepAmount = 0
    local slowDownFraction = self.GetCollisionSlowdownFraction and self:GetCollisionSlowdownFraction() or 1
    local deflectMove = self.GetDeflectMove and self:GetDeflectMove() or false
    
    -- step up at first
    local ent
    local _, hitEntities = self:PerformMovement(Vector(0, kStepHeight, 0), 1)
    ent = CheckForInvalidEntityStep(self, hitEntities)
    if ent then
        -- logger:PrintWarn("StepUp: %s attemped to step over %s", SafeClassName(self), SafeClassName(ent))
        AbortDoStepMove(self, oldOrigin, oldVelocity, velocity, deltaTime, slowDownFraction, deflectMove)
        return false
    end

    stepAmount = self:GetOrigin().y - oldOrigin.y
    -- do the normal move
    local startOrigin = Vector(self:GetOrigin())
    local completedMove = self:PerformMovement(velocity * deltaTime, 3, velocity, true, slowDownFraction, deflectMove)
    local horizMoveAmount = (startOrigin - self:GetOrigin()):GetLengthXZ()
    
    if completedMove then
        -- step down again
        local _, hitEntities, averageSurfaceNormal = self:PerformMovement(Vector(0, -stepAmount - horizMoveAmount * kDownSlopeFactor, 0), 1)
        ent = CheckForInvalidEntityStep(self, hitEntities)
        if ent then
            -- logger:PrintWarn("StepDown: %s attemped to step over %s", SafeClassName(self), SafeClassName(ent))
            AbortDoStepMove(self, oldOrigin, oldVelocity, velocity, deltaTime, slowDownFraction, deflectMove)
            return false
        end
        
        if averageSurfaceNormal and averageSurfaceNormal.y >= 0.5 then
            success = true
        else    
        
            local onGround = GetIsCloseToGround(self, 0.15)
            
            if onGround then
                success = true
            end
            
        end
        
    end
    
    -- not succesful. fall back to normal move
    if not success then
        AbortDoStepMove(self, oldOrigin, oldVelocity, velocity, deltaTime, slowDownFraction, deflectMove)
    end

    return success

end

debug.setupvaluex(GroundMoveMixin.UpdatePosition, "DoStepMove", DoStepMove)
