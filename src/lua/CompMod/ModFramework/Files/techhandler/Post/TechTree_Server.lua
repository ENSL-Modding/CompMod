local mod = CompMod
local logger = mod:GetModule('logger')
local techHandler = mod:GetModule('techhandler')

local function CreateHook(functionName, nodeName, oldFunction, toChangeGetter, toRemoveGetter)
    local tempFunc = function(self, ...)
        local args = {...}
        local techId = args[1]
        local techName = EnumToString(kTechId, techId) or techId
        local toChange = toChangeGetter(techHandler)
        local toRemove = toRemoveGetter(techHandler)

        if toRemove.marine[techId] or toRemove.alien[techId] then
            logger:PrintDebug("Removing %s: %s", nodeName, techName)
        elseif toChange.marine[techId] or toChange.alien[techId] then
            logger:PrintDebug("Changing %s: %s", nodeName, techName)

            local changedNode = toChange.marine[techId] or toChange.alien[techId]
            if type(changedNode) ~= "table" then
                changedNode = { changedNode }
            end
            oldFunction(self, unpack(changedNode))
        else
            local arg = ...
            if type(arg) ~= "table" then
                arg = { ... }
            end
            oldFunction(self, unpack(arg))
        end
    end

    TechTree[functionName] = tempFunc
end

local oldAddOrder = TechTree.AddOrder
function TechTree:AddOrder(techId)
    local orderToRemove = techHandler:GetOrderToRemove()

    if orderToRemove[techId] then
        logger:PrintDebug("Removing Order: " .. (EnumToString(kTechId, techId) or techId))
    else
        oldAddOrder(self, techId)
    end
end

CreateHook("AddTechInheritance",        "TechInheritance",      TechTree.AddTechInheritance,       techHandler.GetTechInheritanceToChange,       techHandler.GetTechInheritanceToRemove)
CreateHook("AddBuildNode",              "BuildNode",            TechTree.AddBuildNode,             techHandler.GetBuildNodeToChange,             techHandler.GetBuildNodeToRemove)
CreateHook("AddEnergyBuildNode",        "EnergyBuildNode",      TechTree.AddEnergyBuildNode,       techHandler.GetEnergyBuildNodeToChange,       techHandler.GetEnergyBuildNodeToRemove)
CreateHook("AddManufactureNode",        "ManufactureNode",      TechTree.AddManufactureNode,       techHandler.GetManufactureNodeToChange,       techHandler.GetManufactureNodeToRemove)
CreateHook("AddBuyNode",                "BuyNode",              TechTree.AddBuyNode,               techHandler.GetBuyNodeToChange,               techHandler.GetBuyNodeToRemove)
CreateHook("AddTargetedBuyNode",        "TargetedBuyNode",      TechTree.AddTargetedBuyNode,       techHandler.GetTargetedBuyNodeToChange,       techHandler.GetTargetedBuyNodeToRemove)
CreateHook("AddResearchNode",           "ResearchNode",         TechTree.AddResearchNode,          techHandler.GetResearchNodeToChange,          techHandler.GetResearchNodeToRemove)
CreateHook("AddUpgradeNode",            "UpgradeNode",          TechTree.AddUpgradeNode,           techHandler.GetUpgradeNodeToChange,           techHandler.GetUpgradeNodeToRemove)
CreateHook("AddAction",                 "Action",               TechTree.AddAction,                techHandler.GetActionToChange,                techHandler.GetActionToRemove)
CreateHook("AddTargetedAction",         "TargetedAction",       TechTree.AddTargetedAction,        techHandler.GetTargetedActionToChange,        techHandler.GetTargetedActionToRemove)
CreateHook("AddActivation",             "Activation",           TechTree.AddActivation,            techHandler.GetActivationToChange,            techHandler.GetActivationToRemove)
CreateHook("AddTargetedActivation",     "TargetedActivation",   TechTree.AddTargetedActivation,    techHandler.GetTargetedActivationToChange,    techHandler.GetTargetedActivationToRemove)
CreateHook("AddMenu",                   "Menu",                 TechTree.AddMenu,                  techHandler.GetMenuToChange,                  techHandler.GetMenuToRemove)
CreateHook("AddEnergyManufactureNode", "EnergyManufactureNode", TechTree.AddEnergyManufactureNode, techHandler.GetEnergyManufactureNodeToChange, techHandler.GetEnergyManufactureNodeToRemove)
CreateHook("AddPlasmaManufactureNode", "PlasmaManufactureNode", TechTree.AddPlasmaManufactureNode, techHandler.GetPlasmaManufactureNodeToChange, techHandler.GetPlasmaManufactureNodeToRemove)
CreateHook("AddSpecial",               "Special",               TechTree.AddSpecial,               techHandler.GetSpecialToChange,               techHandler.GetSpecialToRemove)
CreateHook("AddPassive",               "Passive",               TechTree.AddPassive,               techHandler.GetPassiveToChange,               techHandler.GetPassiveToRemove)
