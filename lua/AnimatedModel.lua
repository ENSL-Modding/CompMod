-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\AnimatedModel.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")

class 'AnimatedModel'

local animatedModel

function CreateAnimatedModel(modelName, renderScene)

    local modelPath = PrecacheAsset(modelName)
    if animatedModel ~= nil then
        animatedModel:OnInitialized(modelPath, renderScene)
    elseif animatedModel == nil then
        animatedModel = AnimatedModel()
        animatedModel:OnInitialized(modelPath, renderScene)
    end
    
    return animatedModel
            
end

function AnimatedModel:OnInitialized(modelName, renderScene)

    if renderScene ~= nil then
        self.renderModel = Client.CreateRenderModel(renderScene)
    else
        self.renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)
    end

    self.modelIndex = Shared.GetModelIndex(modelName)
    if self.modelIndex == 0 then
        self.modelIndex = Shared.LoadModel(modelName)
    end

    self.modelName = modelName
    
	self.renderModel:SetModel( self.modelIndex )

    self.animationName = nil
    
    self.animationTime = 0
	
    self.poseParams = PoseParams()
    
    self.staticAnim = false
    
    self.additiveMaterials = {}

end

function AnimatedModel:SetCoords(coords)
    assert(self.renderModel)
    assert(coords and coords:GetIsFinite())
    if self.renderModel ~= nil then
        self.renderModel:SetCoords(coords)
    end
end

function AnimatedModel:GetCoords()
    assert(self.renderModel)
    return self.renderModel:GetCoords()
end

function AnimatedModel:SetIsVisible(visible)
    if self.renderModel ~= nil then
        self.renderModel:SetIsVisible(visible)
    end
end

function AnimatedModel:SetAnimation(animationName)
    self.animationName = ToString(animationName)
    self.animationTime = 0
end

function AnimatedModel:SetPoseParam(name, value)
    local success = false
    local paramIndex = self:GetPoseParamIndex(name)

    if (paramIndex ~= -1) then
        self.poseParams:Set(paramIndex, value)
        success = true
    else
        Print("AnimatedModel:SetPoseParam(%s) - Couldn't find pose parameter with name.", ToString(name)) 
    end
    
    return success
end

function AnimatedModel:GetPoseParamIndex(name)
  
    local model = Shared.GetModel(self.modelIndex)  
    if (model ~= nil) then
        return model:GetPoseParamIndex(name)
    else
        return -1
    end
    
end

function AnimatedModel:GetModelFilename()
    return self.modelName
end

function AnimatedModel:GetAnimationName()
    return self.animationName
end

function AnimatedModel:GetAnimationLength(animationName)

    local model = Shared.GetModel(self.modelIndex)
    if model ~= nil then

        local anim = ConditionalValue(animationName ~= nil, animationName, self.animationName)
        local animationIndex = model:GetSequenceIndex(anim)
        return model:GetSequenceLength(animationIndex)
    end
    
    return 0
    
end

function AnimatedModel:SetQueuedAnimation(queuedAnimationName)
    self.queuedAnimationName = ToString(queuedAnimationName)
end

function AnimatedModel:SetAnimationTime(time)

    local model = Shared.GetModel(self.modelIndex)
    if model ~= nil and self.animationName ~= nil then

        local animationIndex = model:GetSequenceIndex(self.animationName)
        local animationLength = model:GetSequenceLength(animationIndex)
        self.animationTime = Clamp(time, 0, animationLength)
        
    end
    
end

function AnimatedModel:SetAnimationParameter(scalar)
    self.animationParameter = Clamp(scalar, 0, 1)
end

function AnimatedModel:SetStaticAnimation(staticAnim)
    self.staticAnim = staticAnim
end

function AnimatedModel:SetRenderMask( mask )
    assert(mask and mask >= 0 and self.renderModel)
    self.renderModel:SetRenderMask(mask)
end

function AnimatedModel:InstanceMaterials()
    assert(self.renderModel)
    self.renderModel:InstanceMaterials()
end

function AnimatedModel:SetMaterialParameter( paramName, paramValue, includeAdditives )
    assert(paramName and paramValue)
    self.renderModel:SetMaterialParameter(paramName, paramValue)
    if includeAdditives then
        for i = 1, #self.additiveMaterials do
            if self.additiveMaterials[i] ~= nil then
                self.additiveMaterials[i]:SetParameter(paramName, paramValue)
            end
        end
    end
end

function AnimatedModel:SetNamedMaterialParameter( paramName, paramValue, materialName )
    assert(paramName and paramValue)
    assert(materialName)
    
    for i = 1, #self.additiveMaterials do
        if self.additiveMaterials[i] ~= nil and self.additiveMaterials[i]:GetMaterialFilename() == materialName then
            self.additiveMaterials[i]:SetParameter(paramName, paramValue)
        end
    end
end

function AnimatedModel:AddMaterial( materialName )
    assert(materialName and materialName ~= "")
    if self.renderModel then
        local newMaterial = AddMaterial(self.renderModel, materialName)
        table.insert( self.additiveMaterials, newMaterial )
        return newMaterial
    end
    return false
end

function AnimatedModel:RemoveMaterial(materialName)
    assert(materialName and materialName ~= "")
    if self.renderModel then
        for i = 1, #self.additiveMaterials do
            if self.additiveMaterials[i] and self.additiveMaterials[i]:GetMaterialFilename() == materialName then
                if RemoveMaterial(self.renderModel, self.additiveMaterials[i]) then
                    self.additiveMaterials[i] = nil
                    return true
                end
            end
        end
    end
    return false
end

--TODO Add material-swapping support

-- Must be called manually
function AnimatedModel:Update(deltaTime)    --TODO Review and optimize

    PROFILE("AnimatedModel:Update")

    if not Shared.GetIsRunningPrediction() then  --?? won't this cause a problem?
    
        -- ...in random dramatic attack pose
        -- Add a small buffer to animate the model so it is not stuck in poses it should not be in
        if (self.animationName ~= nil and self.staticAnim == false) or (self.staticAnim == true and self.animationTime < 0.07) then

            local model = Shared.GetModel(self.modelIndex)
            if model ~= nil then
                -- Update animation time
                local animationIndex = model:GetSequenceIndex(self.animationName)
                self.animationTime = self.animationTime + deltaTime
                
                local animationLength = model:GetSequenceLength(animationIndex)
                local animationTime = self.animationTime
                if self.animationTime > animationLength then
                
                    self.animationTime = self.animationTime - animationLength
                
                    -- When we hit the end of the current animation, transition to queued animation
                    if self.queuedAnimationName ~= nil then
                    
                        self:SetAnimation(self.queuedAnimationName)
                        
                        animationIndex = model:GetSequenceIndex(self.queuedAnimationName)
                        animationTime = 0
                        self.queuedAnimationName = nil

                    end
                    
                end
                
                -- Update bone coords
                local boneCoords = CoordsArray()
                local poses = PosesArray()
                model:GetReferencePose(poses)
                
                model:AccumulateSequence(animationIndex, animationTime, self.poseParams, poses)
                model:GetBoneCoords(poses, boneCoords)

                if self.renderModel ~= nil then
                    self.renderModel:SetBoneCoords(boneCoords)
                end
                
            else
                Print("AnimatedModel:OnUpdate(): Couldn't find model for model index %s (%s)", ToString(self.modelIndex), ToString(self.modelName))
            end
            
        end
        
    end 
   
end

function AnimatedModel:SetCastsShadows(showShadows)
    if self.renderModel ~= nil then
        self.renderModel:SetCastsShadows(showShadows)
    end
end

-- Must be called manually
function AnimatedModel:Destroy()

    if self.renderModel then
        for i = 1, #self.additiveMaterials do 
            if not RemoveMaterial(self.renderModel, self.additiveMaterials[i]) then
                Log("Failed to remove additive material!")
            end
        end
    
        Client.DestroyRenderModel(self.renderModel)
        self.renderModel = nil
    end

    self.poseParams = nil
end