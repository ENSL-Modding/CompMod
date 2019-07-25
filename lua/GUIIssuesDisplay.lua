class 'GUIIssuesDisplay' (GUIScript)

local kConnectionProblemsIcon = PrecacheAsset("ui/ethernet-connect.dds") -- red plug network connection issue
local kServerPerformanceProblemsIcon = PrecacheAsset("ui/perf-error-server.dds")
local kScriptErrorProblemsIcon = PrecacheAsset("ui/script-error.dds")
local kSeverScriptErrorProblemsIcon = PrecacheAsset("ui/script-error-server.dds")

local kServerScriptErrorStickTime = 2
local kScriptErrorStickTime = 2
local kConnectionProblemErrorStickTime = 0.2
local kServerPerformanceErrorStickTime = 0.2

function GUIIssuesDisplay:Initialize()
	
	--self.updateInterval = 0.016 -- 60fps
	self.updateInterval = 0.04 -- 25fps
	--self.updateInterval = 0.2 -- 5fps (GUIScoreboard)
    	
    self.connectionProblemsIcon = GUIManager:CreateGraphicItem()
    self.connectionProblemsIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.connectionProblemsIcon:SetPosition(GUIScale(Vector(32, 0, 0)))
    self.connectionProblemsIcon:SetSize(GUIScale(Vector(64, 64, 0)))
    self.connectionProblemsIcon:SetLayer(kGUILayerScoreboard)
    self.connectionProblemsIcon:SetTexture(kConnectionProblemsIcon)
    self.connectionProblemsIcon:SetColor(Color(1, 0, 0, 1))
    self.connectionProblemsIcon:SetIsVisible(false)
    self.connectionProblemsDetector = CreateTokenBucket(8, 20)
    
    self.serverPerformanceProblemsIcon = GUIManager:CreateGraphicItem()
    self.serverPerformanceProblemsIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.serverPerformanceProblemsIcon:SetPosition(GUIScale(Vector(32, 0, 0)))
    self.serverPerformanceProblemsIcon:SetSize(GUIScale(Vector(64, 64, 0)))
    self.serverPerformanceProblemsIcon:SetLayer(kGUILayerScoreboard)
    self.serverPerformanceProblemsIcon:SetTexture(kServerPerformanceProblemsIcon)
    self.serverPerformanceProblemsIcon:SetColor(Color(1, 0, 0, 1))
    self.serverPerformanceProblemsIcon:SetIsVisible(false)
	
    self.scriptErrorProblemsIcon = GUIManager:CreateGraphicItem()
    self.scriptErrorProblemsIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.serverPerformanceProblemsIcon:SetPosition(GUIScale(Vector(32, 0, 0)))
    self.scriptErrorProblemsIcon:SetSize(GUIScale(Vector(64, 64, 0)))
    self.scriptErrorProblemsIcon:SetLayer(kGUILayerScoreboard)
    self.scriptErrorProblemsIcon:SetTexture(kScriptErrorProblemsIcon)
    self.scriptErrorProblemsIcon:SetColor(Color(1, 1, 0, 0))
    self.scriptErrorProblemsIcon:SetIsVisible(false)
    
    self.serverScriptErrorProblemsIcon = GUIManager:CreateGraphicItem()
    self.serverScriptErrorProblemsIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.serverPerformanceProblemsIcon:SetPosition(GUIScale(Vector(32, 0, 0)))
    self.serverScriptErrorProblemsIcon:SetSize(GUIScale(Vector(64, 64, 0)))
    self.serverScriptErrorProblemsIcon:SetLayer(kGUILayerScoreboard)
    self.serverScriptErrorProblemsIcon:SetTexture(kSeverScriptErrorProblemsIcon)
    self.serverScriptErrorProblemsIcon:SetColor(Color(1, 0, 1, 0))
    self.serverScriptErrorProblemsIcon:SetIsVisible(false)
    
    self.visible = true
    
end

function GUIIssuesDisplay:SetIsVisible(state)
    
    -- this variable is never used within the class, except for GetIsVisible().
    -- we do this because we never want to hide error icons, but we don't want to
    -- make some special case for the ClientUI.  (Better to just nod your head and
    -- say "yes sir, no sir" than to kick up a fuss!)
    self.visible = state
    
end

function GUIIssuesDisplay:GetIsVisible()
    
    return self.visible
    
end

function GUIIssuesDisplay:Uninitialize()

    GUI.DestroyItem(self.connectionProblemsIcon)
    self.connectionProblemsIcon = nil
    
    GUI.DestroyItem(self.serverPerformanceProblemsIcon)
    self.serverPerformanceProblemsIcon = nil
    
    GUI.DestroyItem(self.scriptErrorProblemsIcon)
    self.scriptErrorProblemsIcon = nil
    
    GUI.DestroyItem(self.serverScriptErrorProblemsIcon)
    self.serverScriptErrorProblemsIcon = nil 

end

function GUIIssuesDisplay:Update(deltaTime)    
	
    local time = Shared.GetTime()
    
    -- Detect connection problems
    self.droppedMoves = self.droppedMoves or 0
    local numberOfDroppedMovesTotal = Shared.GetNumDroppedMoves()
    if numberOfDroppedMovesTotal ~= self.droppedMoves then
    
        self.connectionProblemsDetector:RemoveTokens(numberOfDroppedMovesTotal - self.droppedMoves)
        self.droppedMoves = numberOfDroppedMovesTotal
        
    end
	if self.connectionProblemsDetector:GetNumberOfTokens() < 6 then
		gTooManyDroppedMovesTime = time
	end    
	if Client.GetConnectionProblems() then
		gConnectionProblemsTime = time
	end
	
    -- Detect Server Script Errors
    local serverScriptErrorCount = Client.GetConnectedServerNumScriptErrors()
    if gServerScriptErrorCount ~= serverScriptErrorCount then
        gServerScriptErrorTime = time
        gServerScriptErrorCount = serverScriptErrorCount
        Print( "Server has had %d errors.", gServerScriptErrorCount )
    end
    	
	-- Detect Server Performance Problems
	local perfScore = Client.GetConnectedServerPerformanceScore()
	if perfScore < 0 then
		gServerPerformanceIssueTime = time
		if perfScore < -20 then
			gServerPerformanceRedIssueTime = time
		end
	end
	
	
	-- Display Icons	
    local errorX = 32
	
    -- Display Server Script Errors
    if gServerScriptErrorTime and time < gServerScriptErrorTime + kServerScriptErrorStickTime then
        local alpha = Clamp(time - gServerScriptErrorTime,0,1)
        alpha = 1 - alpha * alpha * alpha
        
        self.serverScriptErrorProblemsIcon:SetIsVisible(true)
        self.serverScriptErrorProblemsIcon:SetColor(Color(1,0,1,alpha))    
        self.serverScriptErrorProblemsIcon:SetPosition(GUIScale(Vector(errorX, 0, 0)))
        errorX = errorX + 64 + 8    
    else
        self.serverScriptErrorProblemsIcon:SetIsVisible(false)
    end
    
    -- Display Clientside Script Errors
    if gScriptErrorTime and time < gScriptErrorTime + kScriptErrorStickTime then
        local alpha = Clamp(time - gScriptErrorTime,0,1)
        alpha = 1 - alpha * alpha * alpha
        
        self.scriptErrorProblemsIcon:SetIsVisible(true)
        self.scriptErrorProblemsIcon:SetColor(Color(1,1,0,alpha))
        self.scriptErrorProblemsIcon:SetPosition(GUIScale(Vector(errorX, 0, 0)))
        errorX = errorX + 64 + 8
    else
        self.scriptErrorProblemsIcon:SetIsVisible(false)
    end
    
    -- Display Connection Problems
	local tooManyDroppedMoves = gTooManyDroppedMovesTime and time < gTooManyDroppedMovesTime + kConnectionProblemErrorStickTime
	local connectionProblems = gConnectionProblemsTime and time < gConnectionProblemsTime + kConnectionProblemErrorStickTime
    if connectionProblems or tooManyDroppedMoves then
        local alpha = 0.5 + (((math.cos(time * 10) + 1) / 2) * 0.5)        
		local useColor
		
        if tooManyDroppedMoves and connectionProblems then
			useColor = Color(1, 0, 1, alpha) -- purple plug
        elseif tooManyDroppedMoves then
			useColor = Color(1, 1, 0, alpha) -- yellow plug
		else
			useColor = Color(1, 0, 0, alpha) -- red plug
        end
        
        self.connectionProblemsIcon:SetColor(useColor)        
        self.connectionProblemsIcon:SetPosition(GUIScale(Vector(errorX, 0, 0)))
		self.connectionProblemsIcon:SetIsVisible(true)
        errorX = errorX + 64 + 8
	else
		self.connectionProblemsIcon:SetIsVisible(false)
    end
	
	-- Display Server Performance Problems	
	if gServerPerformanceIssueTime and time < gServerPerformanceIssueTime + kServerPerformanceErrorStickTime then
        local alpha = 0.5 + (((math.cos(time * 10) + 1) / 2) * 0.5)
        local useColor = Color(1, 1, 0, alpha) -- yellow performance
		if gServerPerformanceRedIssueTime and time < gServerPerformanceRedIssueTime + kServerPerformanceErrorStickTime then
            useColor = Color(1, 0, 0, alpha)  -- red performance
		end
		
		self.serverPerformanceProblemsIcon:SetColor(useColor)	
		self.serverPerformanceProblemsIcon:SetIsVisible(true)
        self.serverPerformanceProblemsIcon:SetPosition(GUIScale(Vector(errorX, 0, 0)))
        errorX = errorX + 64 + 8
	else
		self.serverPerformanceProblemsIcon:SetIsVisible(false)
	end
	
end

gServerScriptErrorCount = 0
gServerScriptErrorTime = nil
gScriptErrorTime = nil
Event.Hook( "ErrorCallback", 
    function(errmsg) 
        gScriptErrorTime = Shared.GetTime()
    end)