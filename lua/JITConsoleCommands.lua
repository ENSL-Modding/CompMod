Script.Load("lua/TraceTracker.lua")

local jit = require("jit")

local jitParams = {

    maxtrace = true,
    maxrecord = true,
    maxirconst = true,
    maxside = true,
    maxsnap = true,
    
    hotloop = true,
    hotexit = true,
    tryside = true,
    
    instunroll = true,
    loopunroll = true,
    callunroll = true,
    recunroll = true,
    tailunroll = true,

    sizemcode = true,
    maxmcode = true,  
}

local function ProcessCommand(cmd, arg)
    
    if(not jit) then
        Print("jit: Error cant use jit console commands because LuaJIT is not loaded")
        return
    end
    
    cmd = cmd or "status"
    
    if(cmd == "flush") then
        
        jit.flush()
        Print("jit: machine code flushed")
        
    elseif(cmd == "on") then
        
        TraceTracker:EnableJIT()
        Print("jit: JIT is now enabled")
        
    elseif(cmd == "fo") then
        
        jit.flush()
        jit.off()
        Print("jit: machine code flushed and jit turned off")
        
    elseif(cmd == "off") then
        
        jit.off()
        Print("jit: JIT is now disabled")
        
    elseif(cmd == "status") then
        
        Print("JIT Status: "..((jit.status() and "On") or "Off"))
        
    elseif(jitParams[cmd]) then
        
        if(not arg or arg == "") then
            Print("jit: Error a value needs to be specifed to set a jit paramamter "..cmd)
            return
        end
        
        jit.opt.start(cmd.."="..arg)
        Print("jit: jit parameter %s set to %s", cmd, arg)
        
    else

        Print("jit: Unknown command "..cmd)
    end
end

local success, tracelogger = pcall(require, "tracelogger")

Event.Hook("Console_tt", function(...) 

    local client, cmd, arg
    
    if Server then
        client, cmd, arg = ...
        if client ~= nil and not Shared.GetCheatsEnabled() then
            return
        end
    else
        cmd, arg = ...
    end
    
    if(not cmd) then
        Print("TraceTracker is " .. (TraceTracker:GetLoggingEnabled() and "running" or "stopped"))
    elseif(cmd == "log" or cmd == "on" or cmd == "1") then

        if cmd == "log" then
            tracelogger.start()
        end
      
        TraceTracker:Startup()
        Print("TraceTracker started.")
    elseif(cmd == "off" or cmd == "0") then
        TraceTracker:Shutdown()
        Print("TraceTracker stopped.")
    elseif(cmd == "print") then
        TraceTracker.LogCompiledTraces = not TraceTracker.LogCompiledTraces
        Print("TraceTracker trace printing ".. ((TraceTracker.LogCompiledTraces and "enabled") or "disabled"))
    end
end)

if(Client) then

    Event.Hook("Console_cjit", function(cmd, arg) 
        ProcessCommand(cmd, arg)
    end)
    
    Event.Hook("Console_tracestep", function(arg1, arg2) 
      
      if(not TraceTracker or not TraceTracker.TraceStep) then
        return
      end
      
      local cmd = (type(arg1) == "string" and arg1) or arg2
      
      if(not cmd or tonumber(arg1)) then
        TraceTracker:TraceStep(tonumber(arg1) or 50)
      elseif(cmd == "off") then
        TraceTracker:DisableTraceStep()
      elseif(cmd == "dump") then
        --TraceTracker:DumpSteppedTrace()
      end
    end)

    Event.Hook("Console_flushstep", function(arg1, arg2)
      if(not TraceTracker) then
        return
      end
      
      if jit.status() then
        jit.off()
        Print("FlushStep: Turning off jit for first step.")
        return
      end
      
      TraceTracker:FlushStep()
    end)

    function CheckTraceNum(...)
      
      local arg1, arg2 = ...
      
      local cmd = (type(arg1) == "string" and arg1) or arg2
      
      local sucess, value = pcall(tonumber, cmd)
      
      if(not sucess or not value) then
        Shared.Message("usage flushtrace TraceNumber")
        return nil
      end
      
      if(not TraceTracker:TraceExists(value)) then
        Print("Trace "..value.."does not exist")
        return nil
      end
      
      return value
    end

    Event.Hook("Console_flushtrace", function(...) 
      
      if(not TraceTracker) then
        return
      end
      
      TraceTracker:FlushTrace(CheckTraceNum(...))
    end)
    
else
    
    Event.Hook("Console_sjit", function(client, cmd, arg, arg2) 
    
        if(client == nil or Shared.GetCheatsEnabled()) then
           ProcessCommand(cmd, arg) 
        end
    end)
end
