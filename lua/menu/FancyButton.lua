-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\FancyButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A clickable area that can contain any number of "FancyElements".  It is made of two
--    components: the visual "elements" for each state (currently only "over" and "grey"
--    (not-over); and a physical "clickable" surface.  This can be a simple box, or a more
--    complex polygon.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/FancyElement.lua")

class 'FancyButton' (FancyElement)

-- index -> state
FancyButton.kValidStates = {"grey", "over"}
-- state -> index
for i=1, #FancyButton.kValidStates do
    FancyButton.kValidStates[FancyButton.kValidStates[i]] = i
end

function FancyButton:Initialize()
    
    FancyElement.Initialize(self)
    
    self.stateElements = {}
    self.clickable = nil
    self.visibility = true -- button visibility.  Overrides individual elements.
    self.eventInputs = {} -- for button behavior to influence shader parameters in the child elements.
    
    getmetatable(self).__tostring = FancyButton.ToString
    
end

function FancyButton:ToString()
    
    local str = FancyElement.ToString(self)
    str = str .. string.format("    stateElements = %s\n    clickable = %s\n    visibility = %s\n", ToString(self.stateElements), self.clickable, self.visibility)
    return str
    
end

function FancyButton:Destroy()
    
    if self.clickable then
        GetGUIManager():DestroyGUIScript(self.clickable)
        self.clickable = nil
    end
    
    FancyElement.Destroy(self)
    
end

function FancyButton:GetElementForState(state)
    
    if not state then
        Log("WARNING: Attempted to call FancyButton:GetElementForState() with nil.")
        return
    end
    
    if not FancyButton.kValidStates[state] then
        Log("WARNING: Attempted to call FancyButton:GetElementForState() with unrecognized state \"%s\".", state)
        return
    end
    
    if not self.stateElements[state] then
        local newElement = FancyElement()
        self.stateElements[state] = newElement
        newElement:Initialize()
        self:AddChild(newElement)
    end
    
    -- default to "out" state when we've initialized the buttons.
    self:UpdateVisibleState("out")
    
    return self.stateElements[state]
    
end

function FancyButton:SetRelativePosition(position)
    
    FancyElement.SetRelativePosition(self, position)
    
    -- clickable isn't a child of this element... it won't inherit transforms.  Need to set it
    -- manually.
    if self.clickable then
        self.clickable:SetPosition(self:GetAbsolutePosition())
    end
    
end

function FancyButton:SetRelativeScale(scale)
    
    FancyElement.SetRelativeScale(self, scale)
    
    -- clickable isn't a child of this element... it won't inherit transforms.  Need to set it
    -- manually.
    if self.clickable then
        self.clickable:SetScale(self:GetAbsoluteScale())
    end
    
end

function FancyButton:SetClickable(clickable)
    
    self.clickable = clickable
    clickable:SetPosition(self:GetAbsolutePosition())
    clickable:SetScale(self:GetAbsoluteScale())
    clickable.parent = self
    
end

function FancyButton:GetClickable()
    
    return self.clickable
    
end

function FancyButton:SetupEventInput(eventName, inputName, element)
    
    local newEvent = { inputName = inputName, element = element }
    if not self.eventInputs[eventName] then
        self.eventInputs[eventName] = {}
    end
    
    self.eventInputs[eventName][#self.eventInputs[eventName] + 1] = newEvent
    
end

function FancyButton:OnCallback(callbackName)
    
    if callbackName == "mouseOver" then
        self:UpdateVisibleState("over")
        MainMenu_OnMouseIn()
    elseif callbackName == "mouseOut" then
        self:UpdateVisibleState("out")
    elseif callbackName == "mouse0Down" then
        MainMenu_OnButtonClicked()
    end
    
    local eventInput = self.eventInputs[callbackName]
    if eventInput then
        for i=1, #eventInput do
            eventInput[i].element:SetShaderParameter({name = eventInput[i].inputName, value = Shared.GetTime()})
        end
    end
    
end

function FancyButton:UpdateVisibleState(state)
    
    if self.visibility then
        if state == "over" then
            if self.stateElements["over"] then
                self.stateElements["over"]:SetIsVisible(true)
            end
            
            if self.stateElements["grey"] then
                self.stateElements["grey"]:SetIsVisible(false)
            end
        elseif state == "out" then
            if self.stateElements["over"] then
                self.stateElements["over"]:SetIsVisible(false)
            end
            
            if self.stateElements["grey"] then
                self.stateElements["grey"]:SetIsVisible(true)
            end
        end
    else
        if self.stateElements["over"] then
            self.stateElements["over"]:SetIsVisible(false)
        end
        
        if self.stateElements["grey"] then
            self.stateElements["grey"]:SetIsVisible(false)
        end
    end
    
end

function FancyButton:SetIsVisible(state)
    
    FancyElement.SetIsVisible(self, state)
    
    self.visibility = state
    
    for i=1, #FancyButton.kValidStates do
        if self.stateElements[FancyButton.kValidStates[i]] then
            self.stateElements[FancyButton.kValidStates[i]]:SetIsVisible(state)
        end
    end
    
    self.clickable:SetIsEnabled(state)
    
    if state then
        self:UpdateVisibleState("out")
    end
    
end
