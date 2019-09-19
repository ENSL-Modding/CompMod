-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/PlayerScreen/FriendsList/GUIMenuAvatar.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Graphic that is used to display the avatar of a steam player.  Will display a missing avatar
--    image (a question mark icon if I remember right) unless the steam player's picture is loaded.
--    If the steam player's picture is not loaded it is automatically requested whenever this object
--    is being rendered (eg is visible, is not cropped away, and is on-screen).
--
--  Parameters (* = required)
--      steamId64
--
--  Properties
--      SteamID64       Steam id of the player.
--
--  Events
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")

---@class GUIMenuAvatar : GUIObject
local baseClass = GUIObject
class "GUIMenuAvatar" (baseClass)

local kMissingAvatarTexture = PrecacheAsset("ui/missing_avatar.dds")

GUIMenuAvatar:AddClassProperty("SteamID64", "")

local function RequestAvatar(self)
    
    local steam64 = self:GetSteamID64()
    if steam64 == "" then
        return -- invalid steam ID, nothing to do right now.
    end
    
    local steam32 = Client.ConvertSteamId64To32(steam64)
    self.textureName = "*"..steam64
    
    -- Set texture to the missing texture in the interim.
    self:SetTexture(kMissingAvatarTexture)
    
    Client.RequestAvatarImageForPlayer(steam32, self.textureName)
    
end

local function OnAvatarDownloaded(self, textureName)
    
    assert(textureName ~= nil)
    if self.textureName == textureName then
        self:SetTexture(textureName)
    end
    
end

local function OnAvatarDeactivated(self, textureName)
    
    assert(textureName ~= nil)
    if self.textureName == textureName then
        self:SetTexture(kMissingAvatarTexture)
        self.textureName = nil
    end
    
end

function GUIMenuAvatar:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.steamId64, "params.steamId64", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    -- Whenever this object becomes visible, request the avatar.  Don't bother with un-requesting it
    -- when we stop rendering.  No point... it'll get kicked out automatically if other avatars need
    -- the slots.
    self:HookEvent(self, "OnRenderingStarted", RequestAvatar)
    self:TrackRenderStatus()
    
    -- Whenever the steamid changes, request the avatar.
    self:HookEvent(self, "OnSteamID64Changed", RequestAvatar)
    
    self:SetTexture(kMissingAvatarTexture)
    self:SetColor(1, 1, 1, 1)
    self:SetOpacity(1)
    
    -- Whenever an avatar image is done downloading, see if it's ours and if so, set the texture.
    self:HookEvent(GetGlobalEventDispatcher(), "OnAvatarDownloaded", OnAvatarDownloaded)
    
    -- Whenever an avatar image is kicked out of the active set (to make room for more recent
    -- requests), set the texture back to the missing avatar texture.
    self:HookEvent(GetGlobalEventDispatcher(), "OnAvatarDeactivated", OnAvatarDeactivated)
    
    if params.steamId64 then
        self:SetSteamID64(params.steamId64)
    end
    
end
