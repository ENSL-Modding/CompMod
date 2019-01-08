-- add neurotoxin to the upgradechamber display on the left hand side of the hud

Script.Load("lua/GUIUpgradeChamberDisplay.lua")

local oldInitialize
oldInitialize = Class_ReplaceMethod("GUIUpgradeChamberDisplay", "Initialize",
    function(self)
        oldInitialize(self)
        local kIndexToUpgrades = CompMod:GetLocalVariable(GUIUpgradeChamberDisplay.Update, "kIndexToUpgrades")
    	for i = 1, 3 do
    		if kIndexToUpgrades[i][1] == kTechId.Veil then
    			for j = 1, #kIndexToUpgrades[i] do
    				if kIndexToUpgrades[i][j] == kTechId.Focus then
    					table.remove(kIndexToUpgrades[i], j)
    				end
    			end
    			table.insert(kIndexToUpgrades[i], kTechId.Neurotoxin)
    		end
    	end
    end
)

-- TODO: add gui post/pre script system

local kIconTexture = "ui/compmod_buildmenu.dds"
local CreateIcons = CompMod:GetLocalVariable(oldInitialize, "CreateIcons")
local CreateUpgradeIcon = CompMod:GetLocalVariable(CreateIcons, "CreateUpgradeIcon")

ReplaceLocals(CreateUpgradeIcon, {kIconTexture = kIconTexture})
