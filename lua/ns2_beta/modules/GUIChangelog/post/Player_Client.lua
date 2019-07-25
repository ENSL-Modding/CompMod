Script.Load("lua/ns2_beta/modules/GUIChangelog/new/GUIModChangelog.lua")

kBetaModVersionKey = "betamod_version"

local function showChangeLog()
    MainMenu_Open()
    local mm = GetGUIMainMenu and GetGUIMainMenu()
    if mm then
        local changeLog = CreateMenuElement(mm.mainWindow, "GUIModChangelog")
        changeLog:SetIsVisible(true)
    end
end

local oldOnInitLocalClient = Player.OnInitLocalClient
function Player:OnInitLocalClient()
    oldOnInitLocalClient(self)

    local oldVersion = Client.GetOptionInteger(kBetaModVersionKey, 0)
    if kBetaVersion > oldVersion then
        Client.SetOptionInteger(kBetaModVersionKey, kBetaVersion)
        showChangeLog()
    end

end

Event.Hook("Console_changelog", showChangeLog)