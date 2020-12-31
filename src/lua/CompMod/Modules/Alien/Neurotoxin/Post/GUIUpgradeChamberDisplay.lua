local oldInitialize = GUIUpgradeChamberDisplay.Initialize
function GUIUpgradeChamberDisplay:Initialize()
    oldInitialize(self)
    local kIndexToUpgrades = debug.getupvaluex(GUIUpgradeChamberDisplay.Update, "kIndexToUpgrades")
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
