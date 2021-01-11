Script.Load("lua/CompMod/ModFramework/Modules/FrameworkModule.lua")

class 'EnumUtilitiesModule' (FrameworkModule)

function EnumUtilitiesModule:Initialize(framework)
    FrameworkModule.Initialize(self, "enumutilities", framework, false)
end

--[[
    Append key to enum

    tbl: Enum
    key: Key
]]
function EnumUtilitiesModule:AppendToEnum(tbl, key)
    fw_assert_not_nil(tbl, "Enum cannot be nil", self)
    fw_assert_type(tbl, "table", "Enum", self)
    fw_assert_not_nil(key, "Key cannot be nil", self)
    fw_assert_nil(rawget(tbl,key), "Key already exists in enum.")

    local maxVal
    if tbl == kTechId then
        maxVal = tbl.Max

        -- Delete old max
        rawset(tbl, rawget(tbl, maxVal), nil)
        rawset(tbl, maxVal, nil)

        -- Move max down
        rawset(tbl, 'Max', maxVal + 1)
        rawset(tbl, maxVal + 1, 'Max')
    else
        maxVal = -1
        for k, v in next, tbl do
            if type(v) == "number" and v > maxVal then
                maxVal = v
            end
        end
        maxVal = maxVal + 1
    end

    fw_assert_not_nil(maxVal, "Failed to get next value for enum")

    rawset(tbl, key, maxVal)
    rawset(tbl, maxVal, key)
end

--[[
    Delete key from enum

    tbl: Enum
    key: Key
]]
function EnumUtilitiesModule:RemoveFromEnum(tbl, key)
    fw_assert_not_nil(tbl, "Enum cannot be nil", self)
    fw_assert_type(tbl, "table", "Enum", self)

    fw_assert_not_nil(key, "Key cannot be nil", self)

    fw_assert_not_nil(rawget(tbl, key), "Key doesn't exist in enum", self)

    -- Delete enum entry
    rawset(tbl, rawget(tbl, key), nil)
    rawset(tbl, key, nil)

    -- If we modified the kTechId eunm, we need to update kTechId.Max too.
    if tbl == kTechId then
        local maxVal = tbl.Max

        -- delete old max
        rawset(tbl, rawget(tbl, maxVal), nil)
        rawset(tbl, maxVal, nil)
    
        -- move max down
        rawset(tbl, 'Max', maxVal - 1)
        rawset(tbl, maxVal - 1, 'Max')
    end
end
