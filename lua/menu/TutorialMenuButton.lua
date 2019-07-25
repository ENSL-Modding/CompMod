-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\menu\TutorialMenuButton.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
--    Modified by Trevor "BeigeAlert" Harris, to make a special version that doesn't
--       have the automatic highlighting behavior, but allows custom behavior.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load('lua/menu/MenuElement.lua')

local kDefaultTutorialMenuButtonFontSize = 24
local kDefaultSize = Vector(16, 16, 0)
local kDefaultBorderWidth = 1
local kDefaultTutorialMenuButtonFontName = Fonts.kArial_15 
local kDefaultFontSize = 18
local kDefaultFontColor = Color(0.77, 0.44, 0.22)

class 'TutorialMenuButton' (MenuElement)

function TutorialMenuButton:GetTagName()
    return "button"
end

function TutorialMenuButton:Initialize()

    MenuElement.Initialize(self)
    
    self:SetBackgroundSize(kDefaultSize)
    self:SetBorderWidth(kDefaultBorderWidth)
    
    self.text = CreateTextItem(self)
    self.text:SetColor(kDefaultFontColor)
    self.text:SetFontName(kDefaultTutorialMenuButtonFontName)
    self.text:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.text:SetTextAlignmentX(GUIItem.Align_Center)
    self.text:SetTextAlignmentY(GUIItem.Align_Center)
    self:GetBackground():AddChild(self.text)
    
    --self:EnableHighlighting()
    
    local eventCallbacks = {
      
    OnClick = function (self)
        MainMenu_OnButtonClicked()
    end, 
    }
    
    self:AddEventCallbacks(eventCallbacks)
    
end

function TutorialMenuButton:SetTextColor(color, time, animateFunc, animName, callBack)
    self.text:SetColor(color, time, animName, animateFunc, callBack)
end

function TutorialMenuButton:SetText(text, time, animateFunc, animName, callBack)
    self.text:SetText(text, time, animName, animateFunc, callBack)
end

function TutorialMenuButton:SetFontSize(fontSize, time, animateFunc, animName, callBack)
    self.text:SetFontSize(fontSize, time, animName, animateFunc, callBack)
end

function TutorialMenuButton:SetFontName(fontName)
    self.text:SetFontName(fontName)
end

function TutorialMenuButton:SetIsScaling(isScaling)

    MenuElement.SetIsScaling(self, isScaling)
    
    self.text:SetIsScaling(isScaling)
    
end