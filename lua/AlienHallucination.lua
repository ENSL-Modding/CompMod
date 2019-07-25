-- ======= Copyright (c) 2003-2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\AlienHallucination.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/PlayerHallucinationMixin.lua")
Script.Load("lua/SoftTargetMixin.lua")
Script.Load("lua/OrdersMixin.lua")

class "SkulkHallucination" (Skulk)
SkulkHallucination.kMapName = "skulkHallucination"

function SkulkHallucination:OnCreate()
    Skulk.OnCreate(self)
    self.isHallucination = true

    InitMixin(self, SoftTargetMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance })

    if Server then
        InitMixin(self, PlayerHallucinationMixin)
    end
end

function SkulkHallucination:SetEmulation(player)
    self:SetName(player:GetName())
    self:SetHallucinatedClientIndex(player:GetClientIndex())

    if player:isa("Alien") then
        self:SetVariant(player:GetVariant())
    end
end

function SkulkHallucination:GetMapBlipType()
    return kMinimapBlipType.Skulk
end

Shared.LinkClassToMap("SkulkHallucination", SkulkHallucination.kMapName, {})

class "GorgeHallucination" (Gorge)
GorgeHallucination.kMapName = "GorgeHallucination"

function GorgeHallucination:OnCreate()
    Gorge.OnCreate(self)
    self.isHallucination = true

    InitMixin(self, SoftTargetMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance })

    if Server then
        InitMixin(self, PlayerHallucinationMixin)
    end
end

function GorgeHallucination:SetEmulation(player)
    self:SetName(player:GetName())
    self:SetHallucinatedClientIndex(player:GetClientIndex())

    if player:isa("Alien") then
        self:SetVariant(player:GetVariant())
    end
end

function GorgeHallucination:GetMapBlipType()
    return kMinimapBlipType.Gorge
end

Shared.LinkClassToMap("GorgeHallucination", GorgeHallucination.kMapName, {})

class "LerkHallucination" (Lerk)
LerkHallucination.kMapName = "lerkHallucination"

function LerkHallucination:OnCreate()
    Lerk.OnCreate(self)
    self.isHallucination = true

    InitMixin(self, SoftTargetMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance })

    if Server then
        InitMixin(self, PlayerHallucinationMixin)
    end
end

function LerkHallucination:SetEmulation(player)
    self:SetName(player:GetName())
    self:SetHallucinatedClientIndex(player:GetClientIndex())

    if player:isa("Alien") then
        self:SetVariant(player:GetVariant())
    end
end

function LerkHallucination:GetMapBlipType()
    return kMinimapBlipType.Lerk
end

Shared.LinkClassToMap("LerkHallucination", LerkHallucination.kMapName, {})

class "FadeHallucination" (Fade)
FadeHallucination.kMapName = "fadeHallucination"

function FadeHallucination:OnCreate()
    Fade.OnCreate(self)
    self.isHallucination = true

    InitMixin(self, SoftTargetMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance })

    if Server then
        InitMixin(self, PlayerHallucinationMixin)
    end
end

function FadeHallucination:SetEmulation(player)
    self:SetName(player:GetName())
    self:SetHallucinatedClientIndex(player:GetClientIndex())

    if player:isa("Alien") then
        self:SetVariant(player:GetVariant())
    end
end

function FadeHallucination:GetMapBlipType()
    return kMinimapBlipType.Fade
end

Shared.LinkClassToMap("FadeHallucination", FadeHallucination.kMapName, {})

class "OnosHallucination" (Onos)
OnosHallucination.kMapName = "onosHallucination"

function OnosHallucination:OnCreate()
    Onos.OnCreate(self)
    self.isHallucination = true

    InitMixin(self, SoftTargetMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance })

    if Server then
        InitMixin(self, PlayerHallucinationMixin)
    end
end

function OnosHallucination:SetEmulation(player)
    self:SetName(player:GetName())
    self:SetHallucinatedClientIndex(player:GetClientIndex())

    if player:isa("Alien") then
        self:SetVariant(player:GetVariant())
    end
end

function OnosHallucination:GetMapBlipType()
    return kMinimapBlipType.Onos
end

Shared.LinkClassToMap("OnosHallucination", OnosHallucination.kMapName, {})