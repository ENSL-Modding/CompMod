-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/MissionScreen/GUIMenuMission.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A single mission to appear in the mission screen.  Missions consist of a series of steps to
--    complete, which are listed inside this object.
--
--  Parameters (* = required)
--     *missionName
--     *completionCheckTex      The texture to use for the checkbox in the completion object.
--     *completionDescription   The description text to use for the completion object.
--     *stepConfigs             List of configs for each individual step of the mission.
--      completedCallback       Function to fire when the mission is completed.  Does not perform
--                              any checks to ensure this is the first time the mission is
--                              completed, so this will also fire every time the mission GUI is
--                              loaded.
--
--  Properties
--      MissionName     The name of the mission to display at the top of the column.
--      Completed       Whether or not this mission has been completed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")

Script.Load("lua/menu2/MissionScreen/GUIMenuMissionStep.lua")
Script.Load("lua/menu2/MissionScreen/GUIMenuMissionCompletion.lua")

Script.Load("lua/menu2/widgets/GUIMenuScrollPane.lua")

Script.Load("lua/menu2/GUIMenuCoolBox2.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")

---@class GUIMenuMission : GUIObject
local baseClass = GUIObject
class "GUIMenuMission" (baseClass)

GUIMenuMission:AddCompositeClassProperty("Completed", "completionObj")
GUIMenuMission:AddCompositeClassProperty("MissionName", "nameText", "Text")

local kNameAreaHeight = 120
local kWidth = 900

local kListInset = 16

local kNameFont = ReadOnly{ family = "Microgramma", size = 42 }
local kNameColor = MenuStyle.kOptionHeadingColor
local kCompletedNameColor = MenuStyle.kHighlight

local function UpdateNameTextColor(self)
    if self:GetCompleted() then
        self.nameText:SetColor(kCompletedNameColor)
    else
        self.nameText:SetColor(kNameColor)
    end
end

local function UpdateMiddleHeight(self)
    self.listArea:SetHeight(self:GetSize().y - kNameAreaHeight - self.completionObj:GetSize().y)
end

local function UpdateCompleteness(self)
    
    local fullyComplete = true
    for i=1, #self.subStepObjs do
        if not self.subStepObjs[i]:GetCompleted() then
            fullyComplete = false
            break
        end
    end
    
    self:SetCompleted(fullyComplete)

end

local function OnStepCompleted(self, completed)
    
    if completed == false then
        self:SetCompleted(false)
        return -- couldn't possibly be all-complete if this one isn't.
    end
    
    UpdateCompleteness(self)
    
end

local function LoadListContents(self, configs, errorDepth)
    errorDepth = errorDepth + 1
    
    for i=1, #configs do
    
        local newStep = CreateGUIObjectFromConfig(configs[i], self.listLayout)
    
        if not newStep:GetPropertyExists("Completed") then
            error(string.format("Sub-step %d of mission didn't have a property named 'Completed'.", i), errorDepth)
        end
        
        table.insert(self.subStepObjs, newStep)
        self:HookEvent(newStep, "OnCompletedChanged", OnStepCompleted)
        newStep:HookEvent(self.listLayout, "OnSizeChanged", newStep.SetWidth)
        newStep:SetWidth(self.listLayout:GetSize().x)
    
    end
    
end

local function UpdateInnerListAreaSize(self)
    self.innerListArea:SetSize(self.listArea:GetSize().x - kListInset*2, self.listArea:GetSize().y - kListInset*2)
end

function GUIMenuMission:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType("string",            params.missionName,           "params.missionName",           errorDepth)
    RequireType("string",            params.completionCheckTex,    "params.completionCheckTex",    errorDepth)
    RequireType("string",            params.completionDescription, "params.completionDescription", errorDepth)
    RequireType("table",             params.stepConfigs,           "params.stepConfigs",           errorDepth)
    RequireType({"function", "nil"}, params.completedCallback,     "params.completedCallback",     errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self:SetWidth(kWidth)
    
    self.back = CreateGUIObject("back", GUIMenuCoolBox2, self)
    self.back:HookEvent(self, "OnSizeChanged", self.back.SetSize)
    self.back:SetSize(self:GetSize())
    self.back:SetLayer(-2)
    
    self.nameArea = CreateGUIObject("nameArea", GUIObject, self)
    self.nameArea:SetSize(kWidth, kNameAreaHeight)
    
    self.nameText = CreateGUIObject("nameText", GUIText, self.nameArea,
    {
        align = "center",
        font = kNameFont,
        color = kNameColor,
    })
    self:HookEvent(self, "OnCompletedChanged", UpdateNameTextColor)
    self:SetMissionName(params.missionName)
    
    self.listArea = CreateGUIObject("listArea", GUIObject, self)
    self.listArea:SetWidth(kWidth)
    self.listArea:SetY(kNameAreaHeight)
    
    self.innerListArea = CreateGUIObject("innerListArea", GUIMenuBasicBox, self.listArea)
    self.innerListArea:AlignCenter()
    self.innerListArea:SetLayer(-1)
    self:HookEvent(self.listArea, "OnSizeChanged", UpdateInnerListAreaSize)
    UpdateInnerListAreaSize(self)
    
    self.listScrollPane = CreateGUIObject("listScrollPane", GUIMenuScrollPane, self.innerListArea,
    {
        horizontalScrollBarEnabled = false,
    })
    self.listScrollPane:HookEvent(self.innerListArea, "OnSizeChanged", self.listScrollPane.SetSize)
    
    self.listLayout = CreateGUIObject("listLayout", GUIListLayout, self.listScrollPane,
    {
        orientation = "vertical",
        fixedMinorSize = true,
    })
    self.listScrollPane:HookEvent(self.innerListArea, "OnSizeChanged", self.listScrollPane.SetPaneWidth)
    self.listScrollPane:SetPaneWidth(self.innerListArea:GetSize().x)
    
    self.listLayout:HookEvent(self.listScrollPane, "OnContentsSizeChanged", self.listLayout.SetWidth)
    self.listLayout:SetWidth(self.listScrollPane:GetContentsSize())
    
    self.listScrollPane:HookEvent(self.listLayout, "OnSizeChanged", self.listScrollPane.SetPaneHeight)
    self.listScrollPane:SetHeight(self.listLayout:GetSize())
    
    self.subStepObjs = {} -- list of objects that hold the substep data.
    LoadListContents(self, params.stepConfigs, errorDepth)
    
    self.completionObj = CreateGUIObject("completionObj", GUIMenuMissionCompletion, self,
    {
        checkTex = params.completionCheckTex,
        description = params.completionDescription,
        align = "bottom"
    })
    self.completionObj:SetWidth(kWidth)
    self:HookEvent(self.completionObj, "OnSizeChanged", UpdateMiddleHeight)
    self:HookEvent(self, "OnSizeChanged", UpdateMiddleHeight)
    UpdateMiddleHeight(self)
    
    if params.completedCallback then
        self:HookEvent(self, "OnCompletedChanged",
        function(self2, completed)
            if completed then
                params.completedCallback()
            end
        end)
    end
    
    UpdateCompleteness(self)
    
end
