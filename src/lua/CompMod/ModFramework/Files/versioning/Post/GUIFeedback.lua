local mod = fw_get_current_mod()

if mod:GetModule('versioning'):GetShouldDisplay() then
    local originalFeedbackInit

    originalFeedbackInit = Class_ReplaceMethod('GUIFeedback', 'Initialize', 
        function (self)
            originalFeedbackInit(self)
            self.buildText:SetText(self.buildText:GetText() .. " " .. mod:GetModule('versioning'):GetFeedbackText())
        end
    )
end