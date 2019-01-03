if _G[kModName].config.kShowInFeedbackText then

	local originalFeedbackInit

	originalFeedbackInit = Class_ReplaceMethod("GUIFeedback", "Initialize",
	function(self)
		originalFeedbackInit(self)
		self.buildText:SetText(self.buildText:GetText() .. " (" .. _G[kModName].config.kModName .. " " .. _G[kModName]:GetVersion() .. ")")
	end)

end
