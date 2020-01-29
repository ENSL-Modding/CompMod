function Cyst:OnKill()

    self:TriggerEffects("death")

    -- apparently we don't need this
    --self.connected = false

    self:SetModel(nil)

    for _, id in ipairs(self.children) do

        local cyst = Shared.GetEntity(id)
        if cyst then
            cyst.parentId = Entity.invalidId
            cyst.connected = false
        end

    end

end

local kDetectRange = 10

CompMod:ReplaceLocal(Cyst.ScanForNearbyEnemy, "kDetectRange", kDetectRange)