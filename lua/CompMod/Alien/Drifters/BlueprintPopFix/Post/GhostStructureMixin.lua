--[[
At some point GhostStructureMixin was changed to use a trigger body to check for nearby entities. The code to pop the
blueprint when an enemy was close enough was moved to the OnTriggerEntered function. That function is called from the
PhysicsTrigger event handler in Shared.lua:265. This on paper works fine except, for whatever reason, the event only
gets triggered when a *player* intersects with a physics object. This means that drifters and structures, which should
be able to pop blueprints (GhostStructureMixin:92), aren't able to.

Since this event is fired by the engine, I can't investigate/fix the underlying issue. Due to this the code below just
reverts the relevant parts of GhostStructureMixin back to a state that allows drifters to pop blueprints.
]]

local ClearGhostStructure = debug.getupvaluex(GhostStructureMixin.OnTriggerEntered, "ClearGhostStructure", true)
local kGhoststructureMaterial = PrecacheAsset("cinematics/vfx_materials/ghoststructure.material")

GhostStructureMixin.OnInitialized = nil
GhostStructureMixin.OnDestroy = nil
GhostStructureMixin.OnTriggerEntered = nil

if Server then
    local function CheckGhostState(self, doer)

        if self:GetIsGhostStructure() and GetAreFriends(self, doer) then
            self.isGhostStructure = false
        end

    end
    debug.setupvaluex(GhostStructureMixin.OnConstruct, "CheckGhostState", CheckGhostState)
end

local function SharedUpdate(self, deltaTime)
    PROFILE("GhostStructureMixin:OnUpdate")

    if Server and self:GetIsGhostStructure() then

        -- check for enemies in range and destroy the structure, return resources to team
        local enemies = GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin() + Vector(0, 0.3, 0), GhostStructureMixin.kGhostStructureCancelRange)
        table.copy(GetEntitiesForTeamWithinRange("Drifter", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin() + Vector(0, 0.3, 0), GhostStructureMixin.kGhostStructureCancelRange), enemies, true)

        for _, enemy in ipairs (enemies) do

            if enemy:GetIsAlive() then

                ClearGhostStructure(self)
                break

            end

        end

    elseif Client then

        local model
        if HasMixin(self, "Model") then
            model = self:GetRenderModel()
        end

        if model then

            if self:GetIsGhostStructure() then

                self:SetOpacity(0, "ghostStructure")

                if not self.ghostStructureMaterial then
                    self.ghostStructureMaterial = AddMaterial(model, kGhoststructureMaterial)
                end

            else

                self:SetOpacity(1, "ghostStructure")

                if RemoveMaterial(model, self.ghostStructureMaterial) then
                    self.ghostStructureMaterial = nil
                end

            end

        end

    end

end

function GhostStructureMixin:OnUpdate(deltaTime)
    SharedUpdate(self, deltaTime)
end

function GhostStructureMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end