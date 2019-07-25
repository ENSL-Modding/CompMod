local ok, jit = pcall(require, "jit")
local hastracelogger, tracelogger = pcall(require, "tracelogger")

TraceTracker = TraceTracker or {
  LogCompiledTraces = false,
  PrintOnError = true,
  DefferedJitOff = false,
}

if not ok then
  function TraceTracker:UpdateStats()
  end
  function TraceTracker:Start()
    error("error TraceTracker cannot run because the jit libary could not be loaded")
  end

  return
end

table.insert(package.loaders, function(name)
    name = string.gsub(name, "%.", "/")
    local path = "lua/" .. name ..".lua"
    local sucess, ret, msg = pcall(loadfile, path)
    if sucess and not msg then
      return ret
    end
end)

  
local bc = require("jit.bc")
vmdef = vmdef or require("jit.vmdef")
local jit_util = require("jit.util")
local traceinfo, traceir, tracek = jit_util.traceinfo, jit_util.traceir, jit_util.tracek
local tracemc, tracesnap = jit_util.tracemc, jit_util.tracesnap

local funcline = jit_util.funcline

if not funcline then
  funcline = function(func, pc)
    return jit_util.funcinfo(func, pc).currentline
  end
end

-- Utilities -------------------------------------------------------------------

-- Stolen from dump.lua
local function fmtfunc(func, pc)
  local fi = jit_util.funcinfo(func, pc)
  if fi.loc then
    return fi.loc
  elseif fi.ffid then
    return vmdef.ffnames[fi.ffid] or fi.name
  elseif fi.addr then
    return ("C:%x"):format(fi.addr)
  else
    return "(?)"
  end
end


-- Format trace error message.  Stolen from dump.lua
local function fmterr(err, info)
  if type(err) == "number" then
    if type(info) == "function" then info = fmtfunc(info) end
    if(not vmdef.traceerr[err]) then
      print(tostring(err))
    end
    err = vmdef.traceerr[err]:format(info)
  end
  return err
end


-- Tracing ---------------------------------------------------------------------

local FunctionList = {}
local FunctionLookup = {}
local FunctionInfo = {}
local traces = {}

local trace_callbacks = {}
local funckey = jit_util.funckey or function(f) return f end

local function GetFunctionIndex(func)

  local index = FunctionLookup[funckey(func)]
  
  if(not index) then
    index = #FunctionList+1
    
    local info = jit_util.funcinfo(func)
    info.functionIndex = index
    
    local key = funckey(func)
    info.key = key
    info.func = func
    
    FunctionInfo[index] = info
    FunctionList[index] = func
    FunctionLookup[key] = index
  end
  
  return index
end

local function GetFunctionInfo(func)
  return FunctionInfo[FunctionLookup[funckey(func)] or GetFunctionIndex(func)]
end

function TraceTracker:Startup(disableLineLogging)
  self:Reset()
  
  local sideCount = 0
  
  for i=1,0xffff do 
    local info = jit_util.traceinfo(i)

    if info then
    
      self.TraceCount = self.TraceCount + 1
      self.MaxTraceId = i
      
      local m, ot, parent, exitno, prev = jit_util.traceir(i, 0)
      
      local t = {
        number = i, 
        parent = parent ~= 0 and parent,
        childcount = 0,
      }

      if parent ~= 0 then
        sideCount = sideCount+ 1
        t.parent = parent
        t.exitnumber = exitno
        parent = self.Traces[parent]
        parent.childcount = parent.childcount + 1
      end
      
      self.Traces[i] = t
    end
  end
  
  self:Log("TraceTracker_Startup: Found %i existing traces. side: %s ", self.TraceCount, sideCount)
  
  self:SetLoggingEnabled(true)
  
  if(not disableLineLogging) then
    self:SetBytecodeLoggingEnabled(1)
  end
  
  //TraceTracker:AddCallback("@lua/GUIManager.lua", 0, 900, function(trace, event) 
  //  
  //  RawPrint(event..":"..trace[event.."_line"]..SourceMap:GetLineForChunk(trace[event].source, trace[event.."_line"])..TraceTracker:GetTraceLabel(trace)) 
  //end)
end


function TraceTracker:Shutdown()
  self:SetLoggingEnabled(false)
  self:Reset()
end

function TraceTracker:Reset()
  
  FunctionList = {}
  FunctionLookup = {}
  FunctionInfo = {}
  traces = {}

  self.Traces = {}

  self.FunctionList = FunctionInfo
  self.UniqueFunctionCount = 0

  self.AllTraces = {}
  self.LatestTraces = {}

  self.TraceCount = 0
  self.MaxTraceId = 0
  self.PrintStartId = 1

  self.AbortedTraceCount = 0
  self.AbortCodeCounts = {}
  
  self.RootTraceCount = 0 
  self.FailedSideTraces = 0
  self.FailedLoopTraces = 0
  
  self.TotalAttemptedTraces = 0
  self.TotalSideTraces = 0
  self.TotalLoopTraces = 0
  self.TotalSucessful = 0
  
  self.StartingFunctions = {}
  self.StartingProtoCount = 0
  
  self.JITBreakpointsSet = {}
  
  if(ClearJITBreakpoints) then
    ClearJITBreakpoints()
  end
end

function TraceTracker:FlushStep()
  
  --Flush the first trace with no side traces
  for i = self.MaxTraceId, 1,-1 do 
    local t = self.Traces[i]
    
    if t and t.childcount == 0 then
      self:FlushTrace(t.number)
      return true
    end
  end
  
  self:Log("FlushStep: Falling back to flushing highest trace id")
  
  for i = self.MaxTraceId, 1,-1 do 
    local t = self.Traces[i]
    
    if t then
      self:FlushTrace(t.number)
      return true
    end
  end
  
  return false
end

function TraceTracker:TraceStep(batch)
  
  if(not self.TraceStepActive) then
    self.TraceStepActive = true
    
    self.TraceStepCount = 0
    self.TraceStepBatch = batch or 50
    self.SteppedTraces = {}

    Print("TraceStep Activated")
  else
    if(self.TraceStepCount) then
      self.TraceStepCount = 0
      self.FlushStepIndex = nil
      self.SteppedTraces = {}
    end
  end
  
  self:EnableJIT()
end

function TraceTracker:DisableTraceStep()
  
  Print("TraceStep Disabled")
 
  self.TraceStepActive = false
  self.TraceStepCount = nil
  self:EnableJIT()
end

function TraceTracker:UpdateFunctionStats()
  
  if(#FunctionList == self.UniqueFunctionCount) then
    return
  end
  
  for i=self.UniqueFunctionCount+1,#FunctionList do
    
    local func = FunctionList[i]
    
  end
  
end

function TraceTracker:UpdateStats()

  local startingFunctions

  for i,trace in ipairs(self.LatestTraces) do
        
    if(trace.abort) then
      self.AbortedTraceCount = self.AbortedTraceCount+1  
      
      self.AbortCodeCounts[trace.abort_code] = (self.AbortCodeCounts[trace.abort.code] or 0) + 1
      
      if(trace.parent) then
        self.FailedSideTraces = self.FailedSideTraces+1
      elseif(trace.start_pc ~= 0) then
        self.FailedLoopTraces = self.FailedLoopTraces+1
      end
    else
      self.TotalSucessful = self.TotalSucessful + 1
    end

    if(trace.parent) then
      self.TotalSideTraces = self.TotalSideTraces+1
      
      local parent = self.Traces[trace.parent]

      if(parent) then
        trace.root = parent.root or parent.number
        trace.loop = parent.loop
      end
    else
      if(trace.start_pc ~= 0) then
        self.TotalLoopTraces = self.TotalLoopTraces+1
        trace.loop = true
      end
      
      if(not self.StartingFunctions[trace.start.key]) then
        self.StartingFunctions[trace.start.key] = trace.start.functionIndex
        self.StartingProtoCount = self.StartingProtoCount+1
      end
    end
    
    if(self.AllTraces) then
      self.AllTraces[#self.AllTraces+1] = trace
    end
    
  end

  self.TraceCount = self.TraceCount + #self.LatestTraces
  self.LatestTraces = {}
  self.UniqueFunctionCount = #FunctionList
  
  return true
end


function TraceTracker:TraceExists(traceNum)
  return self.Traces[traceNum] ~= nil
end

function TraceTracker:FlushTrace(traceid)
  assert(traceid, "FlushTrace: Expected a trace id")
  local trace = self.Traces[traceid]
  
  if not trace then
    self:Log("FlushTrace: trace #%i does not exist", trace.number)
    return false
  end
  
  local parent = trace.parent and self.Traces[trace.parent]
  
  if parent then
    parent.childcount = parent.childcount-1
  end
  
  self:Log("FlushTrace: Flushing %s trace #%i", (trace.parent and "side" or "root"),  trace.number)
  
  local childTraces = self:GetDescendantTraces(trace)

  jit.flush(trace.number)
  self:OnTraceDestroyed(trace.number)
  
  for i,traceEntry in ipairs(childTraces) do
    self:OnTraceDestroyed(traceEntry.number)
    self:Log("Flushed child trace #%i", traceEntry.number)
  end
  
  return true
end

function TraceTracker:FlushParentRootTrace(trace)
  
  if(type(trace) == "number") then
    trace = self.Traces[trace]
    assert(trace)
  end
  
  local startingTrace = trace
  
  while(trace.parent) do
    trace = self.Traces[trace.parent]
  end
  
  if(trace ~= startingTrace) then
    self:Log("FlushParentRootTrace: Flushing root trace #%i of trace #%i", trace.number, startingTrace.number)
  else
    self:Log("FlushParentRootTrace: Flushing root trace #%i", trace.number)
  end
  
  local childTraces = self:GetDescendantTraces(trace)
  
  for i,traceEntry in ipairs(childTraces) do
    self.Traces[traceEntry.number] = nil
    self:Log("Flushed child trace #%i", traceEntry.number)
  end
  
  jit.flush(trace.number)
end

function TraceTracker:OnTraceDestroyed(traceid)

  self.TraceCount = self.TraceCount - 1
  self.Traces[traceid] = nil
  
  if traceid == self.MaxTraceId then  
    self.MaxTraceId = self.MaxTraceId-1
  else
    if self.Traces[traceid-1] then
      self.MaxTraceId = self.MaxTraceId-1
    else
      -- Fallback incase there are no more traces left
      self.MaxTraceId = 0
      
      for i = traceid, 1,-1 do
        if self.Traces[i] then
          self.MaxTraceId = i
          break
        end
      end
    end
  end
end

function TraceTracker:GetDescendantTraces(trace, traceList)
  
  if traceList ~= false then
    traceList = traceList or {}
  end
  
  local parentId = trace.number
  
  for i=1,self.MaxTraceId do
    local traceEntry = self.Traces[i]
    
    if(traceEntry and traceEntry.parent == parentId) then
      traceList[#traceList+1] = traceEntry
      if traceList ~= false then
        self:GetDescendantTraces(traceEntry, traceList)
      end
    end
  end
  
  return traceList
end

function TraceTracker:GetChildTraces(parentId)

  local traceList = {}

  for i=1,self.MaxTraceId do
    local traceEntry = self.Traces[i]
    
    if(traceEntry and traceEntry.parent == parentId) then
      traceList[#traceList+1] = traceEntry
    end
  end
  
  return traceList
end

local function HookTraceback(err)
  return debug.traceback("Error while in TraceHook: "..err, 2)
end

local function SafeCallHook(func, self, ...)
  --local success, err = pcall(func, self, ...)
  local success, err = xpcall(func, HookTraceback, self, ...)
  if not success then
    Print(err)
  end
end

function TraceTracker:SetLoggingEnabled(enable)

  if(enable and not self.TraceHook) then
    
    self.TraceHook = function(name, ...) 
      SafeCallHook(self[name], self, ...)
    end 
    
    jit.attach(self.TraceHook, "trace")
    self:SetBytecodeLoggingEnabled(1)
    
  elseif(not enable and self.TraceHook) then
    
    //detach the trace hook
    jit.attach(self.TraceHook)   
    self.TraceHook = nil
  end
  
  if(not enable) then
    self:SetBytecodeLoggingEnabled(false)
  end 
end

function TraceTracker:GetLoggingEnabled()
  return self.TraceHook ~= nil
end

function TraceTracker:SetBytecodeLoggingEnabled(enable)
  
  if(enable and not self.BytecodeLogging) then 
   
    if enable == 1 then
      jit.attach(self.record_lastbc, "record")
      self.BytecodeLogging = 1
    else
      jit.attach(self.record_bc, "record")
      self.BytecodeLogging = 2     
    end

  elseif(not enable and self.BytecodeLogging) then   
  
    //detach the trace hook
    jit.attach(self.BytecodeLogging == 1 and self.record_lastbc or self.record_bc)
    self.BytecodeLogging = false
  end
end

function TraceTracker:GetBytecodeLoggingEnabled()
  return self.BytecodeLogging == true
end

function TraceTracker:EnableJIT()
  if not jit.status() then
    self:Log("Enabling JIT")
    jit.on()
  end
  self.DefferedJitOff = false
end

function TraceTracker:DisableJIT(deffered)
  if jit.status() then
    self:Log("Disabling JIT")
    jit.off()
  end
  if deffered then
     self.DefferedJitOff = true
  end
end

local lastfunc, lastpc

function TraceTracker:start(tr, func, pc, parent, exitno)

  if not traces[tr] then 
    traces[tr] = {} 
  end
  
  lastfunc = nil
  lastbc = nil
  local funcInfo = GetFunctionInfo(func)

  local t = {
    number = tr, 
    start = funcInfo,
    start_line = funcline(func, pc),
    start_pc = pc,
    parent = parent,
    exitnumber = exitno,
    childcount = 0,
  }
  
  if self.BytecodeLogging == 2 then
    t.bytecode = {}
  end

  traces[tr][#traces[tr]+1] = t
  
  self.TotalAttemptedTraces = self.TotalAttemptedTraces+1 
  --self.LatestTraces[#self.LatestTraces+1] = t
  
  if(self.Watchers) then
    self:CheckCallbacks(t, "start")
  end

  if self.DefferedJitOff then
    self:Log("Turning off JIT for deffered request")
    jit.off() --Should abort trace
    self.DefferedJitOff = false
  end
end

function TraceTracker.record_lastbc(tr, func, pc, depth)
 //RawPrint("annotate_record pc:%i", pc, (pc < 0 and fmtfunc(func, pc)))

  local info = GetFunctionInfo(func)
  --Only update for Lua functions and not c functions
  if info.source then
    lastfunc = func
    lastpc = pc 
  end
end

function TraceTracker.record_bc(tr, func, pc, depth)
 //RawPrint("annotate_record pc:%i", pc, (pc < 0 and fmtfunc(func, pc)))

  local funcIndex = GetFunctionIndex(func)
  local t = traces[tr][#traces[tr]]
  
  local byteI = #t.bytecode
  local bytecode = t.bytecode
  
  bytecode[byteI+1] = funcIndex
  bytecode[byteI+2] = pc
  bytecode[byteI+3] = depth
  bytecode[byteI+4] = false

  if pc >= 0 and bit.band(jit_util.funcbc(func, pc), 0xff) < 16 then
    bytecode[byteI+5] = funcIndex
    bytecode[byteI+6] = pc
    bytecode[byteI+7] = depth
    bytecode[byteI+8] = true
  end
end

function TraceTracker:stop(tr)
  local t = traces[tr][#traces[tr]]
  t.status = true
  
  if(tr > self.MaxTraceId) then
    self.MaxTraceId = tr
  end
  
  local bytecode = t.bytecode
  local funcIndex, pc
  
  if lastfunc then
    funcIndex = GetFunctionIndex(lastfunc)
    pc = lastpc
  elseif t.bytecode and t.bytecode[1] then
    funcIndex = bytecode[#bytecode-3]
    lastpc = bytecode[#bytecode-2]
  end
  
  if funcIndex then
    local stopFunc = FunctionInfo[funcIndex]
    t.stop = stopFunc
    t.stop_line = funcline(FunctionList[funcIndex], lastpc)
    
    local start = t.start
    
    if(self.Watchers) then
      self:CheckCallbacks(t, "stop")
    end
    
    if(t.SetJITBreakpoint) then
      self:SetJitBreakPoint(t)
    end
    
    if(self.Traces[tr]) then
      Shared.Message(string.format("Compiled Trace #%i GC'ed", tr))
    end

    if(self.LogCompiledTraces) then
      if t.parent then
        self:Log("Trace #%i compiled. Ended at %s:%i side trace of #%i", t.number, stopFunc.source, t.stop_line, t.parent)
      else
        self:Log("Trace #%i compiled. Ended at %s:%i", t.number, stopFunc.source, t.stop_line)
      end
    end
  else
    t.stop = t.start
    t.stop_line = t.start_line
    
    if(self.LogCompiledTraces) then
      self:Log("Trace #%i compiled. Side exit of #%i to intepreter", t.number, t.parent)
    end
  end
  
  self.Traces[tr] = t
  
  local parent = t.parent and self.Traces[t.parent]
  
  if parent then
    parent.childcount = parent.childcount + 1
  end
  
  if(self.TraceStepCount) then
    self.SteppedTraces[#self.SteppedTraces+1] = t
    self.TraceStepCount = self.TraceStepCount+1
  end
  
  if(self.TraceStepActive and (not self.TraceStepCount or self.TraceStepCount > self.TraceStepBatch)) then
    self:Log("TraceStep limit hit turning off JIT")
    self:DisableJIT()
  end
  
  if(t.autodump or self.AutoDumpTraces) then
    self:DumpTrace(t, self:GetAutoDumpStream())
  end
end

function TraceTracker:PrintTrace(t)

  if t.stop.source then
    if t.parent then
      self:Log("Trace #%i compiled. Ended at %s:%i side trace of #%i", t.number, t.stop.source, t.stop_line, t.parent)
    else
      self:Log("Trace #%i compiled. Ended at %s:%i", t.number, t.stop.source, t.stop_line)
    end
  else
    t.stop = t.start
    t.stop_line = t.start_line
    
    self:Log("Trace #%i compiled. Side exit of #%i to intepreter", t.number, t.parent or -1)
  end
end

function TraceTracker:PrintTraceList(startId, endId)

  self:Log("PrintTraceList")

  startId = startId or 1
  endId = endId or self.MaxTraceId

  for i=startId,endId do
     local t = self.Traces[i]
  
     if t then
        TraceTracker:PrintTrace(t)
     end
  end
end

function TraceTracker:abort(tr, func, pc, code, reason)
  
  local t = traces[tr][#traces[tr]]
  
  local reason = fmterr(code, reason)
--[[
  reason = reason:gsub("bytecode (%d+)", function(c)
    c = tonumber(c) * 6
    return "bytecode "..vmdef.bcnames:sub(c, c+6):gsub(" ", "")
  end)
]]
  t.abort = GetFunctionInfo(func) 
  t.abort_code = code
  t.abort_reason = reason
 
  t.stop_line = funcline(func, pc)
  t.stop = t.abort
  
  if(t.autodump or self.AutoDumpTraces) then
    self:DumpTrace(t, self:GetAutoDumpStream())
  end
end

function TraceTracker:flush()
  TraceTracker:Reset()
  self:Log("TraceTracker: All traces flushed")
end

function TraceTracker:GetTraceLabel(tr)
  
  if(tr.parent) then
    return ("Trace #%d(Parent #%d Parent Exit %d)"):format(tr.number, tr.parent, tr.exitnumber or -1)
  else
    return ("Trace #%d"):format(tr.number)
  end
end

local function CallbackSorter(c1, c2)
  return c1.Start < c2.Start
end

function TraceTracker:AddCallback(chunk, startLine, endLine, callback)
  
  if(not self.Watchers) then
    self.Watchers = {}
  end
  
  local chunkRanges = self.Watchers[chunk]
  
  if(not ChunkRanges) then
    chunkRanges = {}
    self.Watchers[chunk] = chunkRanges
  end
  
  chunkRanges[#chunkRanges+1] = {
    Start = startLine,
    End = endLine,
    Callback = callback
  }
  
  table.sort(chunkRanges, CallbackSorter)
end

function TraceTracker:CheckCallbacks(t, event)

  local RangeList
  
  local funcInfo
  
  if(event == "start") then
    funcInfo = t.start
  elseif(event == "stop") then
    funcInfo = t.start
  end
  
  RangeList = self.Watchers[funcInfo.source]

  if(not RangeList) then
    return
  end
  
  RawPrint("HasChunkList "..funcInfo.source)
  
  local startLine = funcInfo.linedefined
  
  for i,range in ipairs(RangeList) do  
    RawPrint("Pos %i Start %i, End %i", startLine, range.Start, range.End)
    
    if(range.Start > startLine) then
      break
    end
    
    if(startLine < range.End) then
      range.Callback(t, event, funcInfo)
    end
  end
end

function TraceTracker:SetJitBreakPoint(t)

  RawPrint("SetJitBreakPoint %i", t.number)

  if(self.JITBreakpointsSet[t]) then
    RawPrint("Skipping setting duplicate breakpoint")
   return
  end

  local mcode, addr, loop = jit_util.tracemc(t.number)

  SetTraceJITBreakpoint(addr, self:GetTraceLabel(t))
  self.JITBreakpointsSet[t] = true
end

function TraceTracker:DumpSteppedTrace(path)

  if(not self.SteppedTraces or #self.SteppedTraces == 0) then
    self:Log("Error there are no step traces recorded yet")
  end

  path = (path or "config://").."SteppedTraces.txt"

  local file = assert(io.open(path, "w"))
  
  annotate_report(file, self.SteppedTraces, true)
end

function TraceTracker:Log(fmt, ...)
  
  if(fmt and type(fmt) == "string" and select("#", ...) ~= 0) then
    Print(string.format(fmt, ...))
  else
    Print(fmt, ...)
  end
end

function TraceTracker:EnableAutoDumping(autoDumpFile) 
  self.AutoDumpTraces = true
  
  if(autoDumpFile) then
    self.AutoDumpPath = autoDumpFile
  end
end

function TraceTracker:GetAutoDumpStream()
  
  if(self.AutoDumpStream) then
    return self.AutoDumpStream
  end
  
  local path = assert(self.DumpFilePath or self.AutoDumpPath)

  self.AutoDumpStream = assert(io_n.open(path, "w"))
  
  return self.AutoDumpStream
end

local errorCount = 0
local lastError

local seenErrors = {}

Event.Hook("ErrorCallback", function(error) 
  --Print("ErrorCallback - start")
  local newError = not seenErrors[error]
  local repeatingError = error == lastError
  lastError = error
  seenErrors[error] = (seenErrors[error] or 0) + 1

  if newError and tracelogger.isrunning() then
    tracelogger:save()
  end

  if TraceTracker:GetLoggingEnabled() then
    if TraceTracker.PrintOnError then
      TraceTracker:PrintTraceList(TraceTracker.PrintStartId)
      TraceTracker.PrintStartId = TraceTracker.MaxTraceId
    end
    -- jit.status() will aways say off in a error handler 
    TraceTracker:DisableJIT(true)
    --Flush a single trace every error until the error stops
    if errorCount > 0 then
      TraceTracker:FlushStep()
    end
  end

  errorCount = errorCount + 1 
  --Print("ErrorCallback - end")
end)

--Event.Hook("UpdateServer", OnUpdateServer)