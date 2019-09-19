-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/style/GUIStyleTextureNode.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Child class of GUIStyleRenderNode, responsible for creating a composite result from different
--    texture inputs.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/style/GUIStyleRenderNode.lua")

---@class GUIStyleTextureNode : GUIStyleRenderNode
class 'GUIStyleTextureNode' (GUIStyleRenderNode)

function GUIStyleTextureNode:Initialize(childNodes, inputKeys, inputValues, shader, color, size, globalScale)
    
    GUIStyleRenderNode.Initialize(self, childNodes)
    
    self:CreateGUIView(size.x, size.y)
    
    assert(#inputKeys == #inputValues)
    for i=1, #inputKeys do
        self.guiView:SetGlobal("key_"..i, inputKeys[i])
        self.guiView:SetGlobal("value_"..i, inputValues[i])
    end
    self.guiView:SetGlobal("paramCount", #inputKeys)
    self.guiView:SetGlobal("__color", color)
    
    self.guiView:SetGlobal("__scaleFactorX", globalScale.x)
    self.guiView:SetGlobal("__scaleFactorY", globalScale.y)
    
    shader = shader or "shaders/GUIBasic.surface_shader"
    self.guiView:SetGlobal("shader", shader)
    
    self.guiView:SetGlobal("update", 1)
    
end