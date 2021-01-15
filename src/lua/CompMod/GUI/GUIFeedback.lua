local oldInitialize = GUIFeedback.Initialize
function GUIFeedback:Initialize()
    oldInitialize(self)
    self.buildText:SetText(self.buildText:GetText() .. " CompMod revision " .. g_compModRevision)
end
