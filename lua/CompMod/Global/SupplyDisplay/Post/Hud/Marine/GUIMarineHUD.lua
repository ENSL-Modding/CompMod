-- modification of GUIMarineHUD:CHUDRepositionGUI(). used to get the y offset for ns2+'s additional elements
local function CalculateYOffsetNS2Plus(hud)
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
        return CalculateYOffsetNS2Plus(hud)
    end

    return 390
end

local function UpdateScale(hud)
    if hud.supplyText then
        hud.supplyText:SetScale(Vector(1,1,1) * hud.scale * 1.2)
        hud.supplyText:SetScale(GetScaledVector())

        local y = CalculateYOffset(hud)
        local position = Vector(20, y, 0)

        hud.supplyText:SetPosition(position)
        GUIMakeFontScale(hud.supplyText)
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

    UpdateScale(self)
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

    UpdateScale(self)
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
