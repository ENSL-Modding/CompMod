local Mod = GetMod()

-- Table for new tech names
local newTechNames = Mod:GetTechIdsToAdd()

for _,v in ipairs(newTechNames) do
  Mod:AppendToEnum(kTechId, v)
end

Mod:OnTechIdsAdded()
