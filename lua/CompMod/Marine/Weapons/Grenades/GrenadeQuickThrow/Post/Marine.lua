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

function Marine:EndQuickThrowGrenade(input)
    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and activeWeapon:isa("GrenadeThrower") then
        self:PrimaryAttackEnd()
        --activeWeapon:SetThrowASAP()
    end
end
