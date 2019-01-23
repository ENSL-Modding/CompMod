-- the gorgebuildmessage is registered on script load using a local variable that is declared in the same file
-- so r1p changing it, time to be hacky

local kRandomVector = Vector(0, -1000, 0)

local oldBuildGorgeDropStructureMessage = BuildGorgeDropStructureMessage
function BuildGorgeDropStructureMessage(origin, direction, structureIndex, lastClickedPosition)
  if structureIndex == 6 then
    structureIndex = 5
    lastClickedPosition = kRandomVector
  end
  return oldBuildGorgeDropStructureMessage(origin, direction, structureIndex, lastClickedPosition)
end

local oldParseGorgeBuildMessage = ParseGorgeBuildMessage
function ParseGorgeBuildMessage(t)
  if t.lastClickedPosition == kRandomVector and t.structureIndex == 5 then
    t.lastClickedPosition = Vector(0,0,0)
    t.structureIndex = 6
  end
  return oldParseGorgeBuildMessage(t)
end
