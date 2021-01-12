Script.Load("lua/CompMod/ModFramework/Modules/FrameworkModule.lua")

class 'TechHandlerModule' (FrameworkModule)

function TechHandlerModule:Initialize(framework)
    FrameworkModule.Initialize(self, "techhandler", framework, true)

    -- Used for removing specific techdata entry
    self.Remove = "modFrameworkRemoveTechData"
    
    -- Initialize arrays
    self:CreateArrays("materialOffset",        false)
    self:CreateArrays("techMapTech",           true)
    self:CreateArrays("techMapLine",           true)
    self:CreateArrays("techData",              false)
    self:CreateArrays("order",                 true)
    self:CreateArrays("techInheritance",       true)
    self:CreateArrays("buildNode",             true)
    self:CreateArrays("energyBuildNode",       true)
    self:CreateArrays("manufactureNode",       true)
    self:CreateArrays("buyNode",               true)
    self:CreateArrays("targetedBuyNode",       true)
    self:CreateArrays("researchNode",          true)
    self:CreateArrays("upgradeNode",           true)
    self:CreateArrays("action",                true)
    self:CreateArrays("targetedAction",        true)
    self:CreateArrays("activation",            true)
    self:CreateArrays("targetedActivation",    true)
    self:CreateArrays("menu",                  true)
    self:CreateArrays("energyManufactureNode", true)
    self:CreateArrays("plasmaManufactureNode", true)
    self:CreateArrays("special",               true)
    self:CreateArrays("passive",               true)

    -- Create functions
    self:GenerateFunctions("MaterialOffset",        "materialOffset",        false, { ["add"] = false, ["change"] = false, ["remove"] = false })
    self:GenerateFunctions("TechMapTech",           "techMapTech",           true,  { ["add"] = false, ["change"] = true,  ["remove"] = false })
    self:GenerateFunctions("TechMapLine",           "techMapLine",           true,  { ["add"] = false, ["change"] = false, ["remove"] = false })
    self:GenerateFunctions("TechData",              "techData",              false)
    self:GenerateFunctions("Order",                 "order",                 true)
    self:GenerateFunctions("TechInheritance",       "techInheritance",       true)
    self:GenerateFunctions("BuildNode",             "buildNode",             true)
    self:GenerateFunctions("EnergyBuildNode",       "energyBuildNode",       true)
    self:GenerateFunctions("ManufactureNode",       "manufactureNode",       true)
    self:GenerateFunctions("BuyNode",               "buyNode",               true)
    self:GenerateFunctions("TargetedBuyNode",       "targetedBuyNode",       true)
    self:GenerateFunctions("ResearchNode",          "researchNode",          true)
    self:GenerateFunctions("UpgradeNode",           "upgradeNode",           true)
    self:GenerateFunctions("Action",                "action",                true)
    self:GenerateFunctions("TargetedAction",        "targetedAction",        true)
    self:GenerateFunctions("Activation",            "activation",            true)
    self:GenerateFunctions("TargetedActivation",    "targetedActivation",    true)
    self:GenerateFunctions("Menu",                  "menu",                  true)
    self:GenerateFunctions("EnergyManufactureNode", "energyManufactureNode", true)
    self:GenerateFunctions("PlasmaManufactureNode", "plasmaManufactureNode", true)
    self:GenerateFunctions("Special",               "special",               true)
    self:GenerateFunctions("Passive",               "passive",               true)
end

function TechHandlerModule:ValidateConfig()
    fw_assert_not_nil(self.config.techIdsToAdd, "config.techhandler.techIdsToAdd missing!", self)
    fw_assert_type(self.config.techIdsToAdd, "table", "config.techhandler.techIdsToAdd", self)
end

function TechHandlerModule:CreateArrays(name, perteam)
    self[name .. "ToAdd"] = self:CreateArrayEntry(perteam)
    self[name .. "ToChange"] = self:CreateArrayEntry(perteam)
    self[name .. "ToRemove"] = self:CreateArrayEntry(perteam)
end

function TechHandlerModule:CreateArrayEntry(perteam)
    local entry = {}
    if perteam then
        entry.marine = {}
        entry.alien = {}
    end

    return entry
end

function TechHandlerModule:GenerateFunctions(functionName, arrayName, perteam, useFirstArgIndex)
    self["Get" .. functionName .. "ToAdd"] = function(self) return self[arrayName .. "ToAdd"] end
    self["Get" .. functionName .. "ToChange"] = function(self) return self[arrayName .. "ToChange"] end
    self["Get" .. functionName .. "ToRemove"] = function(self) return self[arrayName .. "ToRemove"] end

    if perteam then
        local teams = { "Alien", "Marine" }
        for _,team in ipairs(teams) do
            self:CreateAddChangeRemoveFunctions(functionName, arrayName, team, useFirstArgIndex)
        end
    else
        self:CreateAddChangeRemoveFunctions(functionName, arrayName, team, useFirstArgIndex)
    end
end

function TechHandlerModule:CreateAddChangeRemoveFunctions(functionName, arrayName, team, useFirstArgIndex)
    useFirstArgIndex = useFirstArgIndex or {}
    local useFirstArgIndexAdd = useFirstArgIndex["add"] == nil and false or useFirstArgIndex["add"]
    local useFirstArgIndexChange = useFirstArgIndex["change"] == nil and true or useFirstArgIndex["change"]
    local useFirstArgIndexRemove = useFirstArgIndex["remove"] == nil and true or useFirstArgIndex["remove"]
    local team_lower

    if team then
        functionName = team .. functionName
        team_lower = team:lower()
    end

    self["Add" .. functionName] = self:CreateGenericArrayModFunction(arrayName .. "ToAdd", useFirstArgIndexAdd, team_lower)
    self["Change" .. functionName] = self:CreateGenericArrayModFunction(arrayName .. "ToChange", useFirstArgIndexChange, team_lower)
    self["Remove" .. functionName] = self:CreateGenericArrayModFunction(arrayName .. "ToRemove", useFirstArgIndexRemove, team_lower)
end

function TechHandlerModule:CreateGenericArrayModFunction(fullArrayName, useFirstArgIndex, team)
    local logger = self.framework:GetModule('logger')

    return function(self, ...)
        local argv = {...}
        local argc = #argv
        assert(argc > 0)
        local val
        local index = -1

        if argc == 1 then
            if useFirstArgIndex then
                index = argv[1]
                val = true
            else
                val = argv[1]
            end
        else
            val = {}

            if useFirstArgIndex then
                index = argv[1]
            end

            for i = 1, argc do
                val[i] = argv[i]
            end
        end

        if useFirstArgIndex then
            assert(index)
            assert(val)
            if team then
                table.insert(self[fullArrayName][team], index, val)
            else
                table.insert(self[fullArrayName], index, val)
            end
        else
            assert(val)
            if team then
                table.insert(self[fullArrayName][team], val)
            else
                table.insert(self[fullArrayName], val)
            end
        end
    end
end

-- This function doesn't fit the pattern of the others so add it manually 
-- instead of generating it
function TechHandlerModule:GetTechIdsToAdd()
    return self.config.techIdsToAdd
end
