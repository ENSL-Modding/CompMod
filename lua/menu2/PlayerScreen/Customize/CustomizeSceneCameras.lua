-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/PlayerScreen/Customize/CustomizeSceneCameras.lua
--
--    Created by:   Brock Gillespie (brock@naturalselection2.com)
--
--    TODO Add doc/descriptor
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================



local kUpVec = Vector(0,1,0)

local camModel = PrecacheAsset("models/system/editor/camera_origin.model") --for Debugging

local debugCameraPositionTeam1 = Vector( 0, 2.1, -2.63 )
local debugCameraTargetTeam1 = Vector( 0.04, 1.45, 7.75 )

local debugCameraPositionTeam2 = Vector( 0, -5.1, -3.6 )
local debugCameraTargetTeam2 = Vector( 0.0, -13.45, 17.75 )

local debugCameraFov_Team1 = math.rad( 96 )
local debugCameraFov_Team2 = math.rad( 98 )

local debugCamCoords_Team1 = Coords.GetLookAt( debugCameraPositionTeam1, debugCameraTargetTeam1, kUpVec )
local debugCamCoords_Team2 = Coords.GetLookAt( debugCameraPositionTeam2, debugCameraTargetTeam2, kUpVec )


---@class CameraTransition
class "CameraTransition"

 
function CameraTransition:Init( targetView, fromView, curOrg, curTarget, curFov, isTeamViewChange )
    assert( gCustomizeSceneData.kCameraViewPositions[targetView] )

    local targetViewData = gCustomizeSceneData.kCameraViewPositions[targetView]
    self.destOrigin = targetViewData.origin --Targeted Camera position
    self.destTarget = targetViewData.target --Targeted "LookAt" point
    self.destFov = targetViewData.fov
    self.animTime = targetViewData.animTime

    --Time to only change lookat-target, and not actually move the camera position
    --movement delay is to allow for Camera rotation first
    self.camMoveDelayTime = targetViewData.startMoveDelay and targetViewData.startMoveDelay or 0
    self.startTime = Shared.GetTime()

    self.interruptTransition = false

    if fromView then
        local fromViewData = gCustomizeSceneData.kCameraViewPositions[fromView]
        self.origin = fromViewData.origin
        self.originTarget = fromViewData.target
        self.originFov = fromViewData.fov
    else
        self.origin = curOrg
        self.originTarget = curTarget
        self.originFov = curFov

        --denotes this has no fromView label, it was mid-transition when new view
        --transition was triggered. Thus, derived from active camrea data "mid-flight"
        self.interruptTransition = true
    end

    self.activeOrigin = nil
    self.activeTarget = nil

    --Cache the requested target-view for cases when transitioning from one team to another's views
    self.requestedTargetView = targetView

    self.isTeamViewChange = isTeamViewChange

    self.targetView = isTeamViewChange and gCustomizeSceneData.kTeamViews.TeamTransition or targetView
    self.originView = fromView

    --Log("\t isTeamViewChange: %s", isTeamViewChange)
    --Log("\t self.targetView: %s", EnumToString(gCustomizeSceneData.kViewLabels, self.targetView ) )
    --Log("\t self.originView: %s", EnumToString(gCustomizeSceneData.kViewLabels, self.originView) )

    self.callbackActivationDist = targetViewData.activationDist and targetViewData.activationDist or 0

    --Must init Coords to origin, otherwise interruptTransition would cause huge jitter
    self.coords = Coords.GetLookAt( self.origin, self.originTarget, kUpVec )
    self.fov = self.originFov

    --Log("\t self.coords: %s", self.coords)
    --Log("\t self.fov: %s", self.fov)

    self.complete = false

    --self.targetOrigHalfDist = Vector(self.destOrigin - self.origin):GetLength() * 0.5
    --self.targetLookHalfDist = Vector(self.destTarget - self.originTarget):GetLength() * 0.5

    self.isTargetDefault = targetView == gCustomizeSceneData.KDefaultViewLabel

    self.distanceActivatedCallback = nil
    self.triggeredCallback = false

end

function CameraTransition:SetDistanceActivationCallback( callback )
    self.distanceActivatedCallback = callback
end

function CameraTransition:GetTargetView()
    return self.targetView
end

function CameraTransition:GetIsInterrupt()
    return self.interruptTransition
end

function CameraTransition:GetOriginView()
    return self.originView
end

function CameraTransition:GetTargetData()
    return { origin = self.destOrigin, target = self.destTarget, fov = self.destFov }
end

function CameraTransition:GetOriginData()
    return { origin = self.origin, target = self.originTarget, fov = self.originFov }
end

function CameraTransition:TriggerCallback()
    if self.distanceActivatedCallback then
        self:distanceActivatedCallback( self.targetView )
    end
end

function CameraTransition:GetCoords()
    return self.coords
end

function CameraTransition:GetFov()
    return self.fov
end

--Special-case handler for when moving from one Team-view to another.
--effectively "resets" this transition to eliminate need to make a new one
function CameraTransition:HandleTeamViewTransition()
    --Log("CameraTransition:HandleTeamViewTransition()")
    local coords = self:GetCoords()
    local fov = self:GetFov()
    local targ = self:GetTargetData()

    --Log("\t Changing to target: %s", EnumToString(gCustomizeSceneData.kViewLabels, self.requestedTargetView))
    self:Init( self.requestedTargetView, nil, coords.origin, targ.target, targ.fov, false )

end

local vecChangeSpeed = 0.05
--FIXME This needs to handle camera YAW separate, because things will get fucky otherwise (no smooth turning/panning, etc)
--FIXME Camera YAW _MUST_ be controled, otherwise it may rotate towards "empty" parts of the customize level!
function CameraTransition:Update(deltaTime, scene)

    --local accel = self.destTarget:GetDistance(self.prevLookAt) <= 1 and 0.095 or 0.034
    local accel = 0.125 --TODO Add debug command to override default
    if self.isTeamViewChange then
        accel = 0.0365
    end
    --TODO Lerp this slightly increasing nearer to target

    local preDist = self.coords.origin:GetDistance( self.destOrigin )
    local totalDist = self.origin:GetDistance( self.destOrigin ) --XXX doesn't need to be done each update
    local positionUpdateAllowed = self.startTime + self.camMoveDelayTime <= Shared.GetTime()
    positionUpdateAllowed = true

    local distPerct = preDist / totalDist
    local targDistPerct = self.prevLookAt and ( self.destTarget:GetDistance(self.prevLookAt) ) or 1 --self.destTarget:GetDistance(self.originTarget)
    --FIXME compute self.prevLookAt value
    ----TODO for above, ensure lookat-rotation is ALWAYS positive ( to force camera to always look "into" the scene)

    local lookTarget = ( deltaTime * (targDistPerct + accel) ) * GetNormalizedVector( self.coords.zAxis ) + self.destTarget
    --local lookTarget = ( deltaTime * targDistPerct ) * GetNormalizedVector( self.coords.zAxis ) + self.destTarget

    local newOrigin
    if positionUpdateAllowed then
        newOrigin = self.coords.origin + ( self.destOrigin - self.coords.origin ) * (deltaTime + accel) 
    else
        newOrigin = self.origin
    end
    
    if self.fov ~= self.destFov then 
        self.fov = Slerp( self.fov, self.destFov, deltaTime * (self.animTime / targDistPerct) )
    end

    local targetDist = self.coords.origin:GetDistance( self.destOrigin )

    if self.distanceActivatedCallback ~= nil then

        if targetDist <= self.callbackActivationDist and not self.triggeredCallback then

            self:TriggerCallback()
            self.triggeredCallback = true

            --Special case for team-transition view(s). Only applies when targetview doesn't match desired team-view
            if self.isTeamViewChange then --FIXME This is not ALWAYS true/false
                self:HandleTeamViewTransition()
                return --exit out immediately and refresh on next update
            end

        end

    end

    self.coords = Coords.GetLookAt( newOrigin, lookTarget, kUpVec )

    if distPerct < 0.00075 then --Cheesy, but it works. Only causes slight "snap" when very close to visible focused object (e.g. shoulder patches view)
        self.coords = Coords.GetLookAt( self.destOrigin, self.destTarget, kUpVec )
        self.complete = true
    end

    scene:SetCameraPerspective( self.coords, self.fov )

    return self.complete

end

