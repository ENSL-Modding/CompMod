kCompModRevisionKey = "compmod_revision"

local kChangelogURL = "https://enslcompmod.github.io/CompMod/"
local kChangelogTitle = "NSL Competitive Mod"
local logger = CompMod:GetModule('logger')
local revision = CompMod:GetModule('versioning'):GetRevision()

local function showChangeLog()
    if Shine then
        Shine:OpenWebpage(kChangelogURL, kChangelogTitle)
    elseif Client.GetIsSteamOverlayEnabled() then
        Client.ShowWebpage(kChangelogURL)
    elseif CompMod then
        logger:PrintWarn("Couldn't open changelog because no webview is available")
    end
end

local oldOnInitLocalClient = Player.OnInitLocalClient
function Player:OnInitLocalClient()
    oldOnInitLocalClient(self)

    local oldRevision = Client.GetOptionInteger(kCompModRevisionKey, 0)
    local currentRevision = revision or "0"
    if currentRevision ~= oldRevision then
        Client.SetOptionInteger(kCompModRevisionKey, currentRevision)
        showChangeLog()
    end

end

Event.Hook("Console_changelog", showChangeLog)