--[[
For testing purposes:

Give the Roost research when biomass 2 is researched, Roost doesn't have to be researched for now.
]]
local oldInitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()
    oldInitTechTree(self)
    self.techTree:GiveUpgrade(kTechId.Roost)
end