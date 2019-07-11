--[[

WHY IS THIS FILE NOT IN lua/hud/Alien WHY IS IT IN THE ROOT DIR KSDHFKJSDHFJKSDHFJKASDHFJKASDHFJKSDHFJK

]]

-- modification of GUIAlienHUD:CHUDRepositionGUI(). used to get the y offset for ns2+'s additional elements
local function CalculateYOffsetNS2Plus(hud)
    local gametime = CHUDGetOption("gametime")
    local realtime = CHUDGetOption("realtime")
    local y = hud.resourceDisplay.teamText:GetPosition().y + 30

    if gametime then
        y = y + 30
    end

    if realtime then
        y = y + 30
    end

    return y
end

local function CalculateYOffset(hud)
    -- if the ns2+ changes to GUIAlienHUD have been loaded
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

local oldInit = GUIAlienHUD.Initialize
function GUIAlienHUD:Initialize()
    oldInit(self)

    self.supplyText = self:CreateAnimatedTextItem()
    self.supplyText:SetFontName(GUIMarineHUD.kTextFontName)
    self.supplyText:SetTextAlignmentX(GUIItem.Align_Min)
    self.supplyText:SetTextAlignmentY(GUIItem.Align_Min)
    self.supplyText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.supplyText:SetLayer(kGUILayerPlayerHUDForeground1)
    self.supplyText:SetColor(kAlienTeamColorFloat)
    self.supplyText:SetFontIsBold(true)
    --self.background:AddChild(self.supplyText)

    UpdateScale(self)
end


local oldUninit = GUIAlienHUD.Uninitialize
function GUIAlienHUD:Uninitialize()
    oldUninit(self)

    self.supplyText:Destroy()
    self.supplyText = nil
end

local oldReset = GUIAlienHUD.Reset
function GUIAlienHUD:Reset()
    oldReset(self)

    UpdateScale(self)
end

local oldUpdate = GUIAlienHUD.Update
function GUIAlienHUD:Update(deltaTime)
    oldUpdate(self, deltaTime)

    if self.supplyText then
        local supplyUsed = GetSupplyUsedByTeam(Client.GetLocalPlayer():GetTeamNumber())
        local maxSupply = GetMaxSupplyForTeam(Client.GetLocalPlayer():GetTeamNumber())

        local useColor

        if supplyUsed == maxSupply then
            useColor = Color(1, 0, 0, 1) -- red
        else
            useColor = kAlienTeamColorFloat
        end

        self.supplyText:SetText(string.format("SUPPLY: %d / %d", supplyUsed, maxSupply))
        self.supplyText:SetColor(useColor)
    end
end
