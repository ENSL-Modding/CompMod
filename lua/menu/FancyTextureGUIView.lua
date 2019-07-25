-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\FancyTextureGUIView.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIView for rendering shaders out to a texture.  Designed to work with the FancyGUIViewManager class.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")
Script.Load("lua/menu/FancyUtilities.lua")

sizeX           = 20
sizeY           = 20
resScale        = 1 -- multiplier for screen resolution.
shader          = nil

paramNameTable = {}
params = ""

local prefix = "prev_"
local checkGlobals = {"sizeX", "sizeY", "shader", "params"}
for i=1, #checkGlobals do
    checkGlobals[checkGlobals[i]] = i
    _G[prefix..checkGlobals[i]] = _G[checkGlobals[i]]
end

local function IsChanged(name)
    
    if _G[prefix..name] ~= _G[name] then
        return true
    end
    return false
    
end

local function UpdateValue(name)
    
    if IsChanged(name) then
        _G[prefix..name] = _G[name]
        return true
    end
    return false
    
end

local function UpdateTexture(textureName, texturePath)
    
    if textureName == "baseTexture" then
        quad:SetTexture(texturePath)
    else
        quad:SetAdditionalTexture(textureName, texturePath)
    end
    
end

local function UpdateParameter(name)
    
    if type(_G[name]) == "string" then
        -- parameter name is a texture
        UpdateTexture(name, _G[name] or "")
    else
        -- parameter name is a float
        quad:SetFloatParameter(name, _G[name])
    end
    
end

local function DoUpdate()
    
    -- do this first, as parameters cannot be added unless the shader will accept them.
    if shader then
        quad:SetShader(shader)
    end
    
    -- See if any new parameters have been added.
    if params ~= "" then
        local newNames = Fancy_SplitStringIntoTable(params, "|")
        for i=1, #newNames do
            if not checkGlobals[newNames[i]] then
                -- parameter is not one of the known globals.
                if not paramNameTable[newNames[i]] then -- add it to the dictionary and the array part.
                    paramNameTable[newNames[i]] = #paramNameTable + 1
                    paramNameTable[#paramNameTable + 1] = newNames[i]
                end
            end
        end
        params = ""
    end
    
    -- Update previous values to their current values.
    for i=1, #checkGlobals do
        UpdateValue(checkGlobals[i])
    end
    for i=1, #paramNameTable do
        if UpdateValue(paramNameTable[i]) then
            UpdateParameter(paramNameTable[i])
        end
    end
    
    GUI.SetSize(sizeX, sizeY)
    quad:SetSize(Vector(sizeX, sizeY, 0))
    
    
    quad:SetFloatParameter("rcpFrameX", 1/sizeX)
    quad:SetFloatParameter("rcpFrameY", 1/sizeY)
    quad:SetFloatParameter("resScale", resScale)
    
end

function Update(deltaTime)
    
    -- check for changes to any of the specified globals.
    for i=1, #checkGlobals do
        if _G[prefix..checkGlobals[i]] ~= _G[checkGlobals[i]] then
            DoUpdate()
            return
        end
    end
    
end

function Initialize()
    
    quad = GUI.CreateItem()
    quad:SetPosition(Vector(0,0,0))
    quad:SetIsVisible(true)
    quad:SetColor(Color(1,1,1,1))
    quad:SetLayer(5)
    
    quad:SetBlendTechnique(GUIItem.Add)
    
end

Initialize()

