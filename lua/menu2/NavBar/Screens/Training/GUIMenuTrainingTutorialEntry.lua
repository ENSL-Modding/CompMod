-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/Training/GUIMenuTrainingTutorialEntry.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A single entry in the categories list (left side list) for one of the tutorials.
--
--  Parameters (* = required)
--      label
--      tutorialAchievementCode     The code associated with this tutorial's completion.  Determines
--                                  Whether or not the check mark is visible.
--
--  Properties:
--      Label               Text to display for this entry.
--      IndexEven           Whether or not this is an even-numbered entry in the list (determines
--                          color).
--      Selected            Whether or not this entry is selected (determines color).
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/GUIMenuCategoryDisplayBoxEntry.lua")

---@class GUIMenuTrainingTutorialEntry : GUIMenuCategoryDisplayBoxEntry
class "GUIMenuTrainingTutorialEntry" (GUIMenuCategoryDisplayBoxEntry)

GUIMenuTrainingTutorialEntry:AddCompositeClassProperty("CheckVisible", "check", "Visible")

local kHeight = 210
local kCheckTexture = PrecacheAsset("ui/menu/tutorial_button_checkmark.dds")
local kCheckColor = Color(1, 1, 1, 0.75)

function GUIMenuTrainingTutorialEntry:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType("string", params.tutorialAchievementCode, "params.tutorialAchievementCode", errorDepth)
    
    GUIMenuCategoryDisplayBoxEntry.Initialize(self, params, errorDepth)
    
    self:SetHeight(kHeight)
    
    self.check = self:CreateGUIItem()
    self.check:SetTexture(kCheckTexture)
    self.check:SetSizeFromTexture()
    self.check:AlignCenter()
    self.check:SetColor(kCheckColor)
    self:SetCheckVisible(Client.GetAchievement(params.tutorialAchievementCode))
    
end