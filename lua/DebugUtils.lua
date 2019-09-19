-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\DebugUtils.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Contains useful commands for debugging purposes.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- Prints out all the local variables of a function and the current line number.  Useful for tracing execution in lieu
-- of a proper debugger. :(
function DumpLocals(functionName)
    local debuginfo = debug.getinfo(2, "nSlu")
    local functionName = functionName or debuginfo.name
    local numUpValues = debuginfo.nups
    local lineNumber = debuginfo.currentline
    
    HPrint("%s() @ %s", functionName, lineNumber)
    
    local localIndex = 1
    while true do
        local localName, localValue = debug.getlocal(2, localIndex)
        if not localName then break end
        
        HPrint("    %s = %s", localName, ToString(localValue))
        localIndex = localIndex + 1
    end
    
end

local kDebugTablePrefix = "debug_entities_"

local function PrintEntityFieldData(entity, fieldName)
    if string.sub(fieldName, -2, -1) == "()" then
        local func = string.sub(fieldName, 1, -3)
        if entity[func] then
            Log("    %s:%s(): %s", entity, func, entity[func](entity))
            return
        end
    end
    
    Log("    %s.%s: %s", entity, fieldName, entity[fieldName])
end

local function SetDebugTable(tableName, contents)
    
    if not tableName then
        Log("Attempted to set debug table with invalid name!")
        return
    end
    _G[kDebugTablePrefix .. tableName] = contents
    
end

local function GetDebugTable(tableName)
    
    if not tableName then
        Log("Attempted to retrieve debug table with invalid name!")
        return nil
    end
    
    return _G[kDebugTablePrefix .. tableName]
    
end

local function PrintDebugPrintEntityListUsage()
    Log("Usage: debugprintentitylist [debug table name] [field name]")
end

Shared.RegisterNetworkMessage("DebugPrintEntityField",
{
    entityId = "entityid",
    fieldName = "string (64)",
})

Shared.RegisterNetworkMessage("DebugPrintEntityFieldP",
{
    entityId = "entityid",
    fieldName = "string (64)",
})

local function GetVMName()
    if Predict then
        return "predict"
    end
    if Client then
        return "client"
    end
    return "server"
end

local function OnPrintEntityField(message)
    local entity = Shared.GetEntity(message.entityId)
    if not entity then
        Log("    entity with id %u not found on %s.", message.entityId, GetVMName())
        return
    end
    
    PrintEntityFieldData(entity, message.fieldName)
end

-- You will notice that there are no "DebugPrintEntityFieldP" messages ever sent... only the non-P ones...
-- absolutely no clue why this works... makes no sense.
if  Client then  Client.HookNetworkMessage("DebugPrintEntityField", OnPrintEntityField) end
if Predict then Predict.HookNetworkMessage("DebugPrintEntityFieldP", OnPrintEntityField) end

-- Prevent error message about nothing hooking into message (it doesn't check predict).
local function Dummy()
end
if Client then Client.HookNetworkMessage("DebugPrintEntityFieldP", Dummy) end

if Server then
    local function OnDebugPrintEntityList(client, tableName, fieldName)
        if not (Shared.GetCheatsEnabled() or Shared.GetTestsEnabled()) then
            return
        end
        
        if not tableName then
            PrintDebugPrintEntityListUsage()
            return
        end
        
        if not fieldName then
            PrintDebugPrintEntityListUsage()
            return
        end
        
        local debugTable = GetDebugTable(tableName)
        if not debugTable then
            Log("Debug entity table '%s' not found!", tableName)
            return
        end
        
        for i=1, #debugTable do
            if not debugTable[i] then return end
            
            PrintEntityFieldData(debugTable[i], fieldName)
            Server.SendNetworkMessage("DebugPrintEntityField",
            {
                entityId = debugTable[i]:GetId(),
                fieldName = fieldName,
            }, true)
            Server.SendNetworkMessage("DebugPrintEntityFieldP",
            {
                entityId = debugTable[i]:GetId(),
                fieldName = fieldName,
            }, true)
        end
    end
    Event.Hook("Console_debug_print_entity_list", OnDebugPrintEntityList)
end

if Server then
    local function OnDebugGetEntitiesInRange(client, debugTableName, className, range)
        if not client then return end
        local player = client:GetControllingPlayer()
        if not player then return end
        
        range = range and tonumber(range) or 20.0
        local ents = GetEntitiesWithinRange(className, player:GetOrigin(), range)
        SetDebugTable(debugTableName, ents)
    end
    Event.Hook("Console_debug_get_entities_in_range", OnDebugGetEntitiesInRange)
end

-------------------------
-- TRACE VISUALIZATION --
-------------------------

local debugTraceRenderItem
local function GetDebugTraceVisItem()
    
    if not debugTraceRenderItem then
        debugTraceRenderItem = GUI.CreateItem()
        debugTraceRenderItem:SetOptionFlag(GUIItem.ManageRender)
        debugTraceRenderItem:SetLayer(20)
        debugTraceRenderItem:SetIsVisible(true)
    end
    
    return debugTraceRenderItem
    
end

--[[
function Debug_ClearTraceVis()
    
    if not Client then
        return
    end
    
    GetDebugTraceVisItem():ClearLines()
    
end
--]]

function Debug_VisualizeBoxTrace(startPoint, endPoint, extents, fraction)
    
    if not Client then
        return
    end
    
    local visItem = GetDebugTraceVisItem()
    
    local pt0_0 = startPoint + Vector(-extents.x, -extents.y, -extents.z)
    local pt0_1 = startPoint + Vector( extents.x, -extents.y, -extents.z)
    local pt0_2 = startPoint + Vector(-extents.x,  extents.y, -extents.z)
    local pt0_3 = startPoint + Vector( extents.x,  extents.y, -extents.z)
    local pt0_4 = startPoint + Vector(-extents.x, -extents.y,  extents.z)
    local pt0_5 = startPoint + Vector( extents.x, -extents.y,  extents.z)
    local pt0_6 = startPoint + Vector(-extents.x,  extents.y,  extents.z)
    local pt0_7 = startPoint + Vector( extents.x,  extents.y,  extents.z)
    
    local pt1_0 = endPoint + Vector(-extents.x, -extents.y, -extents.z)
    local pt1_1 = endPoint + Vector( extents.x, -extents.y, -extents.z)
    local pt1_2 = endPoint + Vector(-extents.x,  extents.y, -extents.z)
    local pt1_3 = endPoint + Vector( extents.x,  extents.y, -extents.z)
    local pt1_4 = endPoint + Vector(-extents.x, -extents.y,  extents.z)
    local pt1_5 = endPoint + Vector( extents.x, -extents.y,  extents.z)
    local pt1_6 = endPoint + Vector(-extents.x,  extents.y,  extents.z)
    local pt1_7 = endPoint + Vector( extents.x,  extents.y,  extents.z)
    
    local numSteps = 5
    local stepInterp = 1.0 / (numSteps - 1)
    for i=1, numSteps do
        local index = i-1
        local interp = stepInterp * index
        
        -- green = clear, red = obstructed, color intensity fades along trace vector.
        local color = (fraction >= interp) and Color(0,1,0,1) or Color(1,0,0,1)
        color = color * (interp * 0.5 + 0.5)
        color.a = 1.0
        
        local p0 = Client.WorldToScreen(pt0_0 * (1.0 - interp) + pt1_0 * interp)
        local p1 = Client.WorldToScreen(pt0_1 * (1.0 - interp) + pt1_1 * interp)
        local p2 = Client.WorldToScreen(pt0_2 * (1.0 - interp) + pt1_2 * interp)
        local p3 = Client.WorldToScreen(pt0_3 * (1.0 - interp) + pt1_3 * interp)
        local p4 = Client.WorldToScreen(pt0_4 * (1.0 - interp) + pt1_4 * interp)
        local p5 = Client.WorldToScreen(pt0_5 * (1.0 - interp) + pt1_5 * interp)
        local p6 = Client.WorldToScreen(pt0_6 * (1.0 - interp) + pt1_6 * interp)
        local p7 = Client.WorldToScreen(pt0_7 * (1.0 - interp) + pt1_7 * interp)
        
        visItem:AddLine(p0, p1, color)
        visItem:AddLine(p1, p3, color)
        visItem:AddLine(p3, p2, color)
        visItem:AddLine(p2, p0, color)
        visItem:AddLine(p4, p5, color)
        visItem:AddLine(p5, p7, color)
        visItem:AddLine(p7, p6, color)
        visItem:AddLine(p6, p4, color)
        visItem:AddLine(p0, p4, color)
        visItem:AddLine(p1, p5, color)
        visItem:AddLine(p2, p6, color)
        visItem:AddLine(p3, p7, color)
    end
    
end

local traces = {}
function Debug_VisualizeTrace(startPoint, endPoint, color, fraction, lifetime)
    
    if not Client then
        return
    end
    
    local newTraceViz = {}
    if type(lifetime) == "number" and lifetime >= 0 then
        newTraceViz.deathTime = Shared.GetTime() + lifeTime
    end
    newTraceViz.startPoint = startPoint
    newTraceViz.endPoint = endPoint
    newTraceViz.color = color
    newTraceViz.fraction = fraction
    
    traces[#traces+1] = newTraceViz
    
end

local function DrawTraceViz(traceViz)
    
    local visItem = GetDebugTraceVisItem()
    
    traceViz.fraction = traceViz.fraction or 1
    
    local pt0 = Client.WorldToScreen(traceViz.startPoint)
    local pt1 = Client.WorldToScreen(traceViz.startPoint * (1.0 - traceViz.fraction) + traceViz.endPoint * traceViz.fraction)
    local pt2 = Client.WorldToScreen(traceViz.endPoint)
    
    traceViz.color = traceViz.color or Color(1,1,1,1)
    local color2 = traceViz.color * 0.333
    color2.a = 1.0
    
    visItem:AddLine(pt0, pt1, traceViz.color)
    visItem:AddLine(pt1, pt2, color2)
    
    -- small x at start
    visItem:AddLine(pt0 - Vector(3,3,0), pt0 + Vector(3,3,0), traceViz.color)
    visItem:AddLine(pt0 - Vector(-3,3,0), pt0 + Vector(-3,3,0), traceViz.color)
    
    -- small x at fractionPoint
    visItem:AddLine(pt1 - Vector(2,2,0), pt1 + Vector(2,2,0), color2)
    visItem:AddLine(pt1 - Vector(-2,2,0), pt1 + Vector(-2,2,0), color2)
    
end

local function DrawCapsule(visItem, origin, radius, height, color)
    
    local numSteps = 16
    local stepSize = (math.pi * 2) / numSteps
    if height == 0 then
        -- draw sphere
        for i=0, numSteps-1 do
            local theta0 = stepSize * i
            local theta1 = stepSize * ((i+1) % numSteps)
            
            local wsPos0_0 = origin + Vector(math.cos(theta0) * radius, math.sin(theta0) * radius, 0)
            local wsPos0_1 = origin + Vector(math.cos(theta1) * radius, math.sin(theta1) * radius, 0)
            local wsPos1_0 = origin + Vector(math.cos(theta0) * radius, 0, math.sin(theta0) * radius)
            local wsPos1_1 = origin + Vector(math.cos(theta1) * radius, 0, math.sin(theta1) * radius)
            local wsPos2_0 = origin + Vector(0, math.cos(theta0) * radius, math.sin(theta0) * radius)
            local wsPos2_1 = origin + Vector(0, math.cos(theta1) * radius, math.sin(theta1) * radius)
            
            local ssPos0_0 = Client.WorldToScreen(wsPos0_0)
            local ssPos0_1 = Client.WorldToScreen(wsPos0_1)
            local ssPos1_0 = Client.WorldToScreen(wsPos1_0)
            local ssPos1_1 = Client.WorldToScreen(wsPos1_1)
            local ssPos2_0 = Client.WorldToScreen(wsPos2_0)
            local ssPos2_1 = Client.WorldToScreen(wsPos2_1)
            
            visItem:AddLine(ssPos0_0, ssPos0_1, color)
            visItem:AddLine(ssPos1_0, ssPos1_1, color)
            visItem:AddLine(ssPos2_0, ssPos2_1, color)
        end
    else
        local offset = height * 0.5
        -- draw capsule contours (tall sides)
        for i=0, floor(numSteps/2) - 1 do
            local theta0 = stepSize * i
            local theta1 = stepSize * (i + 1)
            
            -- top of capsule
            local wsPos0_0 = origin + Vector(math.cos(theta0) * radius, math.sin(theta0) * radius, 0) + Vector(0, offset, 0)
            local wsPos0_1 = origin + Vector(math.cos(theta1) * radius, math.sin(theta1) * radius, 0) + Vector(0, offset, 0)
            local wsPos1_0 = origin + Vector(0, math.sin(theta0) * radius, math.cos(theta0) * radius) + Vector(0, offset, 0)
            local wsPos1_1 = origin + Vector(0, math.sin(theta1) * radius, math.cos(theta1) * radius) + Vector(0, offset, 0)
            
            local ssPos0_0 = Client.WorldToScreen(wsPos0_0)
            local ssPos0_1 = Client.WorldToScreen(wsPos0_1)
            local ssPos1_0 = Client.WorldToScreen(wsPos1_0)
            local ssPos1_1 = Client.WorldToScreen(wsPos1_1)
            
            -- bottom of capsule
            local wsPos2_0 = origin + Vector(math.cos(theta0) * radius, -math.sin(theta0) * radius, 0) + Vector(0, -offset, 0)
            local wsPos2_1 = origin + Vector(math.cos(theta1) * radius, -math.sin(theta1) * radius, 0) + Vector(0, -offset, 0)
            local wsPos3_0 = origin + Vector(0, -math.sin(theta0) * radius, math.cos(theta0) * radius) + Vector(0, -offset, 0)
            local wsPos3_1 = origin + Vector(0, -math.sin(theta1) * radius, math.cos(theta1) * radius) + Vector(0, -offset, 0)
            
            local ssPos2_0 = Client.WorldToScreen(wsPos2_0)
            local ssPos2_1 = Client.WorldToScreen(wsPos2_1)
            local ssPos3_0 = Client.WorldToScreen(wsPos3_0)
            local ssPos3_1 = Client.WorldToScreen(wsPos3_1)
            
            visItem:AddLine(ssPos0_0, ssPos0_1, color)
            visItem:AddLine(ssPos1_0, ssPos1_1, color)
            visItem:AddLine(ssPos2_0, ssPos2_1, color)
            visItem:AddLine(ssPos3_0, ssPos3_1, color)
        end
        
        -- draw long sides of capsule
        local ssSidePos0_0 = Client.WorldToScreen(origin + Vector(radius, -offset, radius))
        local ssSidePos0_1 = Client.WorldToScreen(origin + Vector(radius, offset, radius))
        local ssSidePos1_0 = Client.WorldToScreen(origin + Vector(-radius, -offset, radius))
        local ssSidePos1_1 = Client.WorldToScreen(origin + Vector(-radius, offset, radius))
        local ssSidePos2_0 = Client.WorldToScreen(origin + Vector(-radius, -offset, -radius))
        local ssSidePos2_1 = Client.WorldToScreen(origin + Vector(-radius, offset, -radius))
        local ssSidePos3_0 = Client.WorldToScreen(origin + Vector(radius, -offset, -radius))
        local ssSidePos3_1 = Client.WorldToScreen(origin + Vector(radius, offset, -radius))
        
        visItem:AddLine(ssSidePos0_0, ssSidePos0_1, color)
        visItem:AddLine(ssSidePos1_0, ssSidePos1_1, color)
        visItem:AddLine(ssSidePos2_0, ssSidePos2_1, color)
        visItem:AddLine(ssSidePos3_0, ssSidePos3_1, color)
        
        -- draw capsule rings (circles in the xz plane)
        for i=0, numSteps-1 do
            local theta0 = stepSize * i
            local theta1 = stepSize * ((i+1)%numSteps)
            
            local wsPos0_0 = origin + Vector(math.cos(theta0) * radius, -offset, math.sin(theta0) * radius)
            local wsPos0_1 = origin + Vector(math.cos(theta1) * radius, -offset, math.sin(theta1) * radius)
            local wsPos1_0 = origin + Vector(math.cos(theta0) * radius, offset, math.sin(theta0) * radius)
            local wsPos1_1 = origin + Vector(math.cos(theta1) * radius, offset, math.sin(theta1) * radius)
            
            local ssPos0_0 = Client.WorldToScreen(wsPos0_0)
            local ssPos0_1 = Client.WorldToScreen(wsPos0_1)
            local ssPos1_0 = Client.WorldToScreen(wsPos1_0)
            local ssPos1_1 = Client.WorldToScreen(wsPos1_1)
            
            visItem:AddLine(ssPos0_0, ssPos0_1, color)
            visItem:AddLine(ssPos1_0, ssPos1_1, color)
        end
        
    end
    
end

function Debug_VisualizeCapsuleTrace(startPoint, endPoint, radius, height, fraction)
    
    if not Client then
        return
    end
    
    local visItem = GetDebugTraceVisItem()
    
    fraction = fraction or 1
    
    local numSteps = 5
    for i=0, numSteps do
        local color = Color(0,1,0,1)
        if (i/numSteps) > fraction then
            color = Color(1,0,0,1)
        end
        local interp = i/numSteps
        local pt = startPoint * (1-interp) + endPoint * interp
        DrawCapsule(visItem, pt, radius, height, color)
    end
    
end

local function DoVisualizations(vizTable, func)
    local t = Shared.GetTime()
    for i=#vizTable, 1, -1 do
        if vizTable[i].deathTime and vizTable[i].deathTime < t then
            table.remove(vizTable, i)
        else
            func(vizTable[i])
        end
    end
end

Event.Hook("UpdateRender",
function()
    GetDebugTraceVisItem():ClearLines()
    DoVisualizations(traces, DrawTraceViz)
end)

function DebugTraceLog(formatString, ...)
    local debuginfo = debug.getinfo(2, "nSlu")
    local functionName = debuginfo.name
    local fileName = debuginfo.short_src
    local lineNumber = debuginfo.currentline
    HPrint(string.format("%s:%s.%s | %s", fileName, functionName, lineNumber, formatString), ...)
    
end
