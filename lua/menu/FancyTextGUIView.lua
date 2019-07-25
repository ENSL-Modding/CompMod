-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\FancyTextGUIView.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIView to help render text effects.  We can't use a simple shader because text is not rendered in
--    that way with nice, contiguous texture coordinates.  Applying a shader directly to a GUIItem that
--    is rendering text will apply the shader to the entire text sheet, which is then rearranged to form
--    the string.  What we want is to apply the effect to the rendered product of the text.  To do this,
--    we render the text in solid white on a black background, and use this resulting texture as our shader
--    input. 
--    
--    Reminder: a GUIView resides within its very own lua VM.
--
--    Designed to work with the FancyGUIViewManager class.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")
Script.Load("lua/menu/FancyUtilities.lua")

fontName            = ""
sizeX               = 20
sizeY               = 20
textScaleFactor     = 1.0
text                = ""

local prefix = "prev_"
local checkGlobals = {"fontName", "sizeX", "sizeY", "textScaleFactor", "text"}
for i=1, #checkGlobals do
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

local function DoUpdate(deltaTime, force)
    
    for i=1, #checkGlobals do
        
        if force or UpdateValue(checkGlobals[i]) then
            -- value was different but is now updated
            
            -- update font name
            if checkGlobals[i] == "fontName" then
                if fontName and fontName ~= "" then
                    textItem:SetFontName(fontName)
                end
            
            -- update text contents
            elseif checkGlobals[i] == "text" then
                textItem:SetText(text or "")
                
            elseif checkGlobals[i] == "sizeX" or checkGlobals[i] == "sizeY" then
                GUI.SetSize(sizeX, sizeY)
            
            elseif checkGlobals[i] == "textScaleFactor" then
                textItem:SetScale(Vector(textScaleFactor, textScaleFactor, 1))
            
            end
            
        end
        
    end
    
end

function Update(deltaTime)
    
    DoUpdate(deltaTime)
    
end

function Initialize()
    
    textItem = GUI.CreateItem()
    textItem:SetOptionFlag(GUIItem.ManageRender)
    textItem:SetLayer(6)
    textItem:SetTextAlignmentX(GUIItem.Align_Center)
    textItem:SetTextAlignmentY(GUIItem.Align_Center)
    textItem:SetAnchor(GUIItem.Middle, GUIItem.Center)
    textItem:SetPosition(Vector(0,0,0))
    textItem:SetColor(Color(1,1,1,1))
    textItem:SetIsVisible(true)
    
    DoUpdate(0, true)
    
end

Initialize()




