local oldInitialize = GUIFeedback.Initialize
function GUIFeedback:Initialize()
    oldInitialize(self)
    self.buildText:SetText(self.buildText:GetText() .. " CompMod revision " .. g_compModRevision)
    if g_compModBeta and g_compModBeta > 0 then
        self.buildText:SetText(self.buildText:GetText() .. "b" .. g_compModBeta)
    end
end
