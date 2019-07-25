-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\ConsumeMixin.lua
--
--    Created by:   Joseph Hutchins
--
--    Allows recycling for aliens (called consume) of structures. Use server side only.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

ConsumeMixin = CreateMixin(ConsumeMixin)
ConsumeMixin.type = "Consume"

local kConsumeEffectDuration = 2

ConsumeMixin.expectedCallback =
{
}

ConsumeMixin.optionalCallbacks =
{
    GetCanConsumeOverride = "Return custom restrictions for consuming."
}

ConsumeMixin.expectedMixins =
{
    Research = "Required for consume progress / cancellation."
}

ConsumeMixin.networkVars =
{
    consumed = "boolean"
}

function ConsumeMixin:__initmixin()
    self.consumed = false
end

function ConsumeMixin:GetConsumeActive()
    return self.researchingId == kTechId.Consume
end

function ConsumeMixin:OnConsumed()
end

function ConsumeMixin:GetCanConsume()

    local canConsume = true
    
    if self.GetCanConsumeOverride then
        canConsume = self:GetCanConsumeOverride()
    end

    return canConsume and not self:GetConsumeActive()

end

function ConsumeMixin:OnResearchComplete(researchId)

    if researchId == kTechId.Consume then
        
        -- Do not display new killfeed messages during concede sequence
        if GetConcedeSequenceActive() then
            return
        end

        -- TODO need effects?
        --self:TriggerEffects("recycle_end")
        Server.SendNetworkMessage( "Consume", { techId = self:GetTechId() }, true )
        
        local team = self:GetTeam()

        -- TODO(jhutchins): Specific messaging for consume
        local deathMessageTable = team:GetDeathMessage(team:GetCommander(), kDeathMessageIcon.Recycled, self)
        local func = Closure [=[
            self deathMessageTable
            args player
            Server.SendNetworkMessage(player:GetClient(), "DeathMessage", deathMessageTable, true)
        ]=]{deathMessageTable}
        team:ForEachPlayer(func)
        
        self.consumed = true
        self.timeConsumed = Shared.GetTime()

        --self:OnKill()
        self:OnConsumed()
        
    end

end

function ConsumeMixin:GetIsConsumed()
    return self.consumed
end

function ConsumeMixin:GetIsConsuming()
    return self.researchingId == kTechId.Consume
end

function ConsumeMixin:OnResearch(researchId)

    if researchId == kTechId.Consume then
        -- TODO need effects?
        --self:TriggerEffects("recycle_start")

        if self.OnConsumeTriggered then
            self:OnConsumeTriggered()
        end

        if self.MarkBlipDirty then
            self:MarkBlipDirty()
        end
    end
    
end

function ConsumeMixin:OnResearchCancel(researchId)
    if researchId == kTechId.Consume then
        if self.OnConsumeCancelled then
            self:OnConsumeCancelled()
        end

        if self.MarkBlipDirty then
            self:MarkBlipDirty()
        end
    end
    
end

function ConsumeMixin:OnUpdateRender()

    PROFILE("ConsumeMixin:OnUpdateRender")

    if self.consumed ~= self.clientConsumed then
    
        self.clientConsumed = self.consumed
        self:SetOpacity(1, "consumeAmount")
        
        if self.consumed then
            self.clientTimeConsumeStarted = Shared.GetTime()
        else
            self.clientTimeConsumeStarted = nil
        end
    
    end
    
    if self.clientTimeConsumeStarted then
    
        local consumeAmount = 1 - Clamp((Shared.GetTime() - self.clientTimeConsumeStarted) / kConsumeEffectDuration, 0, 1)
        self:SetOpacity(consumeAmount, "consumeAmount")
    
    end

end

function ConsumeMixin:OnUpdateAnimationInput(modelMixin)

    PROFILE("ConsumeMixin:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("consuming", self:GetConsumeActive())
    
end

local function SharedUpdate(self, deltaTime)

    if Server then
    
        if self.timeConsumed then
        
            if self.timeConsumed + kConsumeEffectDuration + 1 < Shared.GetTime() then
                DestroyEntity(self)
            end
        
        elseif self.researchingId == kTechId.Consume then
            self:UpdateResearch(deltaTime)
        end
        

    end
    
end

function ConsumeMixin:OnUpdate(deltaTime)
    SharedUpdate(self, deltaTime)
end

function ConsumeMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end