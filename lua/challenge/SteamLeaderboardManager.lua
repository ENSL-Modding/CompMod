-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua/challenge/SteamLeaderboardManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A helpful class for dealing with Steam's asynchronous leaderboard functions.  Manages a queue of requests,
--    and sends out callbacks when operations complete.
--
-- ========= For more information, visit us at http:\\www.unknownworlds.com =====================

assert(Client) -- should only be loaded on client.

class 'SteamLeaderboardManager'

-- if an operation fails, but might work if we try again, give it this many attempts.
SteamLeaderboardManager.kMaxAttempts = 5

-- wait 1 second after failures to retry.
SteamLeaderboardManager.kFailTimeout = 1

--------------------------------------------------------------------------------
-------------------------------- PUBLIC METHODS --------------------------------
--------------------------------------------------------------------------------

-- Static global accessor for manager class.  Should really never need more than one instance of this class.
local manager
function GetSteamLeaderboardManager()
    
    if not manager then
        manager = SteamLeaderboardManager()
        manager:Init()
    end
    
    return manager
    
end

local function OnSteamNameReceived(steamId, name)
    
    local self = GetSteamLeaderboardManager()
    self.requestedNames:RemoveElement(steamId)
    self.knownSteamNames[steamId] = name
    
end
Event.Hook("SteamNameReceived", OnSteamNameReceived)
-- Returns the steam name of the given steam id.  If the name is not yet known, a request is
-- sent to Steam, and nil is returned.  You can keep polling this function to get the name if
-- nil is returned.
function SteamLeaderboardManager:GetSteamName(steamId)
    
    if self.knownSteamNames[steamId] then
        return self.knownSteamNames[steamId]
    end
    
    -- Ensure the name is being requested by steam
    if not self.requestedNames:GetIndex(steamId) then
        local result = {}
        if Client.RequestSteamName(steamId, result) then
            -- returned true, meaning we have a result immediately available.
            OnSteamNameReceived(steamId, result.steamName)
        else
            -- we've put out a request for the name, and must now wait for Steam to return.  Make note of requested
            -- names we're waiting on so we don't spam Steam.
            self.requestedNames:Add(steamId)
        end
    end
    
    return nil
    
end

-- Removes all queued requests (excluding any waiting for a reply from Steam) of the given type.
-- Useful to allow players to scroll through scoreboard quickly without having to wait for 8 billion requests to
-- finish.  Allows the most recent request to preempt the others.
function SteamLeaderboardManager:CancelPendingRequestsOfType(typeName)
    
    assert(typeName)
    assert(typeName ~= "")
    
    for i = #self.requestQueue, 2, -1 do -- iterate backwards from the end to the second element.
        if typeName == self.requestQueue[i].type then
            table.remove(self.requestQueue, i)
        end
    end
    
end

-- Whenever Steam returns with a result of a request, it also carries with it the total number of entries
-- in the leaderboard.  This is an accessor for that value.
function SteamLeaderboardManager:GetEntryCount(boardName)
    
    assert(boardName)
    assert(boardName ~= "")
    
    local boardHandle = self.boardNameToHandle[boardName]
    if boardHandle == nil then
        Log("No board handle found for board named '%s'.", boardName)
        return nil
    end
    
    return self.entryCount[boardHandle]
    
end

-- Sends a request to Steam to retrieve this player's entry for the leaderboard. Returns true if
-- request is enqueued successfully, false if there was an issue. When the reply is received,
-- callbackFunc is called with two parameters: a boolean, and a table of leaderboard entries.
-- The boolean is true if successful, or false if the request failed. The second parameter is an
-- array-like table (nil if success == false), with each element being another table containing
-- the following fields:
--      number  steamId
--      number  globalRank (eg #1 is player with best score)
--      number  score
--      string  ugcHandle (User Generated Content handle, eg the skulk challenge replays)
--      table   details (array of numbers for extra information about player's score,
--          eg max speed, number of kills, etc.)
function SteamLeaderboardManager:RequestPlayerScore(boardName, callbackFunc)
    
    assert(boardName)
    assert(boardName ~= "")
    assert(callbackFunc)
    
    local newRequest = {}
    newRequest.type = "GetPlayerScore"
    newRequest.boardName = boardName
    newRequest.callbackFunc = callbackFunc
    self:EnqueueRequest(newRequest)
    
end

-- Sends a request to Steam to retrieve leaderboard entries within the given range of rankings.
-- Steam can only return what exists.  If no entries exist within the specified range, an empty
-- list will be returned.
-- See RequestPlayerScore for format of callbackFunc parameter.
function SteamLeaderboardManager:RequestRangeOfScores(boardName, rangeStart, rangeEnd, callbackFunc)
    
    assert(rangeStart)
    assert(rangeEnd)
    assert(rangeStart > 0)
    assert(rangeEnd >= rangeStart)
    assert(boardName)
    assert(boardName ~= "")
    assert(callbackFunc)
    
    local newRequest = {}
    newRequest.type = "GetRangeOfScores"
    newRequest.boardName = boardName
    newRequest.rangeStart = rangeStart
    newRequest.rangeEnd = rangeEnd
    newRequest.callbackFunc = callbackFunc
    self:EnqueueRequest(newRequest)
    
end

-- Sends a request to Steam to retrieve leaderboard entries surrounding the player's own leaderboard entry.
-- For example, if frontCount is 4, and backCount is 5, this will (potentially) yield a list of 10 entries
-- (the user is included in this list).  Also, Steam will automatically adjust the frontCount and backCount
-- if the requested counts are not possible, to preserve the total entry count.  For example, if frontCount
-- is 4, and backCount is 5, that's 10 total entries, but if player is rank 2, then we cannot retrieve 4
-- in front of player.  The frontCount is adjusted to 1, and backCount is adjusted to 8.
-- See RequestPlayerScore for format of callbackFunc parameter.
function SteamLeaderboardManager:RequestScoresAroundPlayer(boardName, frontCount, backCount, callbackFunc)
    
    assert(boardName)
    assert(boardName ~= "")
    assert(callbackFunc)
    assert(frontCount >= 0)
    assert(backCount >= 0)
    
    local newRequest = {}
    newRequest.type = "GetScoresAroundPlayer"
    newRequest.boardName = boardName
    newRequest.frontCount = frontCount
    newRequest.backCount = backCount
    newRequest.callbackFunc = callbackFunc
    self:EnqueueRequest(newRequest)
    
end

-- Sends a request to Steam to download all leaderboard entries associated with friends of the user for this
-- board.
-- See RequestPlayerScore for format of callbackFunc parameter.
function SteamLeaderboardManager:RequestFriendScores(boardName, callbackFunc)
    
    assert(boardName)
    assert(boardName ~= "")
    assert(callbackFunc)
    
    local newRequest = {}
    newRequest.type = "GetFriendScores"
    newRequest.boardName = boardName
    newRequest.callbackFunc = callbackFunc
    self:EnqueueRequest(newRequest)
    
end

-- Sends the score to Steam.  Steam automatically decides based on the leaderboard's settings whether or not the
-- score is better or should be discarded, so no need to check this ahead of time. Parameter score is just a number
-- value (it should be an integer).  Parameter scoreExtras should be a table of integers, but can be nil.  Extra values
-- are extra information about how a player obtained the score (eg number of kills, max speed, etc.)
-- The callbackFunc function is called upon receipt of successful confirmation from Steam, and will have two parameters:
-- success and uploadResult.  Success is a boolean, true if the score uploaded successfully, false if the operation
-- failed.  Note that the SteamLeaderboardManager class already attempts several retries.  The callback is only called
-- once it gives up and fails for good.
-- Parameter uploadResult is a table (nil if success == false) that holds 5 named values:
--      string  handle          the handle of the leaderboard this score was just added to.
--      number  score           the score that was added (or attempted to be added) to the leaderboard.
--      boolean changed         true if this score was better than the previous one, or false if it was worse or the same.
--      number  globalRank      the player's new ranking (only valid if changed == true)
--      number  prevGlobalRank  the player's old ranking (only valid if changed == true)
-- NOTE: It is tempting to use globalRank and prevGlobalRank even when changed == false, as they may be nonzero and appear
-- valid.  This is UNRELIABLE!  It sometimes shows 0 for both.  You should instead request the player's score from the 
-- leaderboard again to ensure the data is correct.
function SteamLeaderboardManager:UploadScore(boardName, score, scoreExtras, callbackFunc)
    
    assert(boardName)
    assert(boardName ~= "")
    assert(score)
    assert(callbackFunc)
    
    scoreExtras = scoreExtras or {} -- default to empty table
    
    local newRequest = {}
    newRequest.type = "UploadScore"
    newRequest.boardName = boardName
    newRequest.callbackFunc = callbackFunc
    newRequest.score = score
    newRequest.scoreExtras = scoreExtras
    self:EnqueueRequest(newRequest)
    
end

-- Attempts to convert the given replayTable into binary data, then upload that to steam cloud under the given fileName.
-- As usual, first parameter with callbackFunc is true/false for if the operation was successful or not.  Then, if true,
-- the next 2 parameters are ugcHandle and fileName.  Parameter ugcHandle is a unique identifier (64-bit unsigned integer,
-- expressed as a string) steam uses to keep track of the file.  Parameter fileName will match what was given.
function SteamLeaderboardManager:UploadReplay(fileName, replayTable, replayType, callbackFunc)
    
    assert(fileName)
    assert(fileName ~= "")
    assert(replayTable)
    assert(replayType)
    assert(callbackFunc)
    
    local newRequest = {}
    newRequest.type = "UploadReplay"
    newRequest.callbackFunc = callbackFunc
    newRequest.fileName = fileName
    newRequest.replayTable = replayTable
    newRequest.replayType = replayType
    self:EnqueueRequest(newRequest)
    
end

-- Attempts to associate the given UGC handle with the player's entry on the given leaderboard.
-- As usual, first parameter given to callbackFunc is true if successful, false if failed.  If
-- it failed, the second parameter is an error code for why the failure occurred.  There is no
-- second parameter for success.
function SteamLeaderboardManager:AttachUGCToLeaderboard(ugcHandle, boardName, callbackFunc)
    
    assert(ugcHandle)
    assert(ugcHandle ~= "")
    assert(boardName)
    assert(boardName ~= "")
    assert(callbackFunc)
    
    local newRequest = {}
    newRequest.type = "AttachUGC"
    newRequest.callbackFunc = callbackFunc
    newRequest.ugcHandle = ugcHandle
    newRequest.boardName = boardName
    self:EnqueueRequest(newRequest)
    
end

-- Tells Steam to begin downloading the UGC.  The download progress can be checked with
-- Client.GetUGCDownloadProgress (see api docs for details).
-- Parameter callbackFunc is called when download completes, first parameter is true if download was successful,
-- false if it failed.  If true, second parameter is the ugcFileHandle that finished downloading (should match
-- input), and third parameter is the file size, in bytes, of the file downloaded.  If download was unsuccessful,
-- the second parameter is an error code.
function SteamLeaderboardManager:DownloadUGC(ugcHandle, callbackFunc)
    
    assert(ugcHandle)
    assert(ugcHandle ~= "")
    assert(callbackFunc)
    
    local newRequest = {}
    newRequest.type = "DownloadUGC"
    newRequest.callbackFunc = callbackFunc
    newRequest.ugcHandle = ugcHandle
    self:EnqueueRequest(newRequest)
    
end

--------------------------------------------------------------------------------
-------------------------------- PRIVATE METHODS -------------------------------
--------------------------------------------------------------------------------

-- Request type names
--      LeaderboardHandle       -- retrieve the leaderboard handle value from steam for the leaderboard of a given name.
--      GetPlayerScore          -- retrieve only the current player's score, and no one else's.
--      GetRangeOfScores        -- retrieve a range of scores based on rank.
--      GetScoresAroundPlayer   -- retrieve a set of score around the player's entry
--      GetFriendScores         -- retrieve the scores of ALL steam friends.
--      UploadScore             -- upload a score to the leaderboard.
--      UploadReplay            -- converts a replay table to binary data (VERY strict format), and uploads it to steam
--                                  cloud.
--      AttachUGC               -- associates the given UGC handle with the player's entry on the given leaderboard.
--      DownloadUGC             -- downloads the steam cloud file associated with the given UGC handle.

-- Constructor.
function SteamLeaderboardManager:Init()
    
    self.boardNameToHandle = {} -- name -> handle lookup table
    self.badBoardNames = {} -- leaderboard names that have definitively failed, and should not be re-queried.
    
    self.requestedNames = UnorderedSet() -- names requested from Steam.
    self.knownSteamNames = {} -- id -> name string lookup table.
    
    self.requestQueue = {} -- stores pending steam requests of various types.
    self.requestRetryDelay = nil -- either nil or a delay for when we should re-attempt our last failed request.
    self.attemptNumber = 1 -- stores the attempt number for the current request.
    
    self.entryCount = {} -- stores the number of entries in the leaderboard.  Unknown until steam returns after a query.
    
end

function SteamLeaderboardManager:UpdateEntryCount(boardHandle)
    
    self.entryCount[boardHandle] = Client.GetNumLeaderboardEntries(boardHandle)
    
end

-- Sets up the manager to pause for a certain amount of time before retrying a request, and keeps track
-- of the number of attempts that have been made.  Returns true if another attempt will be made, or false
-- if all attempts have been exhausted.
function SteamLeaderboardManager:DelayReattempt()
    
    if self.attemptNumber >= self.kMaxAttempts then
        self.attemptNumber = 1
        return false
    end
    
    self.attemptNumber = self.attemptNumber + 1
    self.requestRetryDelay = self.kFailTimeout
    return true
    
end

function SteamLeaderboardManager:Update(deltaTime)
    
    if self.requestRetryDelay ~= nil then
        
        self.requestRetryDelay = self.requestRetryDelay - deltaTime
        
        if self.requestRetryDelay <= 0.0 then
            self.requestRetryDelay = nil
            self:ProcessNextRequest()
        end
        
    end
    
end
local function OnUpdateClient(deltaTime)
    GetSteamLeaderboardManager():Update(deltaTime)
end
Event.Hook("UpdateClient", OnUpdateClient)

function SteamLeaderboardManager:ProcessRequest_LeaderboardHandle(request)
    Client.GetLeaderboardHandleByName(request.boardName)
    return true
end

function SteamLeaderboardManager:ProcessRequest_GetPlayerScore(request)
    return Client.DownloadGlobalLeaderboardEntriesAroundPlayer(self.boardNameToHandle[request.boardName], 0, 0)
end

function SteamLeaderboardManager:ProcessRequest_GetRangeOfScores(request)
    return Client.DownloadGlobalLeaderboardEntries(self.boardNameToHandle[request.boardName], request.rangeStart, request.rangeEnd)
end

function SteamLeaderboardManager:ProcessRequest_GetScoresAroundPlayer(request)
    return Client.DownloadGlobalLeaderboardEntries(self.boardNameToHandle[request.boardName], request.frontCount, request.backCount)
end

function SteamLeaderboardManager:ProcessRequest_GetFriendScores(request)
    return Client.DownloadFriendsLeaderboardEntries(self.boardNameToHandle[request.boardName])
end

function SteamLeaderboardManager:ProcessRequest_UploadScore(request)
    Client.UploadScoreToLeaderboard(self.boardNameToHandle[request.boardName], request.score, request.scoreExtras)
    return true
end

function SteamLeaderboardManager:ProcessRequest_UploadReplay(request)
    return Client.UploadReplay(request.fileName, request.replayTable, request.replayType)
end

function SteamLeaderboardManager:ProcessRequest_AttachUGC(request)
    return Client.AttachUGCToLeaderboard(request.ugcHandle, self.boardNameToHandle[request.boardName])
end

function SteamLeaderboardManager:ProcessRequest_DownloadUGC(request)
    return Client.DownloadUGC(request.ugcHandle)
end

-- Performs the next request in the queue.
function SteamLeaderboardManager:ProcessNextRequest()
    
    local request = self.requestQueue[1]
    if not request then
        -- no more requests queued up.
        return
    end
    
    assert(request.type ~= nil)
    
    if request.type ~= "LeaderboardHandle" and request.boardName ~= nil then
        -- ensure we have a valid board handle for this board name... otherwise we gotta do that one first.
        if not self:CheckBoardName(request.boardName) then
            -- board name is invalid (not just missing).  Discard request.
            assert(request == self.requestQueue[1])
            table.remove(self.requestQueue, 1)
            self:ProcessNextRequest()
            return
        end
        
        if request ~= self.requestQueue[1] then
            -- our request is no longer the most urgent... do the most recent request first.
            self:ProcessNextRequest()
            return
        end
        
    end
    
    -- If we make it to here, we're good to go, and should process request now.  We process each type with a different
    -- function.  The name of the function is derived from the type of request.
    local functionName = "ProcessRequest_" .. request.type
    if self[functionName](self, request) == false then
        -- Something is wrong with the request, we cannot retry.
        Log("Unable to process request '%s'!", request.type)
        table.remove(self.requestQueue, 1)
        self:ProcessNextRequest()
        return
    end
    
end

-- Adds the request (table) to the request queue.
function SteamLeaderboardManager:EnqueueRequest(newRequest)
    
    self.requestQueue[#self.requestQueue+1] = newRequest
    
    if #self.requestQueue == 1 then
        self:ProcessNextRequest()
    end
    
end

-- Adds the request (table) to the front of the request queue.
function SteamLeaderboardManager:EnqueueRequestImmediate(newRequest)
    
    table.insert(self.requestQueue, 1, newRequest)
    
    if #self.requestQueue == 1 then
        self:ProcessNextRequest()
    end
    
end

-- Checks to ensure the board name has a handle associated with it.  If not, it sends the request to
-- steam to check the name.  Returns false if the board name is invalid (definitively missing, not just IO failure),
-- true if all is well.
function SteamLeaderboardManager:CheckBoardName(boardName)
    if self.boardNameToHandle[boardName] then
        -- This board name already has a handle, we're good to proceed.
        return true
    end
    
    if self.badBoardNames[boardName] then
        -- board is definitively missing, we should discard any requests using this board name.
        return false
    end
    
    local newRequest = {}
    newRequest.type = "LeaderboardHandle"
    newRequest.boardName = boardName
    self:EnqueueRequestImmediate(newRequest)
    
    -- We don't have a handle yet, but we've just put in the request, so it should be ready by the time
    -- the other request is put through.
    return true
    
end

-- Handles which behavior needs to occur when an asynchronous request comes back successful.
function SteamLeaderboardManager:OnSuccess()
    
    -- Update the amount of entries this steam leaderboard has.
    local request = self.requestQueue[1]
    if request.boardName then
        local boardHandle = self.boardNameToHandle[request.boardName]
        if boardHandle then
            self:UpdateEntryCount(boardHandle)
        end
    end
    
    self.attemptNumber = 1
    table.remove(self.requestQueue, 1)
    
    self:ProcessNextRequest()
    
end

-- Handles which behavior needs to occur when an asynchronous request fails.
-- errorCode is optional, and will only be used if it fails for good.
function SteamLeaderboardManager:OnFail(errorCode)
    
    if not self:DelayReattempt() then
        local request = self.requestQueue[1]
        if request.callbackFunc then
            request.callbackFunc(false, errorCode)
        end
        
        table.remove(self.requestQueue, 1)
        self:ProcessNextRequest()
    end
    
end

local function OnLeaderboardFindSuccess(boardHandle)
    
    local self = GetSteamLeaderboardManager()
    local request = self.requestQueue[1]
    
    self.boardNameToHandle[request.boardName] = boardHandle
    
    self:OnSuccess()
    
end
Event.Hook("LeaderboardFindSuccess", OnLeaderboardFindSuccess)

local function OnLeaderboardFindFail(canRetry)
    
    local self = GetSteamLeaderboardManager()
    
    if not canRetry then
        self.attemptNumber = 99999 -- disallow reattempts if there's no point in retrying.
    end
    
    self:OnFail()
    
end
Event.Hook("LeaderboardFindFail", OnLeaderboardFindFail)

local function OnDownloadScoresSuccess(entries)
    
    local self = GetSteamLeaderboardManager()
    local request = self.requestQueue[1]
    
    request.callbackFunc(true, entries)
    
    self:OnSuccess()
    
end
Event.Hook("DownloadScoresSuccess", OnDownloadScoresSuccess)

local function OnDownloadScoresFailed()
    
    local self = GetSteamLeaderboardManager()
    self:OnFail()
    
end
Event.Hook("DownloadScoresFailed", OnDownloadScoresFailed)

local function OnLeaderboardUploadSuccess(uploadResult)
    
    local self = GetSteamLeaderboardManager()
    local request = self.requestQueue[1]
    
    request.callbackFunc(true, uploadResult)
    
    self:OnSuccess()
    
end
Event.Hook("LeaderboardUploadSuccess", OnLeaderboardUploadSuccess)

local function OnLeaderboardUploadFail()
    
    local self = GetSteamLeaderboardManager()
    self:OnFail()
    
end
Event.Hook("LeaderboardUploadFail", OnLeaderboardUploadFail)

local function OnShareFileSuccess(ugcHandle, fileName)
    
    local self = GetSteamLeaderboardManager()
    local request = self.requestQueue[1]
    
    request.callbackFunc(true, ugcHandle, fileName)
    
    self:OnSuccess()
    
end
Event.Hook("ShareFileSuccess", OnShareFileSuccess)

local function OnShareFileFailed()
    
    local self = GetSteamLeaderboardManager()
    self:OnFail()
    
end
Event.Hook("ShareFileFailed", OnShareFileFailed)

local function OnUGCAttachSuccess()
    
    local self = GetSteamLeaderboardManager()
    local request = self.requestQueue[1]
    
    request.callbackFunc(true)
    
    self:OnSuccess()
    
end
Event.Hook("UGCAttachSuccess", OnUGCAttachSuccess)

local function OnUGCAttachFail(errorCode)
    
    local self = GetSteamLeaderboardManager()
    self:OnFail(errorCode)
    
end
Event.Hook("UGCAttachFail", OnUGCAttachFail)

local function OnDownloadUGCSuccess(ugcHandle, fileSize)
    
    local self = GetSteamLeaderboardManager()
    local request = self.requestQueue[1]
    
    request.callbackFunc(true, ugcHandle, fileSize)
    
    self:OnSuccess()
    
end
Event.Hook("DownloadUGCSuccess", OnDownloadUGCSuccess)

local function OnDownloadUGCFailed(errorCode)
    
    local self = GetSteamLeaderboardManager()
    self:OnFail(errorCode)
    
end
Event.Hook("DownloadUGCFailed", OnDownloadUGCFailed)

