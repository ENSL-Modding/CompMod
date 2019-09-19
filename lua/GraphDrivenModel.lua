-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\GraphDrivenModel.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Client-only, purely visual animated model that is driven by an animation graph.
--
-- ========= For more information, visit us at http:\\www.unknownworlds.com =====================

Script.Load("lua/MaterialUtility.lua")

local graphDrivenModels = {} -- for updating them.

class 'GraphDrivenModel'

function CreateGraphDrivenModel(modelName, graphName, optionalRenderSceneZone)
    
    assert(modelName)
    assert(modelName ~= "")
    
    assert(graphName)
    assert(graphName ~= "")
    
    optionalRenderSceneZone = optionalRenderSceneZone or RenderScene.Zone_Default
    
    local gdm = GraphDrivenModel()
    
    gdm.renderModel = Client.CreateRenderModel(optionalRenderSceneZone)
    gdm.renderModel:SetModelByName(modelName)
    
    gdm.modelIndex = Shared.GetModelIndex(modelName)
    
    gdm.graphIndex = Shared.GetAnimationGraphIndex(graphName)
    if gdm.graphIndex == 0 then
        error("Animation graph " .. graphName .. " does not exist!")
        return nil
    end
    
    gdm.coords = Coords()
    gdm.poseParams = PoseParams()
    gdm.boneCoords = CoordsArray()
    gdm.animationState = AnimationGraphState()
    
    gdm.additiveMaterials = {}

    table.insert(graphDrivenModels, gdm)
    
    return gdm
    
end

function DestroyGraphDrivenModel(gdm)
    
    if gdm.renderModel then
        Client.DestroyRenderModel(gdm.renderModel)
        gdm.renderModel = nil
        for i=1, #graphDrivenModels do
            if graphDrivenModels[i] == gdm then
                table.remove(graphDrivenModels, i)
            end
        end
    end
    
end

--Optional manual initialization for usage where models need to be easily tracked (instead of create and forget)
function GraphDrivenModel:Initialize( modelFile, graphFile, optionalRenderSceneZone )   --?? change to use precached?
    assert(modelFile and graphFile)
    assert(modelFile ~= "")
    assert(graphFile ~= "")

    optionalRenderSceneZone = optionalRenderSceneZone or RenderScene.Zone_Default

    self.renderModel = Client.CreateRenderModel(optionalRenderSceneZone)
    --self.renderModel:SetModelByName(modelFile)

    self.modelIndex = Shared.GetModelIndex(modelFile)
    if self.modelIndex == 0 then
        self.modelIndex = Shared.LoadModel(modelFile)
    end
    
    self.modelName = modelFile

    self.modelIndex = Shared.GetModelIndex(modelFile)

    assert(self.modelIndex > 0)
    self.renderModel:SetModel( self.modelIndex )

    if Client then --FIXME needs to be Main Menu Only!
        Client.PrecacheLoadAnimationGraph(graphFile)
    end

    self.graphIndex = Shared.GetAnimationGraphIndex(graphFile)

    if self.graphIndex == 0 then
        error("Animation graph " .. graphFile .. " does not exist!") --FYI, Not jittable
        return
    end

    self.coords = Coords()
    self.poseParams = PoseParams()
    self.boneCoords = CoordsArray()
    self.animationState = AnimationGraphState()

    self.additiveMaterials = {}

end

function GraphDrivenModel:InstanceMaterials()
    
    if self.renderModel then
        self.renderModel:InstanceMaterials()
    end
    
end

function GraphDrivenModel:SetMaterialParameter(materialParamName, materialParamVal, includeAdditives)
    if self.renderModel then
        self.renderModel:SetMaterialParameter(materialParamName, materialParamVal)

        if includeAdditives then
            for i = 1, #self.additiveMaterials do
                if self.additiveMaterials[i] ~= nil and self.additiveMaterials[i].SetParameter then
                    self.additiveMaterials[i]:SetParameter(materialParamName, materialParamVal)
                end
            end
        end
    end
end

function GraphDrivenModel:SetNamedMaterialParameter( paramName, paramValue, materialName )
    assert(paramName and paramValue)
    assert(materialName)
    
    for i = 1, #self.additiveMaterials do
        if self.additiveMaterials[i] ~= nil and self.additiveMaterials[i].SetParameter and self.additiveMaterials[i]:GetMaterialFilename() == materialName then
            self.additiveMaterials[i]:SetParameter(paramName, paramValue)
        end
    end
end

function GraphDrivenModel:AddMaterial(materialName)
    assert(materialName and materialName ~= "")
    if self.renderModel then
        local newMaterial = AddMaterial(self.renderModel, materialName)
        table.insert( self.additiveMaterials, newMaterial )
        return newMaterial
    end
    return false
end

function GraphDrivenModel:RemoveMaterial(materialName)
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

--TODO Add Material-Swapping support

function GraphDrivenModel:SetRenderMask( mask )
    assert(type(mask) == "number" and mask > 0)
    self.renderModel:SetRenderMask(mask)
end

function GraphDrivenModel:SetCastsShadows(shadows)
    assert(type(shadows) == "boolean")
    self.renderModel:SetCastsShadows(shadows)
end

function GraphDrivenModel:SetCoords(coords)
    assert(coords and coords:GetIsFinite())
    self.coords = coords
    self.renderModel:SetCoords(coords)
end

function GraphDrivenModel:SetIsVisible(visible)
    assert(type(visible) == "boolean")
    self.renderModel:SetIsVisible(visible)
end

function GraphDrivenModel:GetCoords()
    return self.coords
end

function GraphDrivenModel:GetModelFilename()
    return self.modelName
end

function GraphDrivenModel:SetPoseParam(name, value)
    
    local model = Shared.GetModel(self.modelIndex)
    if model == nil then
        return
    end
    
    local paramIndex = model:GetPoseParamIndex(name)
    self.poseParams:Set(paramIndex, value)
    
end

function GraphDrivenModel:SetAnimationInput(name, value)
    
    local graph = Shared.GetAnimationGraph(self.graphIndex)
    if not graph then
        return
    end
    self.animationState:SetInputValue(graph, name, value)
    
end

function GraphDrivenModel:SetPreUpdateCallbackFunction(callback)
    self.callback = callback  --?? pass reference to self?
end

function GraphDrivenModel:Update()
    
    -- Skip updating if the render model was culled last frame.  Ideally we'd be able to tell if it was going to be rendered
    -- THIS frame... but that's going to be too expensive.  A single non-updated frame is a small price to pay... and the
    -- occlusion culling algorithm is pretty conservative anyways, so it'll likely never be noticed anyways.
    if self.renderModel:GetNumFramesInvisible() > 0 then
        return
    end
    
    local now = Shared.GetTime()
    local prev = Shared.GetPreviousTime()
    local delta = now - prev
    
    if self.callback then
        self.callback(self, delta)
    end
    
    local graph = Shared.GetAnimationGraph(self.graphIndex)
    if not graph then
        return
    end
    
    self.animationState:PrepareForGraph(graph)
    
    local model = Shared.GetModel(self.modelIndex)
    local passedTags = {}
    
    self.animationState:Update(graph, model, self.poseParams, prev, now, passedTags)
    self.animationState:Transition(graph, model, passedTags)
    
    self.animationState:GetBoneCoords(model, self.poseParams, self.boneCoords)
    self.renderModel:SetBoneCoords(self.boneCoords)
    
end

function GraphDrivenModel:Destroy()
    
    self.coords = nil
    self.poseParams = nil
    self.boneCoords = nil
    self.animationState = nil

    if #self.additiveMaterials > 0 and self.renderModel then
        for i = 1, #self.additiveMaterials do
            if not RemoveMaterial(self.renderModel, self.additiveMaterials[i]) then --? just make as assert?
                Log("GraphDrivenModel:Destroy() - Failed to remove additive material")
            end
        end
    end
    self.additiveMaterials = nil

    if self.renderModel then
        Client.DestroyRenderModel(self.renderModel)
        self.renderModel = nil
    end
end

local function UpdateGraphDrivenModels()
    
    for i=1, #graphDrivenModels do
        graphDrivenModels[i]:Update()
    end
    
end
Event.Hook("UpdateRender", UpdateGraphDrivenModels)
