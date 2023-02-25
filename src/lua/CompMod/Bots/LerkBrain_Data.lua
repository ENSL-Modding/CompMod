-- Remove table entries for Umbra and Spores. We don't use bots in comp so this is really just to disable the actions for hallucinations

-- table.remove(kLerkBrainActions, 2)
-- table.remove(kLerkBrainActions, 1)

-- Trying to be a bit more robust than hardcoding indexes
local idxsToRemove = {}
for k,v in ipairs(kLerkBrainActions) do
    if type(v) == "function" then
        local i = 1
        while true do
            local n,_ = debug.getupvalue(v, i)
            if not n then break end

            if n == "PerformUmbraFriendlies" or n == "PerformSporeHostiles" then
                table.insert(idxsToRemove, k)
                break
            end
            i = i + 1
        end
    end
end

-- Need to sort the indexes so that we remove later entries first. If we remove earlier indexes first then we will change all the indexes of the later entries
table.sort(idxsToRemove, function (i1, i2) return i1 >= i2 end )
for _,v in ipairs(idxsToRemove) do
    table.remove(kLerkBrainActions, v)
end
