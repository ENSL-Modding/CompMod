--[[
Main implementation for Grenade Quick Throw.

We can use Move.Minimap here since it is only used by commanders and QuickThrow doesn't exist for the commander.

From testing this doesn't cause any issues when getting in/out of the chair and quick throwing grenades

For the official implementation (if it goes live) you'd want to find a way to implement this properly.
The easiest way would be to include the 64bit bitwise lua library, then add Move.QuickThrowGrenade in
PlayerInputs.lua. Upgrading to the 64 bit libraries would allow for 32 more Move entries, which is needed
as Move cannot have more entries.

Alternatively you could use GetIsBinding, but as that's only available client side it would cause issues.
]]

local networkVars =
{
    flashlightOn = "boolean",

    timeOfLastDrop = "private time",
    timeOfLastPickUpWeapon = "private time",

    flashlightLastFrame = "private boolean",

    timeLastSpitHit = "private time",
    lastSpitDirection = "private vector",

    ruptured = "boolean",
    interruptAim = "private boolean",
    poisoned = "boolean",
    weaponUpgradeLevel = "integer (0 to 3)",

    unitStatusPercentage = "private integer (0 to 100)",

    strafeJumped = "private compensated boolean",

    timeLastBeacon = "private time",

    weaponBeforeUseId = "private compensated entityid",

    -- quick throw vars
    quickGrenadeThrowLastFrame = "private boolean",
    quickGrenadeLastWeaponSlot = "private integer (0 to 10)"
}

local oldOnCreate = Marine.OnCreate
function Marine:OnCreate()
    oldOnCreate(self)

    self.quickGrenadeThrowLastFrame = false
    self.quickGrenadeLastWeaponSlot = 1
end

local oldHandleAttacks = Marine.HandleAttacks
function Marine:HandleAttacks(input)
    oldHandleAttacks(self, input)

    if not self:GetIsCommander() and not self:GetIsUsing() then
        if not self:GetCanAttack() then
            input.commands = bit.band(input.commands, bit.bnot(Move.Minimap))
        end

        if bit.band(input.commands, Move.Minimap) ~= 0 then
            if not self.quickGrenadeThrowLastFrame then
                self:QuickThrowGrenade()

                self.quickGrenadeThrowLastFrame = true
            end
        else
            if self.quickGrenadeThrowLastFrame then
                self:PrimaryAttackEnd()
            end
            self.quickGrenadeThrowLastFrame = false
        end
    end
end

function Marine:QuickThrowGrenade()
    local weapons = self.GetWeapons and self:GetWeapons() or 0
    local validMarine = (self:isa("Marine") or self:isa("JetpackMarine"))
    local throwValid = weapons and validMarine

    if throwValid then
        for _,weapon in ipairs(weapons) do
            if weapon and weapon:isa("GrenadeThrower") then
                weapon:SetIsQuickThrown(true)

                -- if we already have the grenade out, we need to use the quickthrow animation graph.
                if weapon:GetMapName() == self:GetActiveWeapon():GetMapName() then
                    weapon:OnDraw(self)
                end

                if self:SetActiveWeapon(weapon:GetMapName()) then
                    self:PrimaryAttack()
                end

                weapon:SetIsQuickThrown(false)

                break
            end
        end
    end
end

Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)
