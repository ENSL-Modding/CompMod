local upgradeToRemove = _G[kModName]:GetUpgradesToRemove()
local upgradeToChange = _G[kModName]:GetUpgradesToChange()

local oldAddUpgradeNode = TechTree.AddUpgradeNode
function TechTree:AddUpgradeNode(techId, prereq1, prereq2)
    if upgradeToRemove[techId] then
        _G[kModName]:PrintDebug("Removing upgrade: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif upgradeToChange[techId] then
        _G[kModName]:PrintDebug("Changing upgrade: " .. (EnumToString(kTechId, techId) or techId), "all")
        local newNode = upgradeToChange[techId]

        oldAddUpgradeNode(self, newNode[1], newNode[2], newNode[3])
    else
        oldAddUpgradeNode(self, techId, prereq1, prereq2)
    end
end

local researchToRemove = _G[kModName]:GetResearchToRemove()
local researchToChange = _G[kModName]:GetResearchToChange()

local oldAddResearchNode = TechTree.AddResearchNode
function TechTree:AddResearchNode(techId, prereq1, prereq2, addOnTechId)
    if researchToRemove[techId] then
        _G[kModName]:PrintDebug("Removing research node: " .. (EnumToString(kTechId, techId) or techId), "all")
    elseif researchToChange[techId] then
        _G[kModName]:PrintDebug("Changing research node: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = researchToChange[techId]

        oldAddResearchNode(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
    end
end

local targetedActivationToRemove = _G[kModName]:GetTargetedActivationToRemove()
local targetedActivationToChange = _G[kModName]:GetTargetedActivationToChange()

local oldAddTargetedActivation = TechTree.AddTargetedActivation
function TechTree:AddTargetedActivation(techId, prereq1, prereq2)
    if targetedActivationToRemove[techId] then
        _G[kModName]:PrintDebug("Removing targeted activation: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif targetedActivationToChange[techId] then
        _G[kModName]:PrintDebug("Changing targeted activation: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = targetedActivationToChange[techId]

        oldAddTargetedActivation(self, changedNode[1], changedNode[2], changedNode[3])
    else
        oldAddTargetedActivation(self, techId, prereq1, prereq2)
    end
end

local buyToRemove = _G[kModName]:GetBuyNodesToRemove()
local buyToChange = _G[kModName]:GetBuyNodesToChange()

local oldAddBuyNode = TechTree.AddBuyNode
function TechTree:AddBuyNode(techId, prereq1, prereq2, addOnTechId)
    if buyToRemove[techId] then
        _G[kModName]:PrintDebug("Removing buy node: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif buyToChange[techId] then
        _G[kModName]:PrintDebug("Changing buy node: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = buyToChange[techId]

        oldAddBuyNode(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddBuyNode(self, techId, prereq1, prereq2, addOnTechId)
    end
end

local buildToRemove = _G[kModName]:GetBuildNodesToRemove()
local buildToChange = _G[kModName]:GetBuildNodesToChange()

local oldAddBuildNode = TechTree.AddBuildNode
function TechTree:AddBuildNode(techId, prereq1, prereq2, isRequired)
    if buildToRemove[techId] then
        _G[kModName]:PrintDebug("Removing build node: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif buildToChange[techId] then
        _G[kModName]:PrintDebug("Changing build node: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = buildToChange[techId]

        oldAddBuildNode(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddBuildNode(self, techId, prereq1, prereq2, isRequired)
    end
end

local passiveToRemove = _G[kModName]:GetPassiveToRemove()
local passiveToChange = _G[kModName]:GetPassiveToChange()

local oldAddPassive = TechTree.AddPassive
function TechTree:AddPassive(techId, prereq1, prereq2)
    if passiveToRemove[techId] then
        _G[kModName]:PrintDebug("Removing passive: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif passiveToChange[techId] then
        _G[kModName]:PrintDebug("Changing passive: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = passiveToChange[techId]

        oldAddPassive(self, changedNode[1], changedNode[2], changedNode[3])
    else
        oldAddPassive(self, techId, prereq1, prereq2)
    end
end

local specialToRemove = _G[kModName]:GetSpecialToRemove()
local specialToChange = _G[kModName]:GetSpecialToChange()

local oldAddSpecial = TechTree.AddSpecial
function TechTree:AddSpecial(techId, prereq1, prereq2, requiresTarget)
    if specialToRemove[techId] then
        _G[kModName]:PrintDebug("Removing special: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif specialToChange[techId] then
        _G[kModName]:PrintDebug("Changing special: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = specialToChange[techId]

        oldAddSpecial(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddSpecial(self, techId, prereq1, prereq2, requiresTarget)
    end
end

local manufactureNodesToRemove = _G[kModName]:GetManufactureNodesToRemove()
local manufactureNodesToChange = _G[kModName]:GetManufactureNodesToChange()

local oldAddManufactureNode = TechTree.AddManufactureNode
function TechTree:AddManufactureNode(techId, prereq1, prereq2, isRequired)
    if manufactureNodesToRemove[techId] then
        _G[kModName]:PrintDebug("Removing manufacture node: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif manufactureNodesToChange[techId] then
        _G[kModName]:PrintDebug("Changing manufacture node: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = manufactureNodesToChange[techId]

        oldAddManufactureNode(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddManufactureNode(self, techId, prereq1, prereq2, isRequired)
    end
end

local ordersToRemove = _G[kModName]:GetOrdersToRemove()

local oldAddOrder = TechTree.AddOrder
function TechTree:AddOrder(techId)
    if ordersToRemove[techId] then
        _G[kModName]:PrintDebug("Removing order: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    else
        oldAddOrder(self, techId)
    end
end

local activationToRemove = _G[kModName]:GetActivationToRemove()
local activationToChange = _G[kModName]:GetActivationToChange()

local oldAddActivation = TechTree.AddActivation
function TechTree:AddActivation(techId, prereq1, prereq2)
    if activationToRemove[techId] then
        _G[kModName]:PrintDebug("Removing activation: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif activationToChange[techId] then
        _G[kModName]:PrintDebug("Changing activation: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = activationToChange[techId]

        oldAddActivation(self, changedNode[1], changedNode[2], changedNode[3])
    else
        oldAddActivation(self, techId, prereq1, prereq2)
    end
end

local targetedBuyToRemove = _G[kModName]:GetTargetedBuyToRemove()
local targetedBuyToChange = _G[kModName]:GetTargetedBuyToChange()

local oldAddTargetedBuyNode = TechTree.AddTargetedBuyNode
function TechTree:AddTargetedBuyNode(techId, prereq1, prereq2, addOnTechId)
    if targetedBuyToRemove[techId] then
        _G[kModName]:PrintDebug("Removing targeted buy node: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif targetedBuyToChange[techId] then
        _G[kModName]:PrintDebug("Changing targeted buy node: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = targetedBuyToChange[techId]

        oldAddTargetedBuyNode(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddTargetedBuyNode(self, techId, prereq1, prereq2, addOnTechId)
    end
end
