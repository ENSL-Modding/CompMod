local kModName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")
local Mod = _G[kModName]

if Mod.config.kShowInFeedbackText then

	local originalFeedbackInit

	originalFeedbackInit = Class_ReplaceMethod("GUIFeedback", "Initialize",
	function(self)
		originalFeedbackInit(self)
		self.buildText:SetText(self.buildText:GetText() .. " (" .. Mod.config.kModName .. " " .. Mod:GetVersion() .. ")")
	end)

end
