-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/challenge/ReplayManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Manages a cache of downloaded replays for the challenge game modes.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kMaxEntries = 10 -- max other player entries to cache before discarding the oldest.

local manager
function GetReplayManager()
    
    if not manager then
        manager = ReplayManager()
        manager:Initialize()
    end
    
    return manager
    
end

class 'ReplayManager'

function ReplayManager:Initialize()
    
    self.playerReplayEntry = nil
    self.replayEntries = {}
    
end

-- clears all replays except the player's local copy
function ReplayManager:ClearCachedReplaysFromLeaderboard()
    
    self.replayEntries = {}
    
end

-- Store a replay for the given steam id.  For the player's last run (not necessarily the one they have on the leaderboard,
-- pass nil for steamId to have this replay stored separately).
function ReplayManager:AddReplay(replayData, steamId)
    
    local replayEntry = {}
    replayEntry.data = replayData
    replayEntry.id = steamId
    
    -- store player's last run separately -- so it is never overwritten.
    if steamId == nil then
        self.playerReplayEntry = replayEntry
        return
    end
    
    -- remove other entries with the same id from the list
    for i=#self.replayEntries, 1, -1 do
        if self.replayEntries[i].id == steamId then
            table.remove(self.replayEntries, i)
        end
    end
    
    -- remove oldest entry to make room, if needed
    while #self.replayEntries > kMaxEntries do
        table.remove(self.replayEntries, 1)
    end
    
    table.insert(self.replayEntries, replayEntry)
    
end

function ReplayManager:GetReplay(steamId)
    
    if steamId == nil and self.playerReplayEntry then
        return self.playerReplayEntry.data
    end
    
    for i=1, #self.replayEntries do
        if self.replayEntries[i].id == steamId then
            return self.replayEntries[i].data
        end
    end
    
    return nil
    
end
