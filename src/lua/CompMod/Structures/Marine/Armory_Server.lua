-- Don't think this is needed...
-- function Armory:OnResearchComplete(researchId)
--     if researchId == kTechId.AdvancedArmoryUpgrade then
--         self:SetTechId(kTechId.AdvancedArmory)

--         -- Remove AdvancedWeaponry Code
--     end
-- end

function Armory:GetShouldResupplyPlayer(player)
    if not player:GetIsAlive() then
        return false
    end
    
    if HasMixin(player, "Stun") and player:GetIsStunned() then
        return false
    end
    
    local inNeed = false
    
    -- Don't resupply when already full
    if (player:GetHealth() < player:GetMaxHealth()) then
        inNeed = true
    elseif(self:GetTechId() == kTechId.AdvancedArmory and player:GetArmor() < player:GetMaxArmor()) then
        inNeed = true
    else
        -- Do any weapons need ammo?
        for i = 1, player:GetNumChildren() do
            local child = player:GetChildAtIndex(i - 1)
            if child:isa("ClipWeapon") and child:GetNeedsAmmo(false) then
                inNeed = true
                break
            end
        end
    end
    
    if inNeed then
        -- Check player facing so players can't fight while getting benefits of armory
        local viewVec = player:GetViewAngles():GetCoords().zAxis
        local toArmoryVec = self:GetOrigin() - player:GetOrigin()
        
        if(GetNormalizedVector(viewVec):DotProduct(GetNormalizedVector(toArmoryVec)) > .75) then
            if self:GetTimeToResupplyPlayer(player) then
                return true 
            end 
        end
    end
    
    return false  
end

function Armory:ResupplyPlayer(player)
    local resuppliedPlayer = false
    
    -- Heal player first
    if (player:GetHealth() < player:GetMaxHealth()) then
        -- third param true = ignore armor
        player:AddHealth(Armory.kHealAmount, false, true)
        resuppliedPlayer = true
    elseif (self:GetTechId() == kTechId.AdvancedArmory and player:GetArmor() < player:GetMaxArmor()) then
        player:AddArmor(Armory.kHealArmorAmount, false)
        resuppliedPlayer = true
    end

    if resuppliedPlayer then
        self:TriggerEffects("armory_health", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})

        if player:isa("Marine") and player.poisoned then
            player.poisoned = false 
        end
    end

    -- Give ammo to all their weapons, one clip at a time, starting from primary
    local weapons = player:GetHUDOrderedWeaponList()
    for _, weapon in ipairs(weapons) do
        if weapon:isa("ClipWeapon") then
            if weapon:GiveAmmo(1, false) then
                self:TriggerEffects("armory_ammo", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
                resuppliedPlayer = true
                break
            end         
        end
    end
        
    if resuppliedPlayer then
        -- Insert/update entry in table
        self.resuppliedPlayers[player:GetId()] = Shared.GetTime()
    end
end
