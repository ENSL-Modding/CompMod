-- The female sprint sounds are backwards in vanilla...
local kSprintStartFemale = Marine.kSprintStartFemale
Marine.kSprintStartFemale = Marine.kSprintTiredEndFemale
Marine.kSprintTiredEndFemale = kSprintStartFemale
