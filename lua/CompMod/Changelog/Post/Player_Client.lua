kCompModVersionKey = "compmod_version"

local kChangelogURL = "https://enslcompmod.github.io/CompMod/"
local kChangelogTitle = "NSL Competitive Mod"

local function showChangeLog()
    if Shine then
        Shine:OpenWebpage(kChangelogURL, kChangelogTitle)
    elseif Client.GetIsSteamOverlayEnabled() then
        Client.ShowWebpage(kChangelogURL)
    elseif CompMod then
        CompMod:Print("Couldn't open changelog because no webview is available", CompMod:GetLogLevels().warn)
    end
end

local oldOnInitLocalClient = Player.OnInitLocalClient
function Player:OnInitLocalClient()
    oldOnInitLocalClient(self)

    local oldVersion = Client.GetOptionString(kCompModVersionKey, "v0")
    local currentVersion = CompMod and CompMod:GetVersion() or "v0"
    if currentVersion > oldVersion then
        Client.SetOptionString(kCompModVersionKey, currentVersion)
        showChangeLog()
    end

end

Event.Hook("Console_changelog", showChangeLog)