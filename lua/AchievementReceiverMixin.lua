-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\AchievementReceiverMixin.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- This mixin assigns stats based achievements to the players

AchievementReceiverMixin = CreateMixin(AchievementReceiverMixin)
AchievementReceiverMixin.type = "AchievementReceiver"

function AchievementReceiverMixin:__initmixin()
    
    PROFILE("AchievementReceiverMixin:__initmixin")
    
    self.weldedPowerNodes = 0
    self.weldedPlayers = 0
    self.buildResTowers = 0
    self.killedResTowers = 0
    self.defendedResTowers = 0
    self.followedOrders = 0
    self.parsitedPlayers = 0
    self.structureDamageDealt = 0
    self.playerDamageDealt = 0
    self.destroyedRessources = 0
end

if Server then
	
	local function RewardAchievement(player, name)
		if player and player.GetClient and player:GetClient() then
			Server.SetAchievement(player:GetClient(), name)
		end
	end
	
	function AchievementReceiverMixin:CheckWeldedPowerNodes()
		if self.weldedPowerNodes == 5 then
			RewardAchievement(self, "Short_0_5")
		elseif self.weldedPowerNodes == 1 then
			RewardAchievement(self, "Short_0_4")
		end
	end

	function AchievementReceiverMixin:CheckWeldedPlayers()
		if self.weldedPlayers == 10 then
			RewardAchievement(self, "Short_0_2")
		end
	end

	function AchievementReceiverMixin:CheckBuildResTowers()
		if self.buildResTowers == 10 then
			RewardAchievement(self, "Short_0_1")
		end
	end

	function AchievementReceiverMixin:CheckKilledResTowers()
		if self:GetTeamNumber() == kTeam1Index then
			if self.killedResTowers == 10 then
				RewardAchievement(self, "Short_0_17")
			elseif self.killedResTowers == 5 then
				RewardAchievement(self, "Short_0_16")
			elseif self.killedResTowers == 1 then
				RewardAchievement(self, "Short_0_15")
			end
		else
			if self.killedResTowers == 10 then
				RewardAchievement(self, "Short_1_6")
			elseif self.killedResTowers == 5 then
				RewardAchievement(self, "Short_1_5")
			elseif self.killedResTowers == 1 then
				RewardAchievement(self, "Short_1_4")
			end
		end
	end

	function AchievementReceiverMixin:CheckDefendedResTowers()
		if self:GetTeamNumber() == kTeam1Index then
			if self.defendedResTowers == 10 then
				RewardAchievement(self, "Short_0_14")
			elseif self.defendedResTowers == 5 then
				RewardAchievement(self, "Short_0_13")
			elseif self.defendedResTowers == 1 then
				RewardAchievement(self, "Short_0_12")
			end
		else
			if self.defendedResTowers == 10 then
				RewardAchievement(self, "Short_1_18")
			elseif self.defendedResTowers == 5 then
				RewardAchievement(self, "Short_1_17")
			elseif self.defendedResTowers == 1 then
				RewardAchievement(self, "Short_1_16")
			end
		end
	end

	function AchievementReceiverMixin:CheckFollowedOrders()
		if self.followedOrders == 5 then
			RewardAchievement(self, "Short_0_11")
		end
	end

	function AchievementReceiverMixin:CheckParasitedPlayers()
		if self.parsitedPlayers == 20 then
			RewardAchievement(self, "Short_1_3")
		elseif self.parsitedPlayers == 10 then
			RewardAchievement(self, "Short_1_2")
		elseif self.parsitedPlayers == 1 then
			RewardAchievement(self, "Short_1_1")
		end
	end

	function AchievementReceiverMixin:CheckStructureDamageDealt()
		if self.structureDamageDealt >= 7500 then
			RewardAchievement(self, "Short_2_1")
		end

		return true
	end

	function AchievementReceiverMixin:CheckPlayerDamageDealt()
		if self.playerDamageDealt >= 4000 then
			RewardAchievement(self, "Short_2_2")
		end
	end

	function AchievementReceiverMixin:CheckDestroyedRessources()
		if self.destroyedRessources >= 300 then
			RewardAchievement(self, "Short_2_10")
		elseif self.destroyedRessources >= 200 then
			RewardAchievement(self, "Short_2_9")
		elseif self.destroyedRessources >= 100 then
			RewardAchievement(self, "Short_2_8")
		end
	end

	function AchievementReceiverMixin:OnPhaseGateEntry()
		RewardAchievement(self, "Short_0_3")
	end

	function AchievementReceiverMixin:OnUseGorgeTunnel()
		RewardAchievement(self, "Short_1_12")
	end

	function AchievementReceiverMixin:AddWeldedPowerNodes()
		self.weldedPowerNodes = self.weldedPowerNodes + 1
		
		self:CheckWeldedPowerNodes()
	end

	function AchievementReceiverMixin:AddWeldedPlayers()
		self.weldedPlayers = self.weldedPlayers + 1

		self:CheckWeldedPlayers()
	end

	function AchievementReceiverMixin:AddBuildResTowers()
		self.buildResTowers = self.buildResTowers + 1
		
		self:CheckBuildResTowers()
	end

	function AchievementReceiverMixin:AddKilledResTowers()
		self.killedResTowers = self.killedResTowers + 1

		self:CheckKilledResTowers()
	end

	function AchievementReceiverMixin:AddDefendedResTowers()
		self.defendedResTowers = self.defendedResTowers + 1
		
		self:CheckDefendedResTowers()
	end

	function AchievementReceiverMixin:AddParsitedPlayers()
		self.parsitedPlayers = self.parsitedPlayers + 1
		
		self:CheckParasitedPlayers()
	end

	function AchievementReceiverMixin:AddStructureDamageDealt(amount)
		self.structureDamageDealt = self.structureDamageDealt + amount
		
		self:CheckStructureDamageDealt()
	end

	function AchievementReceiverMixin:AddPlayerDamageDealt(amount)
		self.playerDamageDealt = self.playerDamageDealt + amount
		
		self:CheckPlayerDamageDealt()
	end

	function AchievementReceiverMixin:AddDestroyedRessources(amount)
		self.destroyedRessources = self.destroyedRessources + amount
		
		self:CheckDestroyedRessources()
	end

	function AchievementReceiverMixin:CompletedCurrentOrder()
		self.followedOrders = self.followedOrders + 1
		
		self:CheckFollowedOrders()
	end

	function AchievementReceiverMixin:ResetScores()
		self.weldedPowerNodes = 0
		self.weldedPlayers = 0
		self.buildResTowers = 0
		self.killedResTowers = 0
		self.defendedResTowers = 0
		self.followedOrders = 0
		self.parsitedPlayers = 0
		self.structureDamageDealt = 0
		self.playerDamageDealt = 0
		self.destroyedRessources = 0
	end

	function AchievementReceiverMixin:CopyPlayerDataFrom(player)
		self.weldedPowerNodes = player.weldedPowerNodes or 0
		self.weldedPlayers = player.weldedPlayers or 0
		self.buildResTowers = player.buildResTowers or 0
		self.killedResTowers = player.killedResTowers or 0
		self.defendedResTowers = player.defendedResTowers or 0
		self.followedOrders = player.followedOrders or 0
		self.parsitedPlayers = player.parsitedPlayers or 0
		self.structureDamageDealt = player.structureDamageDealt or 0
		self.playerDamageDealt = player.playerDamageDealt or 0
		self.destroyedRessources = player.destroyedRessources or 0
	end

end

if Client then
	local kTimeNeededCaged = 3600 * 2 -- two hours of gametimes
	local kTimeNeededArcade = 3600


	function AchievementReceiverMixin:GetMaxPlayer()
		if self.maxPlayers then return self.maxPlayers end

		local perfData = Shared.GetServerPerformanceData()

		if perfData then
			self.maxPlayers = perfData:GetMaxPlayers()
			return self.maxPlayers
		end

		return 0
	end

	function AchievementReceiverMixin:OnUpdatePlayer(deltaTime)
		if self ~= Client.GetLocalPlayer() then return end

		if gDisablePlaytimeAch or Shared.GetCheatsEnabled() or Shared.GetDevMode()
				or Shared.GetTestsEnabled() or not GetGameInfoEntity():GetIsDedicated() then

			gDisablePlaytimeAch = true
			return

		end

		if GetGameInfoEntity() and GetGameInfoEntity():GetGameStarted() then

			if self:GetMaxPlayer() > 24 or GetGamemode() ~= "ns2" then

				if self.timeSinceLastArcadeUpdate and self.timeSinceLastArcadeUpdate > 10 then

					self.timeSinceLastArcadeUpdate = 0

					local playtime = Client.GetOptionInteger( "maps/arcade_playtime", 0 )
					playtime = playtime + 10
					Client.SetOptionInteger( "maps/arcade_playtime", playtime)

					if playtime >= kTimeNeededArcade and not Client.GetAchievement("Long_0_2")then
						Client.SetAchievement("Long_0_2") -- give arcade achievement
					end

				else
					self.timeSinceLastArcadeUpdate = (self.timeSinceLastArcadeUpdate or 0) + deltaTime
				end

			elseif Shared.GetMapName() == "ns2_caged" then

				if self.timeSinceLastCagedUpdate and self.timeSinceLastCagedUpdate > 10 then

					self.timeSinceLastCagedUpdate = 0
					local playtime = Client.GetOptionInteger("maps/caged_playtime",
						Client.GetOptionInteger( "system/caged_playtime", 0 ))

					if playtime == -1 then
						playtime = kTimeNeededCaged
					end

					playtime = playtime + 10
					Client.SetOptionInteger( "maps/caged_playtime", playtime)

					if playtime >= kTimeNeededCaged and not Client.GetAchievement("Long_0_1")then
						Client.SetAchievement("Long_0_1") -- give caged achievement
						--Client.GrantPromoItems()
						--InventoryNewItemNotifyPush( 601 )
					end

				else

					self.timeSinceLastCagedUpdate = (self.timeSinceLastCagedUpdate or 0) + deltaTime

				end

			end

		end

	end

end