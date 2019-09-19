-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/MenuBackgrounds.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Data and functions related to menu backgrounds.  Defined here rather than in MenuData.lua so
--    that we can pick and preload a menu background cinematic without having to load the rest of
--    the menu.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

MenuBackgrounds = {}

local kMenuBackgroundData = {}
function MenuBackgrounds.AddMenuBackground(data)
    
    if type(data.name) ~= "string" then
        error(string.format("Expected a string for menu background name, got '%s' instead!", data.name), 2)
    end
    
    if data.name == "default" then
        error("Defining a menu background with the name \"default\" is not allowed.", 2)
    end
    
    if data.name == "random" then
        error("Defining a menu background with the name \"random\" is not allowed.", 2)
    end
    
    if data.name == "" then
        error("Menu background name cannot be empty!", 2)
    end
    
    if type(data.localeString) ~= "string" then
        error(string.format("Expected a string for menu background localeString, got '%s' instead!", data.localeString), 2)
    end
    
    if data.localeString == "" then
        error("Menu background locale string cannot be empty!", 2)
    end
    
    if type(data.cinematicPath) ~= "string" then
        error(string.format("Expected a string for menu background cinematic path, got '%s' instead!", data.cinematicPath), 2)
    end
    
    if data.cinematicPath == "" then
        error("Menu background cinematic path cannot be empty!", 2)
    end
    
    kMenuBackgroundData[data.name] =
    {
        name = data.name,
        localeString = data.localeString,
        cinematicPath = data.cinematicPath,
    }
end

local kDefaultMenuBackgroundPath
function MenuBackgrounds.SetDefaultBackground(backgroundName)
    local backgroundData = kMenuBackgroundData[backgroundName]
    if not backgroundData then
        error(string.format("Menu background named '%s' was not defined!  (Did you call MenuBackgrounds.SetDefaultBackground() before this menu was added with MenuBackgrounds.AddMenuBackground()?)", backgroundName), 2)
    end
    
    kDefaultMenuBackgroundPath = backgroundData.cinematicPath

end

function MenuBackgrounds.GetMenuBackgroundChoices()
    
    local choices = {}
    
    choices[1] = { value = "default", displayString = Locale.ResolveString("MENU_BACKGROUND_DEFAULT") }
    choices[2] = { value = "random", displayString = Locale.ResolveString("MENU_BACKGROUND_RANDOM") }
    
    -- Yea yea... we're using pairs, but this function is called VERY infrequently, so it should be fine.
    for __, background in pairs(kMenuBackgroundData) do
        choices[#choices+1] = { value = background.name, displayString = Locale.ResolveString(background.localeString) }
    end
    
    return choices

end

function MenuBackgrounds.GetMenuBackgroundCinematicPath(name)
    if name == "default" then
        if kDefaultMenuBackgroundPath then
            return kDefaultMenuBackgroundPath
        else
            Log("WARNING: No default menu background was set!  Defaulting to tram.")
            return "cinematics/menus/main_menu_tram.cinematic"
        end
    elseif name == "random" then
        local choices = MenuBackgrounds.GetMenuBackgroundChoices()
        local choice = choices[math.random(3, #choices)]
        return kMenuBackgroundData[choice.value].cinematicPath
    else
        return kMenuBackgroundData[name].cinematicPath
    end
end

function MenuBackgrounds.GetCurrentMenuBackgroundCinematicPath()
    local cinematicPath = Client.GetOptionString("menu/pickedCinematicPath", "")
    if cinematicPath == "" then
        cinematicPath = MenuBackgrounds.PickNextMenuBackgroundPath()
    end
    return cinematicPath
end

-- Called to "re-roll" the menu background for the next time the game displays the main menu.  This
-- is necessary when the background is set to random -- we need to know ahead of time which
-- background is going to be picked.  This is tricky because we cannot pick it during the loading
-- screen -- we have no way of communicating the result of the roll to the main world (loading world
-- and main world do not communicate, and Loading world does not have access to any of the
-- Client.SetOption_____() functions -- only Client.GetOption_____().
function MenuBackgrounds.PickNextMenuBackgroundPath()
    
    local backgroundName = Client.GetOptionString("menu/menuBackgroundName", "default")
    local cinematicPath = MenuBackgrounds.GetMenuBackgroundCinematicPath(backgroundName)
    
    -- If we can, store the result of this.
    if Client and Client.SetOptionString then
        Client.SetOptionString("menu/pickedCinematicPath", cinematicPath)
    end
    
    return cinematicPath
    
end

MenuBackgrounds.AddMenuBackground(
{
    name = "derelict",
    localeString = "MENU_BACKGROUND_DERELICT",
    cinematicPath = "cinematics/menus/main_menu_derelict.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "eclipse",
    localeString = "MENU_BACKGROUND_ECLIPSE",
    cinematicPath = "cinematics/menus/main_menu_eclipse.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "kodiak",
    localeString = "MENU_BACKGROUND_KODIAK",
    cinematicPath = "cinematics/menus/main_menu_kodiak.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "biodome",
    localeString = "MENU_BACKGROUND_BIODOME",
    cinematicPath = "cinematics/menus/main_menu_biodome.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "descent",
    localeString = "MENU_BACKGROUND_DESCENT",
    cinematicPath = "cinematics/menus/main_menu_descent.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "docking",
    localeString = "MENU_BACKGROUND_DOCKING",
    cinematicPath = "cinematics/menus/main_menu_docking.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "mineshaft",
    localeString = "MENU_BACKGROUND_MINESHAFT",
    cinematicPath = "cinematics/menus/main_menu_mineshaft.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "refinery",
    localeString = "MENU_BACKGROUND_REFINERY",
    cinematicPath = "cinematics/menus/main_menu_refinery.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "summit",
    localeString = "MENU_BACKGROUND_SUMMIT",
    cinematicPath = "cinematics/menus/main_menu_summit.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "tram",
    localeString = "MENU_BACKGROUND_TRAM",
    cinematicPath = "cinematics/menus/main_menu_tram.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "veil",
    localeString = "MENU_BACKGROUND_VEIL",
    cinematicPath = "cinematics/menus/main_menu_veil.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "caged",
    localeString = "MENU_BACKGROUND_CAGED",
    cinematicPath = "cinematics/menus/main_menu_caged.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "unearthed",
    localeString = "MENU_BACKGROUND_UNEARTHED",
    cinematicPath = "cinematics/menus/main_menu_unearthed.cinematic",
})

MenuBackgrounds.AddMenuBackground(
{
    name = "origin",
    localeString = "MENU_BACKGROUND_ORIGIN",
    cinematicPath = "cinematics/menus/main_menu_origin.cinematic",
})

MenuBackgrounds.SetDefaultBackground("origin")

-- Precache the main menu background cinematic.
local cinematicPath = MenuBackgrounds.GetCurrentMenuBackgroundCinematicPath()
PrecacheAsset(cinematicPath)
