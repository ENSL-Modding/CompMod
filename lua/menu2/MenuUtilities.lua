-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/MenuUtilities.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Common functions.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local function StopSoundFunction(soundFile)
    Shared.StopSound(nil, soundFile)
end

local precachedMenuSounds = {}
function PlayMenuSound(soundType)
    
    local soundFile = MenuSounds[soundType]
    if not soundFile then
        Log("WARNING!  Attempted to play undefined menu sound '%s'!  It should be defined in menu2/MenuStyles.lua.", soundType)
        return
    end
    
    if not precachedMenuSounds[soundFile] then
        Log("WARNING!  Attempted to play menu sound '%s', which wasn't precached!  It won't be audible!", soundFile)
        return
    end
    
    GetGUIDeferredUniqueCallbackManager():EnqueueDeferredUniqueCallback(
    {
        param = soundFile,
        callbackFunction = StartSoundEffect,
    })
    
end

function StopMenuSound(soundType)
    
    local soundFile = MenuSounds[soundType]
    if not soundFile then
        Log("WARNING!  Attempted to stop undefined menu sound '%s'!  It should be defined in menu2/MenuStyles.lua.", soundType)
        return
    end
    
    GetGUIDeferredUniqueCallbackManager():EnqueueDeferredUniqueCallback(
    {
        param = soundFile,
        callbackFunction = StopSoundFunction,
    })
    
end

function PrecacheMenuSounds()
    for _, menuSound in pairs(MenuSounds) do
        Client.PrecacheLocalSound(menuSound)
        precachedMenuSounds[menuSound] = true
    end
end

local kFlashShader = PrecacheAsset("shaders/GUI/menu/flash.surface_shader")
function SetupFlashEffect(obj, flashPropertyName, item)
    flashPropertyName = flashPropertyName or "Flash"
    item = item or obj:GetRootItem()
    item:SetShader(kFlashShader)
    obj:HookEvent(obj, "On"..flashPropertyName.."Changed",
    function(self, flash)
        item:SetFloatParameter("multAmount", 2*flash + 1)
        item:SetFloatParameter("screenAmount", 2*flash)
    end)
end

function DoFlashEffect(obj, flashPropertyName)
    flashPropertyName = flashPropertyName or "Flash"
    obj:ClearPropertyAnimations(flashPropertyName)
    obj:Set(flashPropertyName, 1)
    obj:AnimateProperty(flashPropertyName, 0, MenuAnimations.FlashColor)
end

-- Flash effect that only animates the color of the object -- doesn't have a special shader.
-- Performs a flash effect on the object, and then fades back down to the highlight color, or
-- the optional color if specified.
function DoColorFlashEffect(obj, flashPropertyName, alternateColor)
    flashPropertyName = flashPropertyName or "Color"
    obj:Set(flashPropertyName, alternateColor or MenuStyle.kHighlight)
    obj:AnimateProperty(flashPropertyName, nil, MenuAnimations.HighlightFlashColor)
end

function Client.GetOptionColor(name, defaultValue)
    defaultValue = tonumber(defaultValue)

    return ColorIntToColor(Client.GetOptionInteger(name, defaultValue))
end

function Client.SetOptionColor(name, value)
    value = ColorToColorInt(value)

    return Client.SetOptionInteger(name, value)
end

-- Wrapped up in function calls so they're not nil due to the whole Client vs ClientLoaded crap...
local kGetOptionValueFunctions =
{
    bool    = function() return Client.GetOptionBoolean end,
    int     = function() return Client.GetOptionInteger end,
    float   = function() return Client.GetOptionFloat end,
    string  = function() return Client.GetOptionString end,
    color   = function() return Client.GetOptionColor end
}

-- Wrapped up in function calls so they're not nil due to the whole Client vs ClientLoaded crap...
local kSetOptionValueFunctions =
{
    bool    = function() return Client.SetOptionBoolean end,
    int     = function() return Client.SetOptionInteger end,
    float   = function() return Client.SetOptionFloat end,
    string  = function() return Client.SetOptionString end,
    color   = function() return Client.SetOptionColor end
}

function ValidateOptionType(optionType, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    if optionType == nil or type(optionType) ~= "string" or kSetOptionValueFunctions[optionType] == nil then
        error(string.format("Invalid optionType!  Expected 'bool', 'int', 'float', 'color' or 'string', got '%s' instead", optionType), errorDepth)
    end
end

function GetOptionValueGetterFunctionForType(typeName)
    
    RequireType("string", typeName, "type", 2)
    
    if not kGetOptionValueFunctions[typeName] then
        error(string.format("Unrecognized type for option getter.  Expected 'bool', 'float', 'int', 'color' or 'string'.  Got '%s'.", typeName))
    end
    
    local result = kGetOptionValueFunctions[typeName]()
    return result
    
end

function GetOptionValueSetterFunctionForType(typeName)
    
    RequireType("string", typeName, "type", 2)
    
    if not kSetOptionValueFunctions[typeName] then
        error(string.format("Unrecognized type for option setter.  Expected 'bool', 'float', 'int', 'color' or 'string'.  Got '%s'.", typeName))
    end
    
    local result = kSetOptionValueFunctions[typeName]()
    return result
    
end

-- Sets the value of an option-wrapped widget to the value loaded from the engine's option system.
function SetWidgetValueFromOption(widget)
    
    local optionType = widget.optionType
    local optionPath = widget.optionPath
    local alternateGetter = widget.alternateGetter
    local default = widget.default
    
    AssertIsaGUIObject(widget)
    assert(type(optionType) == "string" or alternateGetter)
    assert(type(optionPath) == "string" or alternateGetter)
    assert(default ~= nil or alternateGetter)
    
    local value
    if alternateGetter then
        value = alternateGetter()
    else
        local func = GetOptionValueGetterFunctionForType(optionType)
        value = func(optionPath, default)
    end

    widget:SetValue(value)
    
end

-- Sets an engine-managed option value.
function SetOptionFromValue(optionPath, optionType, value, alternateSetter)
    
    assert(type(optionType) == "string" or alternateSetter)
    assert(type(optionPath) == "string" or alternateSetter)
    
    if alternateSetter then
        alternateSetter(value)
    else
        local func = GetOptionValueSetterFunctionForType(optionType)
        func(optionPath, value)
    end
    
end

-- Sets an engine-managed option value based on the given widget's value.
function SetOptionFromWidgetValue(widget)
    
    local optionType = widget.optionType
    local optionPath = widget.optionPath
    local alternateSetter = widget.alternateSetter
    
    AssertIsaGUIObject(widget)
    
    SetOptionFromValue(optionPath, optionType, widget:GetValue(), alternateSetter)
    
end

function CleanNickName(name)
    local result = string.UTF8SanitizeForNS2(TrimName(name))
    return result
end

function UpdatePlayerNicknameFromOptions()
    
    local name = ""
    local nickname
    local overrideEnabled = Client.GetOptionBoolean(kNicknameOverrideKey, false)
    
    if overrideEnabled then
        name = Client.GetOptionString(kNicknameOptionsKey, "")
        nickname = name
    else
        name = Client.GetUserName()
    end
    
    name = CleanNickName(name)
    if nickName then
        nickname = CleanNickName(nickName)
    end
    
    if name == "" or not string.IsValidNickname(name) then
        name = kDefaultPlayerName
    end
    
    if Client and Client.GetIsConnected() and (Client.lastSentName ~= name) then
        Client.lastSentName = name
        Client.SendNetworkMessage("SetName", {name = name}, true)
    end
    
    local localPlayerData = GetLocalPlayerProfileData()
    if localPlayerData then
        localPlayerData:SetPlayerName(name)
    end
    
    return name
    
end
Event.Hook("SteamPersonaChanged", UpdatePlayerNicknameFromOptions )

function GetNickName()
    
    local localPlayerData = GetLocalPlayerProfileData()
    if localPlayerData then
        return (localPlayerData:GetPlayerName())
    else
        return (UpdatePlayerNicknameFromOptions())
    end
    
end

function SetNickName(name)
    
    name = CleanNickName(name)
    Client.SetOptionString(kNicknameOptionsKey, name)
    
    -- Update options menu widgets accordingly.
    local optionsMenu = GetOptionsMenu()
    if optionsMenu then
        local textBox = optionsMenu:GetOptionWidget("nickname")
        if textBox then
            textBox:SetValue(name)
        end
    end
    
    UpdatePlayerNicknameFromOptions()
    
end
