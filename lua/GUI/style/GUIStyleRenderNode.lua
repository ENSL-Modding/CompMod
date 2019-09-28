-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/style/GUIStyleRenderNode.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Abstract class used to create a dependency graph of GUIViews and text inputs for rendering
--    Photoshop-like layer styles into text, dynamically.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kLuaPath = "lua/GUI/style/GUIStyleGUIView.lua"

---@class GUIStyleRenderNode
class 'GUIStyleRenderNode'

function GUIStyleRenderNode:Initialize(childNodes)
    
    self.children = childNodes
    self.renderDone = false
    self.childrenDone = false
    self.lastResetTime = 0.0
    self.targetTextureName = AutoGenerateBindTextureName()
    
end

function GUIStyleRenderNode:Uninitialize()
    
    self:DestroyGUIView()
    self.destroyed = true
end

-- should only be called by root node.
function GUIStyleRenderNode:ClearAll()
    
    local allNodes = UnorderedSet()
    self:GatherAllNodes(allNodes)
    
    for i=1, #allNodes do
        allNodes[i]:Uninitialize()
    end
    
end

function GUIStyleRenderNode:GatherAllNodes(set)
    set:Add(self)
    for i=1, #self.children do
        self.children[i]:GatherAllNodes(set)
    end
end

function GUIStyleRenderNode:GetTargetTextureName()
    return self.targetTextureName
end

function GUIStyleRenderNode:AddChildNode(node)
    self.children[#self.children+1] = node
end

function GUIStyleRenderNode:DestroyGUIView()
    if self.guiView then
        Client.DestroyGUIView(self.guiView)
    end
end

function GUIStyleRenderNode:CreateGUIView(sizeX, sizeY)
    
    self:DestroyGUIView()
    
    self.guiView = Client.CreateGUIView(sizeX, sizeY)
    self.guiView:Load(kLuaPath)
    self.guiView:SetGlobal("sizeX", sizeX)
    self.guiView:SetGlobal("sizeY", sizeY)
    self.guiView:SetRenderCondition(GUIView.RenderNever)
    self.guiView:SetTargetTexture(self.targetTextureName)
    
end

function GUIStyleRenderNode:GetIsDoneRendering()
    return self.renderDone
end

function GUIStyleRenderNode:GetAreChildrenDone()
    for i=1, #self.children do
        if not self.children[i]:GetIsDoneRendering() then
            return false
        end
    end
    return true
end

function GUIStyleRenderNode:UpdateChildren()
    
    PROFILE("GUIStyleRenderNode:UpdateChildren")
    
    for i=1, #self.children do
        self.children[i]:Update()
    end
end

function GUIStyleRenderNode:SetIsRootNode()
    self.isRoot = true -- will clean up children when done rendering.
end

function GUIStyleRenderNode:Update()
    
    PROFILE("GUIStyleRenderNode:Update")
    
    if not self.guiView then
        return
    end
    
    self:UpdateChildren()
    
    -- check for device reset
    local resetTime = self.guiView:GetLastResetTime()
    if resetTime > self.lastResetTime then
        self.lastResetTime = resetTime
        self.renderDone = false
        self.childrenDone = false
        return
    end
    
    -- end here if we do not need rendering.
    if self.renderDone then
        return
    end
    
    -- see if we've just finished rendering.
    if self.childrenDone and self.guiView:GetRenderCondition() == GUIView.RenderNever then
        self.renderDone = true
        
        -- If this is the root node, cleanup/free all children.
        if self.isRoot then
            local childNodes = UnorderedSet()
            self:GatherAllNodes(childNodes)
            childNodes:RemoveElement(self)
            for i=1, #childNodes do
                childNodes[i]:Uninitialize()
            end
            self.children = {}
        end
        
        return
    end
    
    -- check if our dependencies are still queued/rendering.
    self.childrenDone = self:GetAreChildrenDone()
    if self.childrenDone then
        self.guiView:SetRenderCondition(GUIView.RenderOnce)
    end
    
end