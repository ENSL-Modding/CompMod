-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/MissionScreen/GUIMenuMissionStep.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Display for a single step in a mission.  Contains a title, description of the task, and an
--    icon showing whether its been completed.
--
--  Parameters (* = required)
--      completed
--      title
--      description
--      checkTex        The texture to use in place of a "checkmark" when completed.  Defaults to
--                      the claws icon.
--      pressCallback   If present, the step will act as a button so the user can click it to be
--                      immediately taken to where the task can be achieved.
--      legacyTitle     Title that was used in old menu.  Required for compatibility for the rookie
--                      missions.
--
--  Properties
--      Completed       Whether or not this step has been completed.
--      Title           Title of the mission step.
--      Description     Description of the mission step.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/GUI/GUIParagraph.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuMissionStep : GUIObject
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIObject
baseClass = GetCursorInteractableWrappedClass(baseClass)
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuMissionStep" (baseClass)

local kClawsIcon = PrecacheAsset("ui/progress/claws.dds")
local kNotDoneIcon = PrecacheAsset("ui/progress/locked.dds")
local kDoneIcon = PrecacheAsset("ui/progress/unlocked.dds")

local kIconAreaWidth = 175
local kIconScale = 1.5

GUIMenuMissionStep.kTitleFont = ReadOnly{family = "MicrogrammaBold", size = 32}
GUIMenuMissionStep.kTitleColor = MenuStyle.kOptionHeadingColor
GUIMenuMissionStep.kTitleCompletedColor = MenuStyle.kHighlight

GUIMenuMissionStep.kDescriptionFont = ReadOnly{family = "AgencyBold", size = 32}
GUIMenuMissionStep.kDescriptionColor = MenuStyle.kLightGrey
GUIMenuMissionStep.kDescriptionCompletedColor = MenuStyle.kHighlight

local kEdgeSpacing = 24

GUIMenuMissionStep:AddClassProperty("Completed", false)
GUIMenuMissionStep:AddCompositeClassProperty("Title", "titleText", "Text")
GUIMenuMissionStep:AddCompositeClassProperty("Description", "descriptionText", "Text")

local kStrokeInnerPadding = 6

local function UpdateIconBackTexture(iconBack, completed)
    if completed then
        iconBack:SetTexture(kDoneIcon)
    else
        iconBack:SetTexture(kNotDoneIcon)
    end
    iconBack:SetSizeFromTexture()
end

local function UpdateTextAreaWidth(textArea, size)
    textArea:SetWidth(math.max(size.x - kIconAreaWidth, 32))
end

local function UpdateTextColor(self)
    
    local completed = self:GetCompleted()
    if completed then
        self.titleText:SetColor(self.kTitleCompletedColor)
        self.descriptionText:SetColor(self.kDescriptionCompletedColor)
    else
        self.titleText:SetColor(self.kTitleColor)
        self.descriptionText:SetColor(self.kDescriptionColor)
    end
    
end

local function UpdateDescriptionMaxWidth(descriptionText, size)
    descriptionText:SetParagraphSize(math.max(size.x - kEdgeSpacing*2, 32), -1)
end

local function UpdateTextAreaHeight(self)

    local titleHeight = self.titleText:GetSize().y
    local descHeight = self.descriptionText:GetSize().y
    
    local totalHeight = titleHeight + descHeight + kEdgeSpacing*3
    self.textArea:SetHeight(totalHeight)

end

local function OnFXStateChanged(self, state, prevState)
    
    if state == "pressed" then
        self.pressBack:ClearPropertyAnimations("StrokeColor")
        self.pressBack:SetStrokeColor(MenuStyle.kHighlight * Color(1, 1, 1, 0.5))
    elseif state == "hover" then
        if prevState == "pressed" then
            self.pressBack:AnimateProperty("StrokeColor", MenuStyle.kHighlight, MenuAnimations.Fade)
        else
            PlayMenuSound("ButtonHover")
            self.pressBack:ClearPropertyAnimations("StrokeColor")
            self.pressBack:SetStrokeColor(MenuStyle.kHighlight)
            self.pressBack:AnimateProperty("StrokeColor", nil, MenuAnimations.HighlightFlashColor)
        end
    elseif state == "default" then
        self.pressBack:AnimateProperty("StrokeColor", MenuStyle.kHighlight * Color(1, 1, 1, 0), MenuAnimations.Fade)
    end

end

local function UpdatePressBackSize(self)
    local size = self:GetSize()
    self.pressBack:SetSize(size.x - kStrokeInnerPadding*2, size.y - kStrokeInnerPadding*2)
end

local function OnPressed(self)
    PlayMenuSound("ButtonClick")
    self.pressCallback(self)
end

local function GetOldOptionName(title)
    return (string.format("menu/unlocked_%s", string.gsub(title, " ", "")))
end

local function OnCompletedChanged(self)

    local complete = self:GetCompleted()
    if not complete then
        return
    end
    
    local name = self:GetName()
    local title = self:GetTitle()
    
    -- Determine if item is already checked off.
    local optionPath = string.format("menu/unlocked_%s", name)
    local altOptionPath
    if self.legacyTitle then
        altOptionPath = GetOldOptionName(self.legacyTitle or title)
    end
    
    local previouslyUnlocked = Client.GetOptionBoolean(optionPath, false)
    if not previouslyUnlocked and altOptionPath then
        -- Check legacy option.
        previouslyUnlocked = Client.GetOptionBoolean(altOptionPath, false)
    end
    
    if not previouslyUnlocked then
        -- Unlocking for the first time
        PlayMenuSound("MissionStepFinish")
        GetMissionScreen():SetUnread()
        Client.SetOptionBoolean(optionPath, true)
    end

end

function GUIMenuMissionStep:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"boolean", "nil"}, params.completed, "params.completed", errorDepth)
    RequireType({"string", "nil"}, params.title, "params.title", errorDepth)
    RequireType({"string", "nil"}, params.legacyTitle, "params.legacyTitle", errorDepth)
    RequireType({"string", "nil"}, params.description, "params.description", errorDepth)
    RequireType({"string", "nil"}, params.checkTex, "params.checkTex", errorDepth)
    RequireType({"function", "nil"}, params.pressCallback, "params.pressCallback", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.legacyTitle = params.legacyTitle
    
    self.iconArea = CreateGUIObject("iconArea", GUIObject, self)
    self.iconArea:AlignLeft()
    self.iconArea:HookEvent(self, "OnSizeChanged", self.iconArea.SetHeight)
    self.iconArea:SetHeight(self:GetSize())
    self.iconArea:SetWidth(kIconAreaWidth)
    
    self.iconBack = CreateGUIObject("iconBack", GUIObject, self.iconArea)
    self.iconBack:AlignCenter()
    self.iconBack:SetTexture(kNotDoneIcon)
    self.iconBack:SetColor(1, 1, 1, 1)
    self.iconBack:SetSizeFromTexture()
    self.iconBack:SetScale(kIconScale, kIconScale)
    self.iconBack:SetLayer(1)
    
    -- Switch icon back texture depending on the completed status.
    self.iconBack:HookEvent(self, "OnCompletedChanged", UpdateIconBackTexture)
    
    self.checkTex = params.checkTex or kClawsIcon
    
    self.iconCheck = CreateGUIObject("iconCheck", GUIObject, self.iconArea)
    self.iconCheck:AlignCenter()
    self.iconCheck:SetTexture(self.checkTex)
    self.iconCheck:SetColor(1, 1, 1, 1)
    self.iconCheck:SetSizeFromTexture()
    self.iconCheck:SetScale(kIconScale, kIconScale)
    self.iconCheck:SetLayer(2)
    self.iconCheck:SetVisible(false)
    self.iconCheck:HookEvent(self, "OnCompletedChanged", self.iconCheck.SetVisible)
    
    self.textArea = CreateGUIObject("textArea", GUIObject, self)
    self.textArea:AlignRight()
    
    -- Update width of text area to the width of the whole object, minus the width of the icon area.
    self.textArea:HookEvent(self, "OnSizeChanged", UpdateTextAreaWidth)
    
    -- Update the height of the object to fit the height of the text area.
    self:HookEvent(self.textArea, "OnSizeChanged", self.SetHeight)
    
    self.titleText = CreateGUIObject("titleText", GUIText, self.textArea,
    {
        color = self.kTitleColor,
        font = self.kTitleFont,
        align = "top",
        position = Vector(0, kEdgeSpacing, 0),
    })
    
    -- Change color of text when completed.
    self:HookEvent(self, "OnCompletedChanged", UpdateTextColor)
    
    self.descriptionText = CreateGUIObject("descriptionText", GUIParagraph, self.textArea,
    {
        color = kDescriptionColor,
        font = self.kDescriptionFont,
        align = "bottom",
        justification = GUIItem.Align_Center,
        position = Vector(0, -kEdgeSpacing, 0),
    })
    
    -- Update the maximum paragraph width of the description text to be a little bit less than the
    -- width of the area it resides in.
    self.descriptionText:HookEvent(self.textArea, "OnSizeChanged", UpdateDescriptionMaxWidth)
    
    -- Update the height of the text area to fit both text items.
    self:HookEvent(self.titleText, "OnSizeChanged", UpdateTextAreaHeight)
    self:HookEvent(self.descriptionText, "OnSizeChanged", UpdateTextAreaHeight)
    
    if params.completed ~= nil then
        self:SetCompleted(params.completed)
    end
    
    if params.title then
        self:SetTitle(params.title)
    end
    
    if params.description then
        self:SetDescription(params.description)
    end
    
    if params.pressCallback then
        self.pressCallback = params.pressCallback
        self.pressBack = CreateGUIObject("pressBack", GUIMenuBasicBox, self)
        self.pressBack:AlignCenter()
        self.pressBack:SetFillColor(0, 0, 0, 0)
        self.pressBack:SetStrokeWidth(3)
        self.pressBack:SetStrokeColor(MenuStyle.kHighlight * Color(1, 1, 1, 0))
        self.pressBack:SetFillColor(0, 0, 0, 0.001) -- small amount of opacity so it gets rendered.
        self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
        self:HookEvent(self, "OnSizeChanged", UpdatePressBackSize)
        self:HookEvent(self, "OnPressed", OnPressed)
        UpdatePressBackSize(self)
    end
    
    self:HookEvent(self, "OnCompletedChanged", OnCompletedChanged)
    
end
