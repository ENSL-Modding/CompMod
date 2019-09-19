-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/GUIModDataManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Singleton GUI object that just serves to hold data related to mods.  Yea, it's a bit odd,
--    wasteful to use a GUIObject for this, as there's no visual component -- just data, but it's
--    more than worth it to leverage the provided event callback system, which is super convenient
--    when dealing with async stuff.
--
--  Properties
--      BeingRefreshed  Whether or not the mods list is currently being refreshed.
--      NumMods         The number of mods reported by the engine.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")

---@class GUIModDataManager : GUIObject
class "GUIModDataManager" (GUIObject)

GUIModDataManager:AddClassProperty("BeingRefreshed", false)
GUIModDataManager:AddClassProperty("NumMods", 0)

local modDataManager
function GetModDataManager()
    if not modDataManager then
        modDataManager = CreateGUIObject("modDataManager", GUIModDataManager)
    end
    return modDataManager
end

function GUIModDataManager:Refresh()
    Client.RefreshModList()
    self:SetUpdates(true)
end

function GUIModDataManager:OnUpdate(deltaTime, now)
    
    self:SetNumMods(Client.GetNumMods())
    
    local beingRefreshed = Client.ModListIsBeingRefreshed()
    self:SetBeingRefreshed(beingRefreshed)
    self:SetUpdates(beingRefreshed)
    
    if not beingRefreshed then
        self:SetUpdates(false)
    end
    
    -- Ensure mod entries are updated
    local modsMenu = GetModsMenu()
    if modsMenu then
        modsMenu:UpdateAllMods()
    end
    
end



