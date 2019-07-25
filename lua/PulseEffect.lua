-- ======= Copyright (c) 2016, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\PulseEffect.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Used to highlight an entity with a pulsing effect.  Used in the tutorials.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/EntityChangeMixin.lua")

PrecacheAsset("cinematics/vfx_materials/PulseGlow.surface_shader")
kPulseHighlightMaterial = PrecacheAsset("cinematics/vfx_materials/PulseGlow.material")

class 'PulseEffect' (Entity)

PulseEffect.kMapName = 'pulseeffect'

local networkVars = 
{
    entityId    =   'entityid',
    frequency   =   'float',
    active      =   'boolean',
    colorR      =   'integer (0 to 255)',
    colorG      =   'integer (0 to 255)',
    colorB      =   'integer (0 to 255)',
    colorA      =   'integer (0 to 255)',
}

AddMixinNetworkVars(EntityChangeMixin, networkVars)

function PulseEffect:OnCreate()
    
    Entity.OnCreate(self)
    
    InitMixin(self, EntityChangeMixin)
    self.entityId   = Entity.invalidId
    self.forever    = false
    self.duration   = 0
    self.frequency  = 1
    self.active     = false
    self.colorR     = 255
    self.colorG     = 255
    self.colorB     = 255
    self.colorA     = 55
    self:SetUpdates(true, kDefaultUpdateRate)
    
end

function PulseEffect:OnInitialized()
    
    Entity.OnInitialized(self)
    
end

function PulseEffect:OnDestroy()
    if Client then
        
        if self.mat then
            local ent = Shared.GetEntity(self.entityId)
            if ent and ent.GetRenderModel then
                local model = ent:GetRenderModel()
                if model then
                    model:RemoveMaterial(self.mat)
                end
            end
            
            Client.DestroyRenderMaterial(self.mat)
        end
    end
end

function PulseEffect:OnEntityChange(oldId, newId)
    if oldId and self.entityId and oldId == self.entityId then -- ensure we give a crap about the entity being changed
        DestroyEntity(self)
    end
end

local function ColorToValues(color)
    return  math.max(math.min(color.r,1),0)*255,
            math.max(math.min(color.g,1),0)*255,
            math.max(math.min(color.b,1),0)*255,
            math.max(math.min(color.a,1),0)*255
end

local function ValuesToColor(r,g,b,a)
    local a = a or 1.0
    return Color(
                math.max(math.min(r,255),0)/255,
                math.max(math.min(g,255),0)/255,
                math.max(math.min(b,255),0)/255,
                math.max(math.min(a,255),0)/255)
end

local function ColorToVector(color)
    return Vector(color.r, color.g, color.b)
end

if Client then
    
    function PulseEffect:OnUpdate(deltaTime)
        if self.active == true and not self.wasActive then
            now = Shared.GetTime()
            self.startTime = now
            self.wasActive = true
            self.mat = Client.CreateRenderMaterial()
            self.mat:SetMaterial(kPulseHighlightMaterial)
            self.mat:SetParameter('frequency', self.frequency)
            self.mat:SetParameter('startTime', now)
            self.mat:SetParameter('glowColor', ColorToVector(ValuesToColor(self.colorR,
                self.colorG, self.colorB, self.colorA)))
            Shared.GetEntity(self.entityId):GetRenderModel():AddMaterial(self.mat)
        end
    end
    
    function CreatePulseEffect(entity, duration, color, frequency)
        local entityId = entity:GetId()
        local duration = duration or -1.0
        local colorR, colorG, colorB, colorA = 1.0, 1.0, 1.0, 1.0
        if color then
            colorR, colorG, colorB, colorA = ColorToValues(color)
        end
        local frequency = frequency or 1.0
        Client.SendNetworkMessage("CreatePulseEffect", {
            entityId    =   entityId,
            duration    =   duration,
            colorR      =   colorR,
            colorG      =   colorG,
            colorB      =   colorB,
            colorA      =   colorA,
            frequency   =   frequency}, true)
    end
    
end

if Server then

    function PulseEffect:SetEntity(entity)
        self:SetEntityId(entity:GetId())
    end

    function PulseEffect:SetEntityId(entityId)
        self.entityId = entityId
    end

    function PulseEffect:SetDuration(duration) --nil = forever
        if not duration then
            self.forever = true
            self.duration = nil
        else
            self.forever = false
            self.duration = duration
        end
    end

    function PulseEffect:SetFrequency(freq)
        if not freq then
            self.frequency = 1
        else
            self.frequency = freq
        end
    end
    
    function PulseEffect:SetColor(color)
        self.colorR, self.colorG, self.colorB, self.colorA = ColorToValues(color)
    end

    local function Deactivate(self, timePassed)
        DestroyEntity(self)
    end

    function PulseEffect:Activate()
        if self.entityId == Entity.invalidId then
            return
        end
        
        self.active = true
        
        local now = Shared.GetTime()
        
        if self.duration then
            self.endTime = now + self.duration
        else
            self.endTime = nil
        end
        
    end
    
    function PulseEffect:OnUpdate(delta)
        
        if self.endTime then
            local now = Shared.GetTime()
            if now >= self.endTime then
                DestroyEntity(self)
            end
        end
    end
    
    function CreatePulseEffect(entity, duration, color, frequency)
        if not entity then
            Log("No entity provided for CreatePulseEffect")
            return
        end
        
        newPulse = CreateEntity(PulseEffect.kMapName)
        newPulse:SetEntity(entity)
        newPulse:SetDuration(duration) -- if nil, it goes forever -- the function detects this
        if color then newPulse:SetColor(color) end
        if frequency then newPulse:SetFrequency(frequency) end
        newPulse:Activate()
        
        return newPulse
        
    end
    
    function OnCreatePulseEffect(client, message)
        local entity = Shared.GetEntity(message.entityId)
        local duration = message.duration
        if duration < 0 then
            duration = nil
        end
        local color = ValuesToColor(message.colorR, message.colorG, message.colorB, message.colorA )
        local frequency = message.frequency
        CreatePulseEffect(entity, duration, color, frequency)
    end

end

local kPulseEffectMessage = 
{
    entityId    =   'entityid',
    duration    =   'float', --forever if < 0
    colorR      =   'integer (0 to 255)',
    colorG      =   'integer (0 to 255)',
    colorB      =   'integer (0 to 255)',
    colorA      =   'integer (0 to 255)',
    frequency   =   'float'
}

Shared.RegisterNetworkMessage("CreatePulseEffect", kPulseEffectMessage)

if Server then
    Server.HookNetworkMessage("CreatePulseEffect", OnCreatePulseEffect)
end

Shared.LinkClassToMap('PulseEffect', PulseEffect.kMapName, networkVars)