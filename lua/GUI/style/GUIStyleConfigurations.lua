-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/style/GUIStyleConfigurations.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Definitions of various Photoshop-like layer-style setups.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/style/GUIStyleFontNode.lua")
Script.Load("lua/GUI/style/GUIStyleTextureNode.lua")

GUIStyle = {} -- namespace for these functions/configurations

-- Most Photoshop styles rely on gaussian blur at their core.  Utilty function to create a blur based on
-- the text input.
function GUIStyle.TextBlur(blurRadius)
    
    return
    {
        shader = "shaders/GUI/menu/gaussianBlurX.surface_shader",
        inputs =
        {
            [1] =
            { name = "baseTexture", value =
                {
                    shader = "shaders/GUI/menu/gaussianBlurY.surface_shader",
                    inputs = 
                    {
                        [1] = { name = "baseTexture", value = "__Text" },
                        [2] = { name = "blurRadius", value = blurRadius },
                    },
                },
            },
            [2] = { name = "blurRadius", value = blurRadius },
        },
    }
    
end

-- Recursively precache the shaders and textures found in this config, and any configs contained within.
function PrecacheGUIStyleConfig(config)
    if config.shader then
        PrecacheAsset(config.shader)
    end
    
    if config.inputs then
        for i=1, #config.inputs do
            local input = config.inputs[i]
            
            if type(input.value) == "string" and input.value ~= "__Text" then
                -- probably a texture...
                PrecacheAsset(input.value)
            elseif type(input.value) == "table" then
                PrecacheGUIStyleConfig(input.value)
            end
            
        end
    end
    
    return config
end

-- Recursively reads a style configuration, adding nodes as it goes, until finally returning the root node.
function GUIStyle.ReadConfig(config, fontNode, size, globalScale)
    
    local children = {}
    local shader = config.shader
    local color = config.color or Color(1,1,1,1)
    local inputNames = {}
    local inputValues = {}
    for i=1, #config.inputs do
        local input = config.inputs[i]
        local inputName = input.name
        local inputValue
        if input.value == "__Text" then
            children[#children+1] = fontNode
            inputValue = fontNode:GetTargetTextureName()
        elseif type(input.value) == "table" then
            local childNode = GUIStyle.ReadConfig(input.value, fontNode, size, globalScale)
            children[#children+1] = childNode
            inputValue = childNode:GetTargetTextureName()
        else
            inputValue = input.value -- some other parameter type...
        end
        inputNames[#inputNames+1] = inputName
        inputValues[#inputValues+1] = inputValue
    end
    
    local newNode = GUIStyleTextureNode()
    newNode:Initialize(children, inputNames, inputValues, shader, color, size, globalScale)
    
    return newNode
    
end

-- Utility function to setup an object with a style config.  Returns the root node, and the size of
-- the graphic it renders.
function GUIStyle.ApplyToText(config, text, fontFile, fontScale, renderScale)
    
    local padding = Vector(2, 2, 0) * (config.padding or 0.0)
    local renderedTextSize = ((GUI.CalculateTextSize(fontFile, text) * fontScale) + padding) * renderScale
    
    local fontNode = GUIStyleFontNode()
    fontNode:Initialize(text, fontFile, fontScale * renderScale, renderedTextSize)
    
    local rootNode = GUIStyle.ReadConfig(config, fontNode, renderedTextSize, renderScale)
    rootNode:SetIsRootNode()
    
    return rootNode, renderedTextSize
    
end
