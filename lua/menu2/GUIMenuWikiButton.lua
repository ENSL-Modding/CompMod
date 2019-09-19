-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/GUIMenuWikiButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Button that opens up the wiki.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/GUIMenuExitButton.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

---@class GUIMenuWikiButton : GUIMenuExitButton
local baseClass = GUIMenuExitButton
baseClass = GetTooltipWrappedClass(baseClass)
class "GUIMenuWikiButton" (baseClass)

local kWikiAddress = "https://wiki.naturalselection2.com/"

GUIMenuWikiButton.kTextureRegular = PrecacheAsset("ui/newMenu/wikiButton.dds")
GUIMenuWikiButton.kTextureHover   = PrecacheAsset("ui/newMenu/wikiButtonOver.dds")

GUIMenuWikiButton.kOffset = Vector(53, 28, 0)

GUIMenuWikiButton.kShadowScale = Vector(10, 5, 1)

function GUIMenuWikiButton:OnPressed()
    Client.ShowWebpage(kWikiAddress)
end

function GUIMenuWikiButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    baseClass.Initialize(self, params, errorDepth)
    self:AlignTopLeft()
    self:SetTooltip(Locale.ResolveString("WIKI_BUTTON_TOOLTIP"))
end
