-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\MedPack.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/DropPack.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/TeamMixin.lua")

class 'MedPack' (DropPack)

MedPack.kMapName = "medpack"

MedPack.kModelNameWinter = PrecacheAsset("seasonal/holiday2012/models/gift_medkit_01.model")
MedPack.kModelName = PrecacheAsset("models/marine/medpack/medpack.model")

local function GetModelName()
    return GetSeason() == Seasons.kWinter and MedPack.kModelNameWinter or MedPack.kModelName
end

MedPack.kHealth = kMedpackHeal

MedPack.kPickupDelay = kMedpackPickupDelay

local networkVars =
{
}

function MedPack:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel(GetModelName())
    
end

function MedPack:OnTouch(recipient)

    if not recipient.timeLastMedpack or recipient.timeLastMedpack + self.kPickupDelay <= Shared.GetTime() then
    
        recipient:AddHealth(MedPack.kHealth, false, true)
        recipient:AddRegeneration()
        recipient.timeLastMedpack = Shared.GetTime()

        self:TriggerEffects("medpack_pickup", { effecthostcoords = self:GetCoords() })

    end
    
end

function MedPack:GetIsValidRecipient(recipient)
	
	if not recipient:isa("Marine") then
		return false
	end
		
    return recipient:GetIsAlive() and recipient:GetHealth() < recipient:GetMaxHealth() and (not recipient.timeLastMedpack or recipient.timeLastMedpack + self.kPickupDelay <= Shared.GetTime())
	
end


Shared.LinkClassToMap("MedPack", MedPack.kMapName, networkVars, false)