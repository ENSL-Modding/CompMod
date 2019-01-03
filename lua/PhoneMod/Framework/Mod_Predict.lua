_G[kModName]:PrintDebug("Loading Predict files", "Predict")

for i = 1, #_G[kModName].config.modules do
	local path = _G[kModName]:FormatDir(_G[kModName].config.modules[i], "Predict")

	local PredictFiles = {}
	Shared.GetMatchingFileNames(path, true, PredictFiles)

	for i = 1, #PredictFiles do
		_G[kModName]:PrintDebug("Loading predict file: " .. PredictFiles[i], "Predict")
    	Script.Load(PredictFiles[i])
	end
end

_G[kModName]:PrintDebug("Predict files loaded.", "Predict")
