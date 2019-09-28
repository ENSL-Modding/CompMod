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
GUIMenuAvatar:AddClassProperty("_IsRendering", false)

local function OnAvatarDownloaded(self, textureName)
    
    if self.textureName == textureName then
        self:SetTexture(textureName)
    end
    
end

local function OnAvatarDeactivated(self, textureName)
    
    if self.textureName == textureName then
        self:SetTexture(kMissingAvatarTexture)
    end
    
end

local function OnRenderingStarted(self)
    self:Set_IsRendering(true)
end

local function OnRenderingStopped(self)
    self:Set_IsRendering(false)
end

-- Activate the request for the avatar image with the given steam Id... IF it's actually requested.
-- Safe to call this to your heart's content.
local function ActivateRequest(self, steamId)
    
    if self.requestActive then
        return -- No request active
    end
    
    if steamId == "" then
        return -- Invalid steamId
    end
    
    -- Set the texture name we're expecting to receive with OnAvatarDownloaded.  To cover the case
    -- where the avatar is already available, set the texture now, as we won't receive an
    -- OnAvatarDownloaded event, since it's already happened.
    self.textureName = Client.GetTextureNameForAvatar(steamId)
    
    if Client.GetIsAvatarReady(steamId) then
        self:SetTexture(self.textureName)
    else
        self:SetTexture(kMissingAvatarTexture)
    end
    
    Client.ActivateAvatarRequest(steamId)
    self.requestActive = true
    
end

-- Deactivate the request for the avatar image with the given steam Id... IF it's actually
-- requested.  Safe to call this to your heart's content.
local function DeactivateRequest(self, steamId)
    
    if not self.requestActive then
        return -- Request already inactive.
    end
    
    if steamId == "" then
        return -- Invalid steamId
    end
    
    -- Don't clear self.textureName just yet.  The deactivation might be because the avatar stopped
    -- being rendered, not because the steam Id changed.  In this case, we'll be perfectly happy to
    -- keep using the image until it's no longer available, even though we're not asking for it to
    -- be kept around anymore.
    
    Client.DeactivateAvatarRequest(steamId)
    self.requestActive = false
    
end

-- When the steamId changes, we need to make sure we deactivate the previous request, and then maybe
-- request for the new Id.
local function OnSteamID64Changed(self, steamId, prevSteamId)
    
    local steamIdIsValid = steamId ~= ""
    local isRendering = self:Get_IsRendering()
    
    local shouldBeRequested = isRendering and steamIdIsValid
    
    -- The steamId just changed, that means the previous request -- if any -- is no longer valid.
    -- Deactivate the request made with the previous steamId.
    DeactivateRequest(self, prevSteamId)
    self:SetTexture(kMissingAvatarTexture)
    self.textureName = ""
    
    if shouldBeRequested then
        ActivateRequest(self, steamId)
    end
    
end

local function On_IsRenderingChanged(self, isRendering)
    
    local steamId = self:GetSteamID64()
    
    if isRendering then
        ActivateRequest(self, steamId)
    else
        DeactivateRequest(self, steamId)
    end
    
end

function GUIMenuAvatar:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.steamId64, "params.steamId64", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    -- Keep track of the "is rendering" status with a property.
    self:HookEvent(self, "OnRenderingStarted", OnRenderingStarted)
    self:HookEvent(self, "OnRenderingStopped", OnRenderingStopped)
    self:TrackRenderStatus()
    
    -- Only request an avatar if the steam Id is valid (not empty), and the avatar graphic is
    -- visible (eg on-screen, not cropped away, etc).
    self:HookEvent(self, "OnSteamID64Changed", OnSteamID64Changed)
    self:HookEvent(self, "On_IsRenderingChanged", On_IsRenderingChanged)
    
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

function GUIMenuAvatar:Uninitialize()
    
    -- Ensure we've released our request for an avatar image.
    DeactivateRequest(self, self:GetSteamID64())
    
    baseClass.Uninitialize(self)
    
end
