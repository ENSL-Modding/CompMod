ModPrintDebug("Loading Predict files", "Predict")

for i = 1, #Modules do
	local path = FormatDir(Modules[i], "Predict")

	local PredictFiles = {}
	Shared.GetMatchingFileNames(path, true, PredictFiles)

	for i = 1, #PredictFiles do
		ModPrintDebug("Loading predict file: " .. PredictFiles[i], "Predict")
    Script.Load(PredictFiles[i])
	end
end

ModPrintDebug("Predict files loaded.", "Predict")
