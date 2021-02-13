function Fade:GetTierThreeTechId()
    return kTechId.AdvancedSwipe
end

local function ResetMetabolize(self)
    if self.previousweapon ~= nil and self:GetActiveWeapon():GetMapName() == Metabolize.kMapName then
        self:SetActiveWeapon(self.previousweapon)
        self.previousweapon = nil

        -- Clear metabolize cooldown
        self.timeMetabolize = Shared.GetTime() - Fade.kMetabolizeAnimationDelay
    end
end

function Fade:OnCommanderStructureLogin(_)
    ResetMetabolize(self)
end

function Fade:OnCommanderStructureLogout(_)
    ResetMetabolize(self)
end
