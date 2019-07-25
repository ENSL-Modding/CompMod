-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\FancyUtilities.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAssets.lua")

-- Calculating the font size isn't actually getting us a pixel-perfect height.  Rather, it is
-- reading the lineHeight from the .fnt file, and multiplying that by the number of lines.
kFancyFontLineHeight = 
{
    [Fonts.kMicrogrammaDBolExt_Huge] = 96.0,
    [Fonts.kAgencyFB_Huge_Bold] = 96.0,
}

kFancyFontActualHeight = 
{
    [Fonts.kMicrogrammaDBolExt_Huge] = 49.0,
    [Fonts.kAgencyFB_Huge_Bold] = 61.0,
}

local function GetTester()
    
    if not gFancyTester then
        gFancyTester = GUI.CreateItem()
        gFancyTester:SetOptionFlag(GUIItem.ManageRender)
        gFancyTester:SetIsVisible(false)
    end
    
    return gFancyTester
    
end

-- Returns the size of the specified string "text" when rendered using the specified "font".
function Fancy_CalculateTextSize(text, font)
    
    if not font or not text then
        return nil
    end
    
    local tester = GetTester()
    tester:SetFontName(font)
    
    local size = Vector(0,0,0)
    size.x = tester:GetTextWidth(text)
    size.y = tester:GetTextHeight(text)
    
    -- adjust the height to a more sensible value.  The original calculation assumes all characters
    -- fill their entire line-height, which they never do.  This changes the calculated value to
    -- be the height of a block of text, but with the first line only as tall as the average
    -- character.
    if kFancyFontLineHeight[font] then
        assert(kFancyFontActualHeight[font]) -- should be in both or neither.
        size.y = size.y - kFancyFontLineHeight[font] + kFancyFontActualHeight[font]
    end
    
    return size
    
end

-- returns font1 if it can render all the characters of the given text.  Returns font2 if it cannot.
-- if font1 is nil, returns nil, as font1 should always be set before font2.  Does not check to ensure
-- font2 can render all characters -- font2 should be a "safe" font.
function Fancy_GetBestFont(font1, font2, text)
    
    -- no text, cannot test!
    if not text then
        return nil
    end
    
    -- no fonts specified
    if not font1 then
        return nil
    end
    
    -- no fallback font specified
    if not font2 then
        return font1
    end
    
    local tester = GetTester()
    tester:SetFontName(font1)
    
    -- if all characters in the string can be rendered by font1... use font1.
    if tester:GetCanFontRenderString(font1, text) then
        return font1
    end
    
    return font2
    
end

-- Returns a string that has been split into substrings by a delimiter character, and returned as a table of
-- these sub strings.  Empty strings caused by two delimiter characters in a row are discarded.
function Fancy_SplitStringIntoTable(text, delimiter)
    
    local output = {}
    while true do
        local i = string.find(text, delimiter)
        if i == nil then
            if #text > 0 then
                output[#output+1] = text
            end
            return output
        else
            local temp = string.sub(text, 1, i-1)
            text = string.sub(text, i+1, #text)
            if #temp > 0 then
                output[#output+1] = temp
            end
        end
    end
    
end

-- pass in transformation assuming a 1920x1080 screen resolution.  Returns corrected
-- position and scale vectors for the user's actual screen resolution.  Resize method
-- determines how the resized screen space is positioned within the real screen.  Is
-- the rectangle centered in the space, or is it pushed up into a corner?  Can be nil.
function Fancy_Transform(position, scale, resizeMethod)
    
    local basisWidth = 1920
    local basisHeight = 1080
    local basisRatio = basisWidth / basisHeight -- eg 1.777778
    
    local width = Client.GetScreenWidth() -- eg 1280
    local height = Client.GetScreenHeight() -- eg 1024
    local ratio = width / height -- eg 1.25
    
    if width == basisWidth and height == basisHeight then
        return position, scale
    end
    
    local scaleFactor = 1.0
    if ratio > basisRatio then
        -- screen is a wider ratio than 16:9
        scaleFactor = height / basisHeight
    else
        -- screen is a taller ratio than 16:9
        scaleFactor = width / basisWidth
    end
    
    local newBasisWidth = basisWidth * scaleFactor
    local newBasisHeight = basisHeight * scaleFactor
    
    local xOffset = (width - newBasisWidth)
    local yOffset = (height - newBasisHeight)
    
    resizeMethod = resizeMethod or "best-fit-center"
    if resizeMethod == "best-fit-center" then
        xOffset = xOffset * 0.5
        yOffset = yOffset * 0.5
    elseif resizeMethod == "best-fit-top-left" then
        xOffset = 0
        yOffset = 0
    end
    
    local newPosition = position * scaleFactor + Vector(xOffset, yOffset, 0)
    local newScale = scale * scaleFactor
    
    return newPosition, newScale
    
end


