AdrenalineRushMixin = CreateMixin(AdrenalineRushMixin)
AdrenalineRushMixin.type = "AdrenalineRush"

AdrenalineRushMixin.expectedMixins =
{
}

local kMaxAdrenalineRushLevel = 1
AdrenalineRushMixin.networkVars =
{
    adrenalineRushLevel = "private integer (0 to " .. kMaxAdrenalineRushLevel .. ")"
}

function AdrenalineRushMixin:__initmixin()
    
    PROFILE("AdrenalineRushMixin:__initmixin")
    
    self.adrenalineRushLevel = 0

    if Server then
        self.adrenalineRushGivers = unique_set()
        self.adrenalineRushGiverTime = {}
    end    
end

function AdrenalineRushMixin:GetAdrenalineRushLevel()
    return self.adrenalineRushLevel
end

if Server then
    local function UpdateAdrenalineRushState(self)
        PROFILE("AdrenalineRushMixin:UpdateState")

        local adrenalineRushAllowed = not self.GetIsAdrenalineRushAllowed or self:GetIsAdrenalineRushAllowed()
        local now = Shared.GetTime()
        
        for _, giverId in ipairs(self.adrenalineRushGivers:GetList()) do
            if not adrenalineRushAllowed or self.adrenalineRushGiverTime[giverId] + 1 < now then
                self.adrenalineRushGiverTime[giverId] = nil
                self.adrenalineRushGivers:Remove(giverId)
            end
        end

        self.adrenalineRushLevel = Clamp(self.adrenalineRushGivers:GetCount(), 0, kMaxAdrenalineRushLevel)
        local isAdrenalineRushed = self.adrenalineRushLevel > 0
        -- self:SetGameEffectMask(kGameEffect.Energize, energized)

        if isAdrenalineRushed then
            -- local energy = ConditionalValue(self:isa("Player"), kPlayerEnergyPerEnergize, kStructureEnergyPerEnergize)
            -- energy = energy * self.energizeLevel
            -- self:AddEnergy(energy)
            
        end

        return isAdrenalineRushed
    end

    function AdrenalineRushMixin:Energize(giver)
    
        local energizeAllowed = not self.GetIsEnergizeAllowed or self:GetIsEnergizeAllowed()
        
        if energizeAllowed then
        
            self.energizeGivers:Insert(giver:GetId())
            self.energizeGiverTime[giver:GetId()] = Shared.GetTime()

            if self:GetEnergizeLevel() == 0 then
                UpdateEnergizedState(self) -- energize
                self:AddTimedCallback(UpdateEnergizedState, kEnergizeUpdateRate)
            end
        
        end
    
    end

    function EnergizeMixin:CopyPlayerDataFrom(player)

        if HasMixin(player, "Energize") and player:GetEnergizeLevel() > 0 then
            self:AddTimedCallback(UpdateEnergizedState, kEnergizeUpdateRate)
        end

    end

end