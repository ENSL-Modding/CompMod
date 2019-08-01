-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\InfestationTrackerMixin.lua
--
-- Created by: Mats Olsson (mats.olsson@matsotech.se)
--
-- Tracks infested state for entities.
-- Cooperates with the Infestation to update the infestation state of entities.
-- Listens for changes in location for self, adding itself to the dirty table, which
-- is cleaned out regularly.
-- In addition, an infestation that changes its radius will also cause all entities in the
-- changed radius to be marked as dirty
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

InfestationTrackerMixin = CreateMixin( InfestationTrackerMixin )
InfestationTrackerMixin.type = "InfestationTracker"

-- Listen on the state that infested state depends on - ie where we are
InfestationTrackerMixin.expectedCallbacks = {
    SetOrigin = "Sets the location of an entity",
    SetCoords = "Sets both both location and angles",
}

InfestationTrackerMixin.expectedMixins =
{
    GameEffects = "Required for on infestation state."
}

-- What entities have become dirty.
-- Flushed in the UpdateServer hook by InfestationTrackerMixin.OnUpdateServer
InfestationTrackerMixin.dirtyTable = {}

-- Call all dirty entities
function InfestationTrackerMixin.OnUpdateServer()

    PROFILE("InfestationTrackerMixin:OnUpdateServer")
    for _, entityId in ipairs(InfestationTrackerMixin.dirtyTable) do

        local entity = Shared.GetEntity(entityId)
        if entity then

            if not entity.UpdateInfestedState then
                Print("waning: %s has no implementation of UpdateInfestedState()", entity:GetClassName())
            else
                entity:UpdateInfestedState()
            end

        end

    end

    InfestationTrackerMixin.dirtyTable = {}

end

-- Intercept the functions that changes the state the mapblip depends on
function InfestationTrackerMixin:SetOrigin(_)
    local entId = self:GetId()
    table.insert(InfestationTrackerMixin.dirtyTable, entId)
end
function InfestationTrackerMixin:SetCoords(_)
    local entId = self:GetId()
    table.insert(InfestationTrackerMixin.dirtyTable, entId)
end

function InfestationTrackerMixin:__initmixin()
    PROFILE("InfestationTrackerMixin:__initmixin")
    assert(Server)

end

function InfestationTrackerMixin:UpdateInfestedState(onInfestation)
    if self.infestedUpdateTime == Shared.GetTime() then return end

    self.infestedUpdateTime = Shared.GetTime()

    -- no need to check here, since we already know that this place is infested
    if onInfestation then
        self:SetInfestationState(true)
    else
        UpdateInfestationMask(self)
    end

end

function InfestationTrackerMixin:SetInfestationState(onInfestation)

    if self:GetGameEffectMask(kGameEffect.OnInfestation) ~= onInfestation then

        self:SetGameEffectMask(kGameEffect.OnInfestation, onInfestation)

        if onInfestation and self.OnTouchInfestation then
            self:OnTouchInfestation()
        end

        if not onInfestation and self.OnLeaveInfestation then
            self:OnLeaveInfestation()
        end

    end

end

function InfestationTrackerMixin:InfestationNeedsUpdate()
    local entId = self:GetId()
    table.insert(InfestationTrackerMixin.dirtyTable, entId)
end

Event.Hook("UpdateServer", InfestationTrackerMixin.OnUpdateServer)