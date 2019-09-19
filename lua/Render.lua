--
-- Syncrhonizes the render settings on the camera with the stored render options
--
function Render_SyncRenderOptions()

    local ambientOcclusion  = Client.GetOptionString("graphics/display/ambient-occlusion", "off")
    local atmospherics      = Client.GetOptionBoolean(kAtmosphericsOptionsKey, true)
    local atmoQuality       = Client.GetOptionString("graphics/atmospheric-quality", "low")
    local bloom             = Client.GetOptionBoolean("graphics/display/bloom_new", false)
    local shadows           = Client.GetOptionBoolean("graphics/display/shadows", true)
    local antiAliasing      = Client.GetOptionString(kAntiAliasingOptionsKey, "off")
    local fog               = Client.GetOptionBoolean("graphics/display/fog", false)
    local particleQuality   = Client.GetOptionString("graphics/display/particles", "low")
    local reflections       = Client.GetOptionBoolean("graphics/reflections", false)
    local refractionQuality = Client.GetOptionString("graphics/refractionQuality", "high")
    local gammaAdjustment   = Clamp(Client.GetOptionFloat("graphics/display/gamma", Client.DefaultRenderGammaAdjustment), Client.MinRenderGamma , Client.MaxRenderGamma)

    Client.SetRenderSetting("mode", "lit")
    Client.SetRenderSetting("ambient_occlusion", ambientOcclusion)
    Client.SetRenderSetting("atmospherics", ToString(atmospherics))
    Client.SetRenderSetting("atmosphericsQuality", atmoQuality)
    Client.SetRenderSetting("bloom"  , ToString(bloom))
    Client.SetRenderSetting("shadows", ToString(shadows))
    Client.SetRenderSetting("anti_aliasing", ToString(antiAliasing))
    Client.SetRenderSetting("fog", ToString(fog))
    Client.SetRenderSetting("particles", particleQuality)
    Client.SetRenderSetting("reflections", ToString(reflections))
    Client.SetRenderSetting("refractionQuality", refractionQuality)
    Client.SetRenderGammaAdjustment(gammaAdjustment)

end

local function RenderConsoleHandler(name, key)
    return function (enabled)
        if enabled == nil then
            enabled = "true"
        end
        Client.SetRenderSetting(name, ToString(enabled))
        Client.SetOptionBoolean(key, enabled == "true")
    end
end

local function RenderConsoleIntegerHandler(name, key)
    return function (int)
        if int == nil then
            int = 50
        end
        Client.SetRenderSetting(key, tonumber(int))
        Client.SetOptionInteger(key, tonumber(int))
        Render_SyncRenderOptions()
    end
end

local function RenderConsoleGammaHandler()

end

local function OnConsoleRenderMode(mode)
    if Shared.GetCheatsEnabled() or Shared.GetTestsEnabled() then
        if mode == nil then
            mode = "lit"
        end
        Client.SetRenderSetting("mode", mode)
    end
end

Client.ClearTextureLoadRules()
Client.AddTextureLoadRule("ui/*.*", -100)   -- Don't reduce resolution on UI textures
Client.AddTextureLoadRule("fonts/*.*", -100) -- Don't reduce resolution of font textures

Event.Hook("Console_r_mode",            OnConsoleRenderMode )
Event.Hook("Console_r_shadows",         RenderConsoleHandler("shadows", "graphics/display/shadows") )
Event.Hook("Console_r_ao",              RenderConsoleHandler("ambient_occlusion", "graphics/display/ambient-occlusion") )
Event.Hook("Console_r_atmospherics",    RenderConsoleHandler("atmospherics", "graphics/display/atmospherics") )
Event.Hook("Console_r_bloom",           RenderConsoleHandler("bloom", "graphics/display/bloom_new") )
Event.Hook("Console_r_fog",             RenderConsoleHandler("fog", "graphics/display/fog") )
Event.Hook("Console_r_glass",           RenderConsoleHandler("glass", "graphics/display/glass") )

Event.Hook("Console_r_aa",
    function(arg)
        if arg == nil then
            arg = "off"
        end
        Client.SetOptionString(kAntiAliasingOptionsKey, arg)
        Client.SetRenderSetting("anti_aliasing", arg)
        Render_SyncRenderOptions()
    end)

Event.Hook("Console_r_gamma",              
    function (arg)
        if arg == nil then
            arg = Client.DefaultGammaAdjustment
        end

        local num = Clamp(tonumber(arg), Client.MinRenderGamma, Client.MaxRenderGamma)

        Shared.Message(string.format("Gamma changed to %.1f", num))

        Client.SetOptionFloat("graphics/display/gamma", num)
        Client.SetRenderGammaAdjustment(num)
        Render_SyncRenderOptions()
    end )

Event.Hook("Console_r_pq",
    function(arg)
        if arg == "high" then
            Client.SetRenderSetting("particles", "high")
            Client.SetOptionString("graphics/display/particles", "high")
        else
            Client.SetRenderSetting("particles", "low")
            Client.SetOptionString("graphics/display/particles", "low")
        end
    end )

-- DEBUB
Event.Hook("Console_exclude_rect_enable", function(state)
    
    if state == nil then
        Log("usage: exclude_rect_enable (true|1|false|0)")
        return
    end
    
    state = (state == "true" or state == "1")
    Client.SetMainCameraExclusionRectEnabled(state)
    Log("%s the main camera exclusion rectangle.", state and "Enabled" or "Disabled")
    
end)

-- DEBUB
Event.Hook("Console_exclude_rect", function(x0, y0, x1, y1)
    
    x0 = tonumber(x0)
    y0 = tonumber(y0)
    x1 = tonumber(x1)
    y1 = tonumber(y1)
    
    if x0 == nil or y0 == nil or x1 == nil or y1 == nil then
        Log("usage: exclude_rect x0, y0, x1, y1")
        return
    end
    
    Client.SetMainCameraExclusionRect(x0, y0, x1, y1)
    Log("Setting the main camera exclusion rectangle to (%s, %s), (%s, %s)", x0, y0, x1, y1)
    
end)
