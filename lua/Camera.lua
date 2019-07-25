
class 'CinematicCamera' (Entity)

CinematicCamera.kMapName = "camera_origin"

local networkVars = 
{
    cameraName = "string (256)"
}

function CinematicCamera:OnCreate()
end

function CinematicCamera:OnInitialized()
    
    if Client then
        
        gCameras = gCameras or {}
        
        if self.cameraName == '' then
            Log("Warning!  Detected camera with a blank name!  Skipping.")
            return
        end
        
        if gCameras[self.cameraName] ~= nil then
            Log("Warning!  Detected camera with duplicate name!  Skipping. (name is %s)", self.cameraName)
            return
        else
            gCameras[self.cameraName] = self
        end
        
    end
    
end

Shared.LinkClassToMap("CinematicCamera", CinematicCamera.kMapName, networkVars)