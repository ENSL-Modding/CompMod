gActiveLobby = nil
gLobbyJoinDesired = nil

gDebugMatchmakingLobby = false
gUseMatchmakingLobby = false
gShowMatchmakingCount = false

function MMPrint(...)
    if gDebugMatchmakingLobby then
        RawPrint( ... )
    end
end
            
function Matchmaking_JoinGlobalLobby()
    if not gUseMatchmakingLobby then return end
    
    MMPrint( "Joining Global Lobby" )
    gLobbyJoinDesired = true
    
    if not gActiveLobby then
        Client.RebuildLobbyList()
    end
end

function Matchmaking_JoinGlobalLobby_RebuildListResponse( list )
    if not gUseMatchmakingLobby then return end
    if not gLobbyJoinDesired then return end
    
    MMPrint( "Found Lobbies: " )
    local max, lobby
    for i,v in ipairs(list) do        
        local np = Client.GetNumLobbyMembers( v )
        MMPrint( i, v, np )
        if not max or max < np then
            max,lobby = np, v
        end
    end
    
    if lobby then
        MMPrint( "Joining Lobby", lobby )
        Client.JoinLobby( lobby )
    else
        MMPrint( "Creating Lobby" )
        Client.CreateLobby( Client.SteamLobbyType_Public, Client.SteamLobbyMaxUserSlots )
    end
end

function Matchmaking_JoinGlobalLobby_JoinedResponse( lobby )
    if not gUseMatchmakingLobby then return end
    
    if not gLobbyJoinDesired then 
        Client.LeaveLobby( lobby )
    end
    
    gActiveLobby = lobby
end

function Matchmaking_LeaveGlobalLobby()
    if not gUseMatchmakingLobby then return end
    
    MMPrint( "Leaving Global Lobby" )
    gLobbyJoinDesired = false
    
    if gActiveLobby then
        Client.LeaveLobby( gActiveLobby )
        gActiveLobby = nil
    end
end

function Matchmaking_GetNumInGlobalLobby()    
    return gShowMatchmakingCount and gActiveLobby and Client.GetNumLobbyMembers( gActiveLobby )
end
    
Event.Hook("OnLobbyListResults", Matchmaking_JoinGlobalLobby_RebuildListResponse )
Event.Hook("OnLobbyCreated", Matchmaking_JoinGlobalLobby_JoinedResponse )
Event.Hook("OnLobbyMessage", function() end )
Event.Hook("OnLobbyClientEnter", Matchmaking_JoinGlobalLobby_JoinedResponse )
Event.Hook("ClientDisconnected", Matchmaking_LeaveGlobalLobby )

--[[
Event.Hook("LobbyMessageReceived", function( lobby, message ) MMPrint( lobby, message ) end )
Event.Hook( "Console_lobbysay", function( ... ) 
    if gActiveLobby then
        local chatMessage = StringConcatArgs(...)
        Client.SendLobbyMessage( gActiveLobby, chatMessage )
    end
end)
--]]