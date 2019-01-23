local Mod = GetMod()

if Mod.config.kShowInFeedbackText then

	local originalFeedbackInit

	originalFeedbackInit = Class_ReplaceMethod("GUIFeedback", "Initialize",
	function(self)
		originalFeedbackInit(self)
		self.buildText:SetText(self.buildText:GetText() .. " (" .. Mod.config.kModName .. " " .. Mod:GetVersion() .. ")")
	end)

end
