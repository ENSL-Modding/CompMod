-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/style/GUIStyleFontNode.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Child class of GUIStyleRenderNode, responsible for rendering plain text into a texture.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/style/GUIStyleRenderNode.lua")

---@class GUIStyleFontNode : GUIStyleRenderNode
class 'GUIStyleFontNode' (GUIStyleRenderNode)

function GUIStyleFontNode:Initialize(text, fontFile, fontScale, renderSize)
    
    GUIStyleRenderNode.Initialize(self, {})
    
    self:CreateGUIView(renderSize.x, renderSize.y)
    
    self.guiView:SetGlobal("isText", 1) -- can't pass bool... :/
    self.guiView:SetGlobal("fontFile", fontFile)
    self.guiView:SetGlobal("fontScaleX", fontScale.x)
    self.guiView:SetGlobal("fontScaleY", fontScale.y)
    self.guiView:SetGlobal("text", text)
    
    self.guiView:SetGlobal("update", 1)
    
end
