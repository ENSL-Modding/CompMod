--[[

    team.TechColors was set improperly here.

    The last entry should be for ShadeHive but it was being set as CragHive.

]]

local kRed = Color(1, 0, 0, 1)
function GUIInsight_PlayerFrames:UpdateTechColors(team)
    local teamNumber = team.TeamNumber
    local teamColor = PlayerUI_GetTeamColor(teamNumber)
    team.TechColors = {
        [0] = teamColor,
        [kTechId.CragHive] = GetShellLevel(teamNumber) == 0 and kRed or teamColor ,
        [kTechId.ShiftHive] = GetSpurLevel(teamNumber) == 0 and kRed or teamColor,
        --[kTechId.CragHive] = GetVeilLevel(teamNumber) == 0 and kRed or teamColor
        [kTechId.ShadeHive] = GetVeilLevel(teamNumber) == 0 and kRed or teamColor
    }
end