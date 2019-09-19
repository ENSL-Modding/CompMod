-- Adding NSL skill tier icons.
local kOpenTournament2019GoldTexture   = PrecacheAsset("ui/badges/nsl_open_tournament_2019_gold.dds")
local kOpenTournament2019SilverTexture = PrecacheAsset("ui/badges/nsl_open_tournament_2019_silver.dds")
local kOpenTournament2019BronzeTexture = PrecacheAsset("ui/badges/nsl_open_tournament_2019_bronze.dds")

local kOpenTournament2019AnimatedShader = PrecacheAsset("ui/badges/nsl_open_tournament_2019_animated.surface_shader")

local k2019GoldFrameCount = 29
local k2019SilverFrameCount = 30
local k2019BronzeFrameCount = 28

local kOpenTournament2019GoldTooltip = "NSL 2019 Open Tournament First Place Winner (Team '%s')"
local kOpenTournament2019SilverTooltip = "NSL 2019 Open Tournament Second Place Winner (Team '%s')"
local kOpenTournament2019BronzeTooltip = "NSL 2019 Open Tournament Third Place Winner (Team '%s')"

-- Hardcode the NS2 steam IDs of players awarded these badges.  Value is team name.
gNSLOpenTournament2019GoldIDs =
{
    [302984041]       = "why bm?",       -- marsh
    [54965415]        = "why bm?",       -- Rirey
    [126698727]       = "why bm?",       -- Hyste
    [32430346]        = "why bm?",       -- phone
    [344054]          = "why bm?",       -- golden
    [803162]          = "why bm?",       -- herakles
}

gNSLOpenTournament2019SilverIDs =
{
    [6638152]         = "eyjafjallajökull",       -- infamous
    [32950287]        = "eyjafjallajökull",       -- rantology
    [289517]          = "eyjafjallajökull",       -- Grissi
    [8188762]         = "eyjafjallajökull",       -- king_yo
    [50996886]        = "eyjafjallajökull",       -- mephilles
    [133828502]       = "eyjafjallajökull",       -- caperp
}

gNSLOpenTournament2019BronzeIDs =
{
    [41125372]        = "Shoobs",       -- der einzieg
    [45191760]        = "Shoobs",       -- BOHICA
    [2582259]         = "Shoobs",       -- swalk
    [34157492]        = "Shoobs",       -- bill
    [10088658]        = "Shoobs",       -- mklp
    [51623684]        = "Shoobs",       -- stark
}

-- Returns either nil (no special recipient), or a table:
--  name        Name to use for "skillTierName" field... not sure where this is actually used, just
--                  dotting my i's and crossing my t's here...
--  shader      Shader to use for this icon.
--  tex         Texture file to use.
--  frameCount (optional) Number of frames in the animation.  Sets a float parameter in the shader named "frameCount".
--  tooltip     Tooltip of the icon for the player found (includes their team name).
--  texCoords (optional)    Normalized texture coordinates to use.
--  texPixCoords (optional) Texture coordinates (in pixels) to use.
function CheckForSpecialBadgeRecipient(steamId)
    
    if steamId == nil then
        return nil
    end
    
    local result
    if gNSLOpenTournament2019GoldIDs[steamId] then
        result =
        {
            name = "Open Tournament 2019 Gold",
            shader = kOpenTournament2019AnimatedShader,
            tex = kOpenTournament2019GoldTexture,
            frameCount = k2019GoldFrameCount,
            tooltip = string.format(kOpenTournament2019GoldTooltip, gNSLOpenTournament2019GoldIDs[steamId]),
            texCoords = {0, 0, 1, 1},
        }
    elseif gNSLOpenTournament2019SilverIDs[steamId] then
        result =
        {
            name = "Open Tournament 2019 Silver",
            shader = kOpenTournament2019AnimatedShader,
            tex = kOpenTournament2019SilverTexture,
            frameCount = k2019SilverFrameCount,
            tooltip = string.format(kOpenTournament2019SilverTooltip, gNSLOpenTournament2019SilverIDs[steamId]),
            texCoords = {0, 0, 1, 1},
        }
    elseif gNSLOpenTournament2019BronzeIDs[steamId] then
        result =
        {
            name = "Open Tournament 2019 Bronze",
            shader = kOpenTournament2019AnimatedShader,
            tex = kOpenTournament2019BronzeTexture,
            frameCount = k2019BronzeFrameCount,
            tooltip = string.format(kOpenTournament2019BronzeTooltip, gNSLOpenTournament2019BronzeIDs[steamId]),
            texCoords = {0, 0, 1, 1},
        }
    end
    
    return result
    
end
