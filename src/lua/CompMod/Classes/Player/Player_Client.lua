local kCompModRevisionKey = "compmod_revision"
local kChangelogTitle = "NSL Competitive Mod"
local kChangelogURL = "https://enslcompmod.github.io/CompMod/changelog"
local kChangelogDetailURL = "https://enslcompmod.github.io/CompMod/revisions/revision" .. g_compModRevision .. ".html"

local function showChangeLog(withDetail)
    withDetail = withDetail or false
    local url = withDetail and kChangelogDetailURL or kChangelogURL

    if Shine then
        Shine:OpenWebpage(url, kChangelogTitle)
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
    if g_compModRevision > oldRevision then
        Client.SetOptionInteger(kCompModRevisionKey, g_compModRevision)
        showChangeLog(true)
    end
end

Event.Hook("Console_changelog", showChangeLog)
