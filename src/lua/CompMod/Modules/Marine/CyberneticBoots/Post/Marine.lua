local logger = CompMod:GetModule('logger')

local networkVars = {
    cyberneticBoots = "private boolean"
}

local function GetHasCyberneticBoots(self)
    local team = self:GetTeam()
    if team then
        local techTree = team.GetTechTree and team:GetTechTree() or nil
        if techTree then
            local cyberneticBootsNode = techTree:GetTechNode(kTechId.CyberneticBoots)
            if cyberneticBootsNode and cyberneticBootsNode:GetResearched() then
                return true
            end
        end
    end

    return false
end

function Marine:GetMaxSpeed(possible)
    local runSpeed = Marine.kRunMaxSpeed
    if self.cyberneticBoots then
        runSpeed = runSpeed + kCyberneticBootsAdditionalSpeed
    end

    if possible then
        return runSpeed
    end

    local sprintingScalar = self:GetSprintingScalar()
    local maxSprintSpeed = Marine.kWalkMaxSpeed + ( runSpeed - Marine.kWalkMaxSpeed ) * sprintingScalar
    local maxSpeed = ConditionalValue( self:GetIsSprinting(), maxSprintSpeed, Marine.kWalkMaxSpeed )
    
    -- Take into account our weapon inventory and current weapon. Assumes a vanilla marine has a scalar of around .8.
    local inventorySpeedScalar = self:GetInventorySpeedScalar() + .17    
    local useModifier = 1

    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and self.isUsing and activeWeapon:GetMapName() == Builder.kMapName then
        useModifier = 0.5
    end

    if self:GetHasCatPackBoost() then
        maxSpeed = maxSpeed + kCatPackMoveAddSpeed
    end
    
    return maxSpeed * self:GetSlowSpeedModifier() * inventorySpeedScalar  * useModifier
end

function Marine:ModifyJump(input, velocity, jumpVelocity)
    if self.cyberneticBoots and self.crouching then
        jumpVelocity:Scale(kCyberneticBootsJumpScale)
    end
end

if Server then
    local oldOnProcessMove = Marine.OnProcessMove
    function Marine:OnProcessMove(input)
        oldOnProcessMove(self, input)

        if not GetGamerules():GetGameStarted() then
            if GetHasCyberneticBoots(self) then
                self.cyberneticBoots = true
            else
                self.cyberneticBoots = false
            end
        else
            self.cyberneticBoots = false
        end
    end
end

Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)
