-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/Vote/GUIMenuVoteOption.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    An option belonging to a list in a menu of the vote menu.  Each one of these options can
--    be linked to another list of options (eg main list contains "kick player" option, which links
--    to a list of options filled with one GUIMenuVoteOption for each player.
--
--  Parameters (* = required)
--     *owningList  List of options that this option belongs to.
--     *label       Label to display for this entry.
--      data        Data associated with this entry that will be passed to the vote function if
--                  called.  Only makes sense for leaf-level items (eg player to be kicked, not
--                  "kick player")
--      startFunc   Function to call when leaf-level option is selected.
--      genFunc     Function that generates a list of options for the sub menu.  Only makes sense
--                  for non-leaf level items (eg "kick player" instead of a player to be kicked).
--
--  Properties
--      Selected    Whether or not the option is selected.  Only makes sense for leaf-level options.
--
--  Events
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIButton.lua")

Script.Load("lua/GUI/wrappers/FXState.lua")

Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/GUIMenuTruncatedText.lua")
Script.Load("lua/menu2/GUIMenuText.lua")

---@class GUIMenuVoteOption : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuVoteOption" (baseClass)

GUIMenuVoteOption:AddClassProperty("Selected", false)
GUIMenuVoteOption:AddCompositeClassProperty("_ArrowColor", "arrowGraphic", "Color")

local kHeight = 116 --166
local kLabelSpacing = 48
local kArrowWidth = 48
local kArrowTexture = PrecacheAsset("ui/newMenu/arrow_sideways_big.dds")

local function UpdateBackColor(self)
    
    local selected = self:GetSelected()
    
    if selected then
        self.back:AnimateProperty("FillColor", MenuStyle.kHighlightBackground, MenuAnimations.FadeFast)
        self.back:AnimateProperty("StrokeColor", MenuStyle.kHighlightStrokeColor, MenuAnimations.FadeFast)
    else
        self.back:AnimateProperty("FillColor", MenuStyle.kBasicBoxBackgroundColor, MenuAnimations.FadeFast)
        self.back:AnimateProperty("StrokeColor", MenuStyle.kBasicStrokeColor, MenuAnimations.FadeFast)
    end
    
end

local function UpdateArrowColor(self)
    
    local selected = self:GetSelected()
    
    if selected then
        self:AnimateProperty("_ArrowColor", MenuStyle.kHighlight, MenuAnimations.FadeFast)
    else
        self:AnimateProperty("_ArrowColor", MenuStyle.kOptionHeadingColor, MenuAnimations.FadeFast)
    end
    
end

local function UpdateLabelSize(self)
    
    local labelSize = self.label:GetTextSize()
    local entryWidth = self:GetSize().x
    
    local spaceForLabel = entryWidth - kLabelSpacing*2
    
    if self.arrowGraphic then
        spaceForLabel = spaceForLabel - kArrowWidth
    end
    
    local labelWidth = math.min(spaceForLabel, labelSize.x)
    self.label:SetSize(labelWidth, labelSize.y)

end

local function SelectThisOption(self)
    assert(self.owningList)
    self.owningList:SetSelectedOption(self)
end

local function DisplaySubMenu(self)
    assert(self.genFunc)
    assert(self.owningList)
    assert(self.labelText)
    assert(self.startFunc)
    self.owningList:CreateSubMenu(self.labelText, self.genFunc, self.startFunc)
end

function GUIMenuVoteOption:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireIsa("GUIMenuVoteList", params.owningList, "params.owningList", errorDepth)
    RequireType("string", params.label, "params.label", errorDepth)
    RequireType({"table", "nil"}, params.data, "params.data", errorDepth)
    RequireType({"function", "nil"}, params.startFunc, "params.startFunc", errorDepth)
    RequireType({"function", "nil"}, params.genFunc, "params.genFunc", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:SetLayer(-1)
    self.back:HookEvent(self, "OnSizeChanged", self.back.SetSize)
    self:HookEvent(self, "OnSelectedChanged", UpdateBackColor)
    UpdateBackColor(self)
    
    self.genFunc = params.genFunc
    self.owningList = params.owningList
    self.startFunc = params.startFunc
    self.data = params.data
    
    if params.genFunc then -- create arrow indicating this option has sub-options.
        self.arrowGraphic = self:CreateGUIItem()
        self.arrowGraphic:SetTexture(kArrowTexture)
        self.arrowGraphic:SetSizeFromTexture()
        self.arrowGraphic:SetAnchor(1, 0.5)
        self.arrowGraphic:SetHotSpot(0.5, 0.5)
        self.arrowGraphic:SetPosition(-kArrowWidth*0.5, 0)
        self:Set_ArrowColor(MenuStyle.kHighlight * Color(1, 1, 1, 0))
        self:HookEvent(self, "OnSelectedChanged", UpdateArrowColor)
        UpdateArrowColor(self)
    end
    
    self.label = CreateGUIObject("label", GUIMenuTruncatedText, self,
    {
        cls = GUIMenuText,
        defaultColor = MenuStyle.kOptionHeadingColor,
    })
    self.label:AlignLeft()
    self.label:SetPosition(kLabelSpacing, 0)
    self.label:SetFont(MenuStyle.kOptionHeadingFont)
    self.label:SetText(params.label)
    self.labelText = params.label
    self:AddFXReceiver(self.label:GetObject())
    self:HookEvent(self.label, "OnTextSizeChanged", UpdateLabelSize)
    self:HookEvent(self, "OnSizeChanged", UpdateLabelSize)
    
    self:SetHeight(kHeight)
    
    if params.genFunc then
        -- When this option is pressed, create and display the sub-options associated with it.
        self:HookEvent(self, "OnPressed", DisplaySubMenu)
    else
        -- No sub options, we can select it.
        self:HookEvent(self, "OnPressed", SelectThisOption)
    end
    
end
