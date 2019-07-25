-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\GraphDrivenModel.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Client-only, purely visual animated model that is driven by an animation graph.
--
-- ========= For more information, visit us at http:\\www.unknownworlds.com =====================

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

function GraphDrivenModel:InstanceGDMMaterials()
    
    if self.renderModel then
        self.renderModel:InstanceMaterials()
    end
    
end

function GraphDrivenModel:SetGDMMaterialParameter(materialParamName, materialParamVal)
    
    if self.renderModel then
        self.renderModel:SetMaterialParameter(materialParamName, materialParamVal)
    end
    
end

function GraphDrivenModel:AddGDMMaterial(materialName)
    
    if self.renderModel then
        return AddMaterial(self.renderModel, materialName)
    end
    
end

function GraphDrivenModel:SetCoords(coords)
    
    self.coords = coords
    self.renderModel:SetCoords(coords)
    
end

function GraphDrivenModel:GetCoords()
    
    return self.coords
    
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
    
    self.callback = callback
    
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

local function UpdateGraphDrivenModels()
    
    for i=1, #graphDrivenModels do
        graphDrivenModels[i]:Update()
    end
    
end
Event.Hook("UpdateRender", UpdateGraphDrivenModels)
