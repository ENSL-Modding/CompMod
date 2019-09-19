-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModColumnHeader.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A button for the top of a column in the mods menu.  Can be clicked on to set the sorting
--    function.
--
--  Parameters (* = required)
--      label
--     *sortFuncs   Table of two sorting functions to cycle through when clicked.
--
--  Properties
--      Label       Text to display for this object.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/widgets/GUIButton.lua")

Script.Load("lua/GUI/wrappers/FXState.lua")

Script.Load("lua/menu2/GUIMenuText.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")

---@class GUIMenuModColumnHeader : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuModColumnHeader" (baseClass)

local function CycleSortFunction(self)
    
    PlayMenuSound("ButtonClick")
    
    local modsMenu = GetModsMenu()
    assert(modsMenu)
    local currentSortFunc = modsMenu:GetSortFunction()
    assert(currentSortFunc)
    
    local foundIdx
    for i=1, #self.sortFuncs do
        if self.sortFuncs[i] == currentSortFunc then
            foundIdx = i
            break
        end
    end
    
    if foundIdx then
        foundIdx = (foundIdx % #self.sortFuncs) + 1 -- Cycle to next sort function, wrap around.
    else
        foundIdx = 1
    end
    
    local func = self.sortFuncs[foundIdx]
    
    modsMenu:SetSortFunction(func)
    
end

function GUIMenuModColumnHeader:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType("table", params.sortFuncs, "params.sortFuncs", errorDepth)
    assert(#params.sortFuncs > 0)
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.label = CreateGUIObject("label", GUIMenuText, self,
    {
        font = MenuStyle.kServerListHeaderFont,
        text = params.label,
        defaultColor = MenuStyle.kHeaderIconPlainColor
    })
    self.label:AlignCenter()
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:SetLayer(-1)
    self.back:SetFillColor(MenuStyle.kServerBrowserHeaderColumnBoxFillColor)
    self.back:SetStrokeColor(MenuStyle.kServerBrowserHeaderColumnBoxStrokeColor)
    self.back:HookEvent(self, "OnSizeChanged", self.back.SetSize)
    
    self:HookEvent(self, "OnPressed", CycleSortFunction)
    
    self.sortFuncs = params.sortFuncs
    
end
