local logger = CompMod:GetModule('logger')
local currentRevision = CompMod:GetModule('versioning'):GetRevision()

local kCompModRevisionKey = "compmod_revision"
local kChangelogTitle = "NSL Competitive Mod"
local kChangelogURL = "https://enslcompmod.github.io/CompMod/changelog"
local kChangelogDetailURL = "https://enslcompmod.github.io/CompMod/revisions/revision" .. currentRevision .. ".md"

local function showChangeLog(withDetail)
    withDetail = withDetail or false
    local url = withDetail and kChangelogDetailURL or kChangelogURL

    if Shine then
        Shine:OpenWebpage(url, kChangelogTitle)
    elseif Client.GetIsSteamOverlayEnabled() then
        Client.ShowWebpage(url)
    elseif CompMod then
        logger:PrintWarn("Couldn't open changelog because no webview is available")
    end
end

local oldOnInitLocalClient = Player.OnInitLocalClient
function Player:OnInitLocalClient()
    oldOnInitLocalClient(self)

    local oldRevision = Client.GetOptionInteger(kCompModRevisionKey, -1)
    if currentRevision > oldRevision then
        Client.SetOptionInteger(kCompModRevisionKey, currentRevision)
        showChangeLog(true)
    end
end

Event.Hook("Console_changelog", showChangeLog)
