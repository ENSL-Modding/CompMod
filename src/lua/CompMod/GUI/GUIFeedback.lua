local oldInitialize = GUIFeedback.Initialize
function GUIFeedback:Initialize()
    oldInitialize(self)

    local oldText = self.buildText:GetText()
    local newText = oldText .. " - CompMod revision " .. g_compModConfig.revision
    if g_compModConfig.build_tag then
        newText = newText .. " (" .. g_compModConfig.build_tag .. ")"
    end

    self.buildText:SetText(newText)
end
