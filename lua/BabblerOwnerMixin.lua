BabblerOwnerMixin = CreateMixin(BabblerOwnerMixin)
BabblerOwnerMixin.type = "BabblerOwner"

BabblerOwnerMixin.networkVars = 
{
	babblerCount = "integer (0 to 18)"
}

kBabblerHatchTime = 2.5
function BabblerOwnerMixin:__initmixin()
    
    PROFILE("BabblerOwnerMixin:__initmixin")
    
	self.babblerCount = 0

	if Server then
		self:AddTimedCallback(self.HatchBabbler, kBabblerHatchTime)
	end
end

function BabblerOwnerMixin:GetBabblerCount()
	return self.babblerCount
end

function BabblerOwnerMixin:GetMaxBabblers()
	return 6
end

function BabblerOwnerMixin:OnWeaponAdded(weapon)
    if weapon:GetMapName() == BabblerAbility.kMapName then
        self.babblerBaitId = weapon:GetId()
    end
end

function BabblerOwnerMixin:GetCanHatchBabbler()
    local babblerBait = self.babblerBaitId and Shared.GetEntity(self.babblerBaitId)
    local recentlyThrown = babblerBait and babblerBait:GetRecentlyThrown()
    return self:GetIsOnPlayingTeam() and not self:GetIsUnderFire() and not recentlyThrown and self:GetCanAttachBabbler()
end

if Server then
	function BabblerOwnerMixin:BabblerCreated()
		self.babblerCount = self.babblerCount + 1
	end

	function BabblerOwnerMixin:BabblerDestroyed()
		self.babblerCount = self.babblerCount - 1
	end

	function BabblerOwnerMixin:HatchBabbler()
		if self:GetCanHatchBabbler() then

			local origin = self:GetFreeBabblerAttachPointOrigin()
			local babbler = CreateEntity(Babbler.kMapName, origin, self:GetTeamNumber())

			babbler:SetOwner(self)
			babbler:SetSilenced(self.silenced)

			babbler:SetVariant(self.variant)

			babbler:SetMoveType( kBabblerMoveType.Cling, self, self:GetOrigin(), true )

		end

		return true
	end

    function BabblerOwnerMixin:HatchMaxBabblers()
        while self:GetCanHatchBabbler() do
            self:HatchBabbler()
        end
    end

	function BabblerOwnerMixin:DestroyAllOwnedBabblers()
		local babblers = GetEntitiesForTeam("Babbler", self:GetTeamNumber())

		for i = 1, #babblers do
			local babbler = babblers[i]

			if babbler:GetOwner() == self then
				babbler:Kill()
			end
		end
	end

	function BabblerOwnerMixin:OnKill()
		self:DestroyAllOwnedBabblers()
	end
end