local kCompModRevisionKey = "compmod_revision"
local kChangeLogTitle = "NSL Competitive Mod"
local kChangeLogURL = "https://enslcompmod.github.io/CompMod/changelog"
local kChangeLogDetailURL = "https://enslcompmod.github.io/CompMod/revisions/revision" .. g_compModRevision .. ".html"

local function showChangeLog(withDetail)
    withDetail = withDetail or false
    local url
    if withDetail then
        url = kChangeLogDetailURL
    else
        url = kChangeLogURL
    end

    if Shine then
        Shine:OpenWebpage(url, kChangeLogTitle)
    elseif Client.GetIsSteamOverlayEnabled() then
        Client.ShowWebpage(url)
    else
        print("Warn: Couldn't open changelog because no webview is available")
    end
end

local oldOnInitLocalClient = Player.OnInitLocalClient
function Player:OnInitLocalClient()
    oldOnInitLocalClient(self)

    local oldRevision = Client.GetOptionInteger(kCompModRevisionKey, -1)
    if g_compModRevision > oldRevision  then
        Client.SetOptionInteger(kCompModRevisionKey, g_compModRevision)
        showChangeLog(true)
    end
end

Event.Hook("Console_changelog", showChangeLog)


function PlayerUI_WithinCragRange()
    local player = Client.GetLocalPlayer()
    if player then
        local ents = GetEntitiesForTeam("Crag", player:GetTeamNumber())
        for _, crag in ipairs(ents) do
            if player:GetOrigin():GetDistance(crag:GetOrigin()) <= crag:GetHealRadius() and crag:GetCanHeal() then
                return true
            end
        end
    end

    return false
end
