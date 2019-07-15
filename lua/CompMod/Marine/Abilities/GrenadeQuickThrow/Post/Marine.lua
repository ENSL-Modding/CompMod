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

    quickGrenadeThrowLastFrame = "private boolean"
}

local NO_GRENADE = 0
local CLUSTER_GRENADE = 1
local GAS_GRENADE = 2
local PULSE_GRENADE = 3

local oldOnCreate = Marine.OnCreate
function Marine:OnCreate()
    oldOnCreate(self)

    self.quickGrenadeThrowLastFrame = false
end

local oldHandleAttacks = Marine.HandleAttacks
function Marine:HandleAttacks(input)
    oldHandleAttacks(self, input)

    if not self:GetIsCommander() and not self:GetIsUsing() then
        if not self:GetCanAttack() then
            --[[
            We can use Move.Minimap here since it is only used by commanders and QuickThrow doesn't exist for the commander.

            From testing this doesn't cause any issues when getting in/out of the chair and quick throwing grenades

            For the official implementation (if it goes live) you'd want to find a way to implement this properly.
            The easiest way would be to include the 64bit bitwise lua library, then add Move.QuickThrowGrenade in
            PlayerInputs.lua. Upgrading to the 64 bit libraries would allow for 32 more Move entries, which is needed
            as Move cannot have more entries.

            Alternatively you could use GetIsBinding, but as that's only available client side it would cause issues.
            ]]
            input.commands = bit.band(input.commands, bit.bnot(Move.Minimap))
        end

        if bit.band(input.commands, Move.Minimap) ~= 0 then
            if not self.quickGrenadeThrowLastFrame then
                self:QuickThrowGrenade(input)
            end

            self.quickGrenadeThrowLastFrame = true
        else
            self.quickGrenadeThrowLastFrame = false
        end
    end
end

local function GetGrenadeType(grenade)
    if grenade:isa("ClusterGrenadeThrower") then return CLUSTER_GRENADE end
    if grenade:isa("GasGrenadeThrower") then return GAS_GRENADE end
    if grenade:isa("PulseGrenadeThrower") then return PULSE_GRENADE end

    return NO_GRENADE
end

local function FindGrenadeType(inventory)
    for _,v in ipairs(inventory) do
        local type = GetGrenadeType(v)

        if type ~= NO_GRENADE then
            return type
        end
    end

    return NO_GRENADE
end

function Marine:QuickThrowGrenade()
    local weapons = self.GetWeapons and self:GetWeapons() or 0
    local grenadeType = weapons and FindGrenadeType(weapons)
    local validMarine = (self:isa("Marine") or self:isa("JetpackMarine"))
    local throwValid = grenadeType and grenadeType ~= NO_GRENADE and validMarine

    if throwValid then
        for _,weapon in ipairs(weapons) do
            if weapon and GetGrenadeType(weapon) ~= NO_GRENADE then

                weapon:OnPrimaryAttack(self)
                self:OnPrimaryAttack()

                weapon:OnTag("throw")
                weapon:OnTag("attack_end")

                break
            end
        end
    end
end

Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)
