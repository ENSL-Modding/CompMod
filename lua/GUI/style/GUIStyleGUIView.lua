-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/GUI/style/GUIStyleGUIView.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Lua script to run in each GUIView used as an intermediate rendering pass.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

-- Dummy definition, otherwise it's not defined, and it's used in FontGlobals.
function PrecacheAsset(x)
    return x
end
gSkipUnorderedSetUnitTests = true -- workaround for missing functionality in this limited lua state.
Script.Load("lua/GUI/FontGlobals.lua")

__kFontShader = "shaders/GUIBasic.surface_shader"
__kDistanceFieldFontShader = "shaders/DistanceFieldFont.surface_shader"

function Update(deltaTime)
    
    -- only update when the main lua script has set our "update" global variable to true
    if not update then
        return
    end
    
    update = nil
    
    if isText == 1 then
        __item:SetOptionFlag(GUIItem.ManageRender)
        --__item:SetOptionFlag(GUIItem.DistanceFieldFont)
        __item:SetTextAlignmentX(GUIItem.Align_Center)
        __item:SetTextAlignmentY(GUIItem.Align_Center)
        __item:SetAnchor(GUIItem.Middle, GUIItem.Center)
        __item:SetPosition(Vector(0,0,0))
        __item:SetColor(Color(1,1,1,1))
        __item:SetIsVisible(true)
        __item:SetText(text)
        __item:SetFontName(fontFile)
        __item:SetScale(Vector(fontScaleX, fontScaleY, 1))
        if GetFontFileUsesDistanceField(fontFile) then
            __item:SetShader(__kDistanceFieldFontShader)
            local smoothing = 0.3333 / (4.0 * math.max(math.abs(fontScaleX), math.abs(fontScaleY)));
            __item:SetFloatParameter("smoothing", smoothing)
        else
            __item:SetShader(__kFontShader)
        end
        __item:SetSnapsToPixels(true)
        __item:SetBlendTechnique(GUIItem.Default)
        
        __background:SetSize(Vector(sizeX, sizeY, 0))
        __background:SetIsVisible(true)
        __background:SetColor(Color(0,0,0,1))
    else
        
        __item:SetShader(shader)
        
        __item:SetFloatParameter("rcpFrameX", 1/sizeX)
        __item:SetFloatParameter("rcpFrameY", 1/sizeY)
        __item:SetFloatParameter("scaleFactorX", __scaleFactorX)
        __item:SetFloatParameter("scaleFactorY", __scaleFactorY)
        
        -- force the composite to be the raw output of whatever shader is running.  Avoids all the
        -- premult bullshit that had been screwing things up.
        __item:SetBlendTechnique(GUIItem.Set)
        
        __background:SetIsVisible(false)
        __background:SetColor(Color(0,0,0,0))
        
        -- since we can have any number of shader parameters, we have one parameter that tells us
        -- how many there are.
        for i=1, paramCount do
            
            local k = _G["key_"..i]
            local v = _G["value_"..i]
            
            if type(v) == "string" then
                
                if k == "baseTexture" then
                    __item:SetTexture(v)
                else
                    __item:SetAdditionalTexture(k, v)
                end
                
            elseif type(v) == "number" then
                __item:SetFloatParameter(k, v)
            elseif type(v) == "cdata" and v:isa("Color") then
                __item:SetFloat4Parameter(k, v)
            else
                error(string.format("Attempted to pass invalid type to shader! (type = %s)", type(v)))
            end
            
        end
        
        __item:SetColor(__color)
        __item:SetSize(Vector(sizeX, sizeY, 0))
        
    end
    
end

function Initialize()
    
    __item = GUI.CreateItem()
    __item:SetPosition(Vector(0,0,0))
    __item:SetIsVisible(true)
    __item:SetColor(Color(1,1,1,1))
    __item:SetLayer(5)
    
    __background = GUI.CreateItem()
    __background:SetPosition(Vector(0,0,0))
    __background:SetIsVisible(false)
    __background:SetColor(Color(0,0,0,0))
    __background:SetLayer(4)
    
end

Initialize()