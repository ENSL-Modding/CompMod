local mod = CompMod
local logger = mod:GetModule('logger')
local techHandler = mod:GetModule('techhandler')

local function ApplyNodeAdditions(techTree, addNodeFunction, nodeName, toAdd)
    logger:PrintDebug("Applying %s Alien%s additions", #toAdd, nodeName)
    for _,v in ipairs(toAdd) do
        local rec = type(v) == "table" and v or { v }
        local techId = rec[1]

        local techName = EnumToString(kTechId, techId) or techId
        logger:PrintDebug("Adding %s: %s", nodeName, techName)
        addNodeFunction(techTree, unpack(rec))
    end
end

local oldInitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()
    oldInitTechTree(self)
	self.complete = false

    ApplyNodeAdditions(self.techTree, self.techTree.AddOrder,                 "Order",                 techHandler:GetOrderToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddBuildNode,             "BuildNode",             techHandler:GetBuildNodeToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddEnergyBuildNode,       "EnergyBuildNode",       techHandler:GetEnergyBuildNodeToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddManufactureNode,       "ManufactureNode",       techHandler:GetManufactureNodeToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddBuyNode,               "BuyNode",               techHandler:GetBuyNodeToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddTargetedBuyNode,       "TargetedBuyNode",       techHandler:GetTargetedBuyNodeToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddResearchNode,          "ResearchNode",          techHandler:GetResearchNodeToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddUpgradeNode,           "UpgradeNode",           techHandler:GetUpgradeNodeToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddAction,                "Action",                techHandler:GetActionToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddTargetedAction,        "TargetedAction",        techHandler:GetTargetedActionToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddActivation,            "Activation",            techHandler:GetActivationToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddTargetedActivation,    "TargetedActivation",    techHandler:GetTargetedActivationToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddMenu,                  "Menu",                  techHandler:GetMenuToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddEnergyManufactureNode, "EnergyManufactureNode", techHandler:GetEnergyManufactureNodeToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddPlasmaManufactureNode, "PlasmaManufactureNode", techHandler:GetPlasmaManufactureNodeToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddSpecial,               "Special",               techHandler:GetSpecialToAdd().alien)
    ApplyNodeAdditions(self.techTree, self.techTree.AddPassive,               "Passive",               techHandler:GetPassiveToAdd().alien)

	self.techTree:SetComplete()
end
