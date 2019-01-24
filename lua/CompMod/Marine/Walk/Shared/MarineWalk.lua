kMarineMaxSlowWalkSpeed = 2.5

local oldMarineInit = Marine.OnInitialized
function Marine:OnInitialized()
  oldMarineInit(self)
  InitMixin(self, WalkMixin)
end

-- local oldSprintUpdate = SprintMixin.UpdateSprintingState
-- function SprintMixin:UpdateSprintingState(input)
--   oldSprintUpdate(self, input)
--   self:UpdateWalkMode(input)
-- end

-- function Marine:GetMaxSpeed(possible)
--
--     if possible then
--         return Marine.kRunMaxSpeed
--     end
--
--     local sprintingScalar = self:GetSprintingScalar()
--     local maxSprintSpeed = Marine.kWalkMaxSpeed + ( Marine.kRunMaxSpeed - Marine.kWalkMaxSpeed ) * sprintingScalar
--     local maxSpeed = ConditionalValue( self:GetIsSprinting(), maxSprintSpeed, Marine.kWalkMaxSpeed )
--     maxSpeed = ConditionalValue(self:GetIsWalking(), kMarineMaxSlowWalkSpeed, maxSpeed)
--
--     -- Take into account our weapon inventory and current weapon. Assumes a vanilla marine has a scalar of around .8.
--     local inventorySpeedScalar = self:GetInventorySpeedScalar() + .17
--     local useModifier = 1
--
--     local activeWeapon = self:GetActiveWeapon()
--     if activeWeapon and self.isUsing and activeWeapon:GetMapName() == Builder.kMapName then
--         useModifier = 0.5
--     end
--
--     if self.catpackboost then
--         maxSpeed = maxSpeed + kCatPackMoveAddSpeed
--     end
--
--     return maxSpeed * self:GetSlowSpeedModifier() * inventorySpeedScalar  * useModifier
--
-- end

local networkVars = { }

AddMixinNetworkVars(WalkMixin, networkVars)

Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)
