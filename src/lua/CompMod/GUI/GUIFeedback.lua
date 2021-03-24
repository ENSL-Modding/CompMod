local oldInitialize = GUIFeedback.Initialize
function GUIFeedback:Initialize()
    oldInitialize(self)
    if g_compModTest then
        self.buildText:SetText(self.buildText:GetText() .. " CompMod - " .. g_compModTest)
    else
        self.buildText:SetText(self.buildText:GetText() .. " CompMod revision " .. g_compModRevision)
        if g_compModBeta and g_compModBeta > 0 then
            self.buildText:SetText(self.buildText:GetText() .. "b" .. g_compModBeta)
        end
    end
end
