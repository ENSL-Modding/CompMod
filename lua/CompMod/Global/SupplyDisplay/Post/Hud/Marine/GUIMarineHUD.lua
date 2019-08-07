-- modification of GUIMarineHUD:CHUDRepositionGUI(). used to get the y offset for ns2+'s additional elements
local function CalculateYOffsetNS2Plus()
    local minimap = CHUDGetOption("minimap")
    local showcomm = CHUDGetOption("showcomm")
    local gametime = CHUDGetOption("gametime")
    local realtime = CHUDGetOption("realtime")

    -- Position of toggleable elements
    local y = 30

    if minimap then
        y = y + 300
    end

    if showcomm then
        y = y + 30
        y = y + 30
    end

    if gametime then
        y = y + 30
    end

    if realtime then
        y = y + 30
    end

    return y
end

local function CalculateYOffset(hud)
    -- if the ns2+ changes to GUIMarineHUD have been loaded
    if hud.CHUDRepositionGUI then
        return CalculateYOffsetNS2Plus()
    end

    return 390
end

function GUIMarineHUD:UpdateScale()
    local y = CalculateYOffset(self)

    if self.supplyText then
        self.supplyText:SetFontName(GUIMarineHUD.kTextFontName)
        self.supplyText:SetScale(GetScaledVector() * 1.15)
        self.supplyText:SetPosition(Vector(20, y, 0))
        GUIMakeFontScale(self.supplyText)
        y = y + 30
    end

    if self.eventDisplay then
        self.eventDisplay.notificationFrame:SetPosition(Vector(20, y, 0) * self.eventDisplay.scale)
    end
end

local oldInit = GUIMarineHUD.Initialize
function GUIMarineHUD:Initialize()
    oldInit(self)

    self.supplyText = self:CreateAnimatedTextItem()
    self.supplyText:SetFontName(GUIMarineHUD.kTextFontName)
    self.supplyText:SetTextAlignmentX(GUIItem.Align_Min)
    self.supplyText:SetTextAlignmentY(GUIItem.Align_Min)
    self.supplyText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.supplyText:SetLayer(kGUILayerPlayerHUDForeground1)
    self.supplyText:SetColor(kBrightColor)
    self.supplyText:SetFontIsBold(true)
    self.background:AddChild(self.supplyText)

    self:UpdateScale()
end


local oldUninit = GUIMarineHUD.Uninitialize
function GUIMarineHUD:Uninitialize()
    oldUninit(self)

    self.supplyText:Destroy()
    self.supplyText = nil
end

local oldReset = GUIMarineHUD.Reset
function GUIMarineHUD:Reset()
    oldReset(self)

    self:UpdateScale(self)
end

local oldUpdate = GUIMarineHUD.Update
function GUIMarineHUD:Update(deltaTime)
    oldUpdate(self, deltaTime)

    if self.supplyText then
        local supplyUsed = GetSupplyUsedByTeam(Client.GetLocalPlayer():GetTeamNumber())
        local maxSupply = GetMaxSupplyForTeam(Client.GetLocalPlayer():GetTeamNumber())

        local useColor

        if supplyUsed == maxSupply then
            useColor = Color(1, 0, 0, 1) -- red
        else
            useColor = kBrightColor
        end

        self.supplyText:SetText(string.format("SUPPLY: %d / %d", supplyUsed, maxSupply))
        self.supplyText:SetColor(useColor)
    end
end
