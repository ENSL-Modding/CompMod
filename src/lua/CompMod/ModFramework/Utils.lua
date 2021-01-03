local ENABLE_DEBUG_PRINT = false

local function fw_print(module, level, msg, ...)
    local args = {...}
    local moduleName = module and module.moduleName or "Main"
    local vm = Client and "Client" or Server and "Server" or Predict and "Predict" or "Unknown"
    local prefix = string.format("[ModFramework - %s](%s) %s:", moduleName, vm, level)

    if #args > 0 then
        msg = string.format(msg, unpack(args))
    end

    local finalMessage = string.format("%s %s", prefix, msg)
    print(finalMessage)
end

function fw_print_info(module, msg, ...)
    fw_print(module, "Info", msg, ...)
end

function fw_print_warn(module, msg, ...)
    fw_print(module, "Warn", msg, ...)
end

function fw_print_debug(module, msg, ...)
    if ENABLE_DEBUG_PRINT then
        fw_print(module, "Debug", msg, ...)
    end
end

function fw_print_fatal(module, msg, ...)
    fw_print(module, "Fatal", msg, ...)
end

function fw_assert(value, msg, module)
    -- If we know the assert will fail, log it first :)
    if value == false or value == nil then
        fw_print_fatal(module, msg)
    end

    return assert(value, msg)
end

function fw_assert_nil(value, msg, module)
    return fw_assert(value == nil, msg, module)
end

function fw_assert_not_nil(value, msg, module)
    return fw_assert(value ~= nil, msg, module)
end

function fw_assert_type(value, expectedType, varName, module)
    local actualType = type(value)
    return fw_assert(actualType == expectedType, varName .. ": Expected type " .. expectedType .. ", got " .. actualType .. ".", module)
end
