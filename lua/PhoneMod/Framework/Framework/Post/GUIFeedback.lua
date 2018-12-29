if kShowModInFeedbackText then

	local originalFeedbackInit

	originalFeedbackInit = Class_ReplaceMethod("GUIFeedback", "Initialize",
	function(self)
		originalFeedbackInit(self)
		self.buildText:SetText(self.buildText:GetText() .. " (" .. kModName .. " v"  .. kModVersion .. "." .. kModBuild .. ")")
	end)

end
