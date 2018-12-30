local upgradeToRemove = GetUpgradesToRemove()
local upgradeToChange = GetUpgradesToChange()

local oldAddUpgradeNode = TechTree.AddUpgradeNode
function TechTree:AddUpgradeNode(techId, prereq1, prereq2)
    if upgradeToRemove[techId] then
        ModPrintDebug("Removing upgrade: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif upgradeToChange[techId] then
        ModPrintDebug("Changing upgrade: " .. (EnumToString(kTechId, techId) or techId), "all")
        local newNode = upgradeToChange[techId]

        oldAddUpgradeNode(self, newNode[1], newNode[2], newNode[3])
    else
        oldAddUpgradeNode(self, techId, prereq1, prereq2)
    end
end

local researchToRemove = GetResearchToRemove()
local researchToChange = GetResearchToChange()

local oldAddResearchNode = TechTree.AddResearchNode
function TechTree:AddResearchNode(techId, prereq1, prereq2, addOnTechId)
    if researchToRemove[techId] then
        ModPrintDebug("Removing research node: " .. (EnumToString(kTechId, techId) or techId), "all")
    elseif researchToChange[techId] then
        ModPrintDebug("Changing research node: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = researchToChange[techId]

        oldAddResearchNode(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
    end
end

local targetedActivationToRemove = GetTargetedActivationToRemove()
local targetedActivationToChange = GetTargetedActivationToChange()

local oldAddTargetedActivation = TechTree.AddTargetedActivation
function TechTree:AddTargetedActivation(techId, prereq1, prereq2)
    if targetedActivationToRemove[techId] then
        ModPrintDebug("Removing targeted activation: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif targetedActivationToChange[techId] then
        ModPrintDebug("Changing targeted activation: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = targetedActivationToChange[techId]

        oldAddTargetedActivation(self, changedNode[1], changedNode[2], changedNode[3])
    else
        oldAddTargetedActivation(self, techId, prereq1, prereq2)
    end
end

local buyToRemove = GetBuyNodesToRemove()
local buyToChange = GetBuyNodesToChange()

local oldAddBuyNode = TechTree.AddBuyNode
function TechTree:AddBuyNode(techId, prereq1, prereq2, addOnTechId)
    if buyToRemove[techId] then
        ModPrintDebug("Removing buy node: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif buyToChange[techId] then
        ModPrintDebug("Changing buy node: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = buyToChange[techId]

        oldAddBuyNode(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddBuyNode(self, techId, prereq1, prereq2, addOnTechId)
    end
end

local buildToRemove = GetBuildNodesToRemove()
local buildToChange = GetBuildNodesToChange()

local oldAddBuildNode = TechTree.AddBuildNode
function TechTree:AddBuildNode(techId, prereq1, prereq2, isRequired)
    if buildToRemove[techId] then
        ModPrintDebug("Removing build node: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif buildToChange[techId] then
        ModPrintDebug("Changing build node: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = buildToChange[techId]

        oldAddBuildNode(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddBuildNode(self, techId, prereq1, prereq2, isRequired)
    end
end

local passiveToRemove = GetPassiveToRemove()
local passiveToChange = GetPassiveToChange()

local oldAddPassive = TechTree.AddPassive
function TechTree:AddPassive(techId, prereq1, prereq2)
    if passiveToRemove[techId] then
        ModPrintDebug("Removing passive: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif passiveToChange[techId] then
        ModPrintDebug("Changing passive: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = passiveToChange[techId]

        oldAddPassive(self, changedNode[1], changedNode[2], changedNode[3])
    else
        oldAddPassive(self, techId, prereq1, prereq2)
    end
end

local specialToRemove = GetSpecialToRemove()
local specialToChange = GetSpecialToChange()

local oldAddSpecial = TechTree.AddSpecial
function TechTree:AddSpecial(techId, prereq1, prereq2, requiresTarget)
    if specialToRemove[techId] then
        ModPrintDebug("Removing special: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif specialToChange[techId] then
        ModPrintDebug("Changing special: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = specialToChange[techId]

        oldAddSpecial(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddSpecial(self, techId, prereq1, prereq2, requiresTarget)
    end
end

local manufactureNodesToRemove = GetManufactureNodesToRemove()
local manufactureNodesToChange = GetManufactureNodesToChange()

local oldAddManufactureNode = TechTree.AddManufactureNode
function TechTree:AddManufactureNode(techId, prereq1, prereq2, isRequired)
    if manufactureNodesToRemove[techId] then
        ModPrintDebug("Removing manufacture node: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif manufactureNodesToChange[techId] then
        ModPrintDebug("Changing manufacture node: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = manufactureNodesToChange[techId]

        oldAddManufactureNode(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddManufactureNode(self, techId, prereq1, prereq2, isRequired)
    end
end

local ordersToRemove = GetOrdersToRemove()

local oldAddOrder = TechTree.AddOrder
function TechTree:AddOrder(techId)
    if ordersToRemove[techId] then
        ModPrintDebug("Removing order: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    else
        oldAddOrder(self, techId)
    end
end

local activationToRemove = GetActivationToRemove()
local activationToChange = GetActivationToChange()

local oldAddActivation = TechTree.AddActivation
function TechTree:AddActivation(techId, prereq1, prereq2)
    if activationToRemove[techId] then
        ModPrintDebug("Removing activation: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif activationToChange[techId] then
        ModPrintDebug("Changing activation: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = activationToChange[techId]

        oldAddActivation(self, changedNode[1], changedNode[2], changedNode[3])
    else
        oldAddActivation(self, techId, prereq1, prereq2)
    end
end

local targetedBuyToRemove = GetTargetedBuyToRemove()
local targetedBuyToChange = GetTargetedBuyToChange()

local oldAddTargetedBuyNode = TechTree.AddTargetedBuyNode
function TechTree:AddTargetedBuyNode(techId, prereq1, prereq2, addOnTechId)
    if targetedBuyToRemove[techId] then
        ModPrintDebug("Removing targeted buy node: " .. (EnumToString(kTechId, techId) or techId), "all")
        return
    elseif targetedBuyToChange[techId] then
        ModPrintDebug("Changing targeted buy node: " .. (EnumToString(kTechId, techId) or techId), "all")
        local changedNode = targetedBuyToChange[techId]

        oldAddTargetedBuyNode(self, changedNode[1], changedNode[2], changedNode[3], changedNode[4])
    else
        oldAddTargetedBuyNode(self, techId, prereq1, prereq2, addOnTechId)
    end
end