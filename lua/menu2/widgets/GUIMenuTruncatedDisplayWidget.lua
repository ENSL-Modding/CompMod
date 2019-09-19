-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuTruncatedDisplayWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu themeing for GUITruncatedDisplayWidget.
--@class GUIMenuTruncatedDisplayWidget : GUITruncatedDisplayWidget
--
--  Properties:
--      AutoScroll          -- Whether or not the item automatically scrolls.
--      Scroll              -- The current value of the item's scroll (some value between 0 and X,
--                             where X is the width of the contents that doesn't fit inside the
--                             container).
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUITruncatedDisplayWidget.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuTruncatedDisplayWidget : GUITruncatedDisplayWidget
class "GUIMenuTruncatedDisplayWidget" (GUITruncatedDisplayWidget)

local function ScrollAnimationFunc(obj, time, params, currentValue, startValue, endValue, startTime)
    
    local maxScroll = obj:GetMaxScroll()
    local scrollSpeed = obj:GetAutoScrollSpeed()
    local scrollTime = maxScroll / scrollSpeed
    local delayFront = MenuStyle.kTextAutoScrollFrontDelay
    local delayBack = MenuStyle.kTextAutoScrollBackDelay
    local delayTotal = delayFront + delayBack
    local smoothTime = MenuStyle.kTextAutoScrollSmoothTime
    local totalTime = scrollTime + delayTotal
    
    local cycle = time / totalTime
    cycle = (cycle - math.floor(cycle)) * totalTime
    
    if delayFront + smoothTime >= scrollTime + delayFront - smoothTime then
        
        -- We have a very short max scroll.  Use a different smoothing technique, to keep it continuous.
        if cycle <= delayFront - smoothTime then -- flat part at the beginning
            return 0, false
        elseif cycle <= scrollTime + delayFront + smoothTime then -- 3t^2 - 2t^3 interpolation
            local t = (cycle - delayFront + smoothTime) / (scrollTime + 2*smoothTime)
            t = 3 * t * t - 2 * t * t * t
            return maxScroll * t, false
        else -- flat part at the end
            return maxScroll, false
        end
        
    else
        
        if cycle <= delayFront - smoothTime then -- segment 1: flat @ 0
            return 0, false
        elseif cycle <= delayFront + smoothTime then -- segment 2: right-half of a parabola
            local parabola = cycle - delayFront + smoothTime
            parabola = parabola * parabola
            return (0.25 / smoothTime) * scrollSpeed * parabola, false
        elseif cycle <= scrollTime + delayFront - smoothTime then -- segment 3: straight slope = scroll speed
            return scrollSpeed * (cycle - delayFront), false
        elseif cycle <= scrollTime + delayFront + smoothTime then -- segment 4: right-half of inverted parabola.
            local parabola = cycle - scrollTime - delayFront - smoothTime
            parabola = parabola * parabola
            return maxScroll - ((0.25 / smoothTime) * scrollSpeed) * parabola, false
        else -- segment 5: flat @ maxScroll
            return maxScroll, false
        end
        
    end
    
end

function GUIMenuTruncatedDisplayWidget:GetScrollAnimationParameters()
    return { func = ScrollAnimationFunc, }
end
