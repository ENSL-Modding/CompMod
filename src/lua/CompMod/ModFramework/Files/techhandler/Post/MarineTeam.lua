local mod = CompMod
local logger = mod:GetModule('logger')
local techHandler = mod:GetModule('techhandler')

local function ApplyNodeAdditions(techTree, addNodeFunction, nodeName, toAdd)
    logger:PrintDebug("Applying %s Marine%s additions", #toAdd, nodeName)
    for _,v in ipairs(toAdd) do
        local rec = type(v) == "table" and v or { v }
        local techId = rec[1]

        local techName = EnumToString(kTechId, techId) or techId
        logger:PrintDebug("Adding %s: %s", nodeName, techName)
        addNodeFunction(techTree, unpack(rec))
    end
end

local oldInitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()
    oldInitTechTree(self)
    self.complete = false

    ApplyNodeAdditions(self.techTree, self.techTree.AddOrder,                 "Order",                 techHandler:GetOrderToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddBuildNode,             "BuildNode",             techHandler:GetBuildNodeToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddEnergyBuildNode,       "EnergyBuildNode",       techHandler:GetEnergyBuildNodeToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddManufactureNode,       "ManufactureNode",       techHandler:GetManufactureNodeToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddBuyNode,               "BuyNode",               techHandler:GetBuyNodeToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddTargetedBuyNode,       "TargetedBuyNode",       techHandler:GetTargetedBuyNodeToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddResearchNode,          "ResearchNode",          techHandler:GetResearchNodeToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddUpgradeNode,           "UpgradeNode",           techHandler:GetUpgradeNodeToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddAction,                "Action",                techHandler:GetActionToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddTargetedAction,        "TargetedAction",        techHandler:GetTargetedActionToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddActivation,            "Activation",            techHandler:GetActivationToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddTargetedActivation,    "TargetedActivation",    techHandler:GetTargetedActivationToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddMenu,                  "Menu",                  techHandler:GetMenuToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddEnergyManufactureNode, "EnergyManufactureNode", techHandler:GetEnergyManufactureNodeToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddPlasmaManufactureNode, "PlasmaManufactureNode", techHandler:GetPlasmaManufactureNodeToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddSpecial,               "Special",               techHandler:GetSpecialToAdd().marine)
    ApplyNodeAdditions(self.techTree, self.techTree.AddPassive,               "Passive",               techHandler:GetPassiveToAdd().marine)

	self.techTree:SetComplete()
end
