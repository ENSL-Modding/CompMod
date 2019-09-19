-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/ExtraMenuButtons/GUIMenuExtraButtons.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    An extra set of buttons on the bottom of the screen for extra menu options to be added to
--    (eg modders wanting to add a button to the main menu, or server ops wanting a link to their
--    main page, etc.)
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/widgets/GUIMenuButton.lua")
Script.Load("lua/GUI/layouts/GUIListLayout.lua")

---@class GUIMenuExtraButtons : GUIObject
class "GUIMenuExtraButtons" (GUIObject)

local kBottomOffsetY = -165

local extraButtonsBar -- only created when needed.

function AddMainMenuButton(name, label, optionalPressedCallback)
    
    if not extraButtonsBar then
        extraButtonsBar = CreateGUIObject("extraButtonsBar", GUIMenuExtraButtons, GetMainMenu())
    end
    
    return (extraButtonsBar:AddButton(name, label, optionalPressedCallback))

end

function RemoveMainMenuButton(name)
    
    if not extraButtonsBar then
        return false
    end
    
    return (extraButtonsBar:RemoveButton(name))
    
end

local function UpdateResolutionScaling(self, newX, newY, oldX, oldY)
    
    local mockupRes = Vector(3840, 2160, 0)
    local res = Vector(newX, newY, 0)
    local scale = res / mockupRes
    scale = math.min(scale.x, scale.y)
    
    self:SetScale(scale, scale)

end

function GUIMenuExtraButtons:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self,
    {
        orientation = "horizontal",
    })
    self:HookEvent(self.layout, "OnSizeChanged", self.SetSize)
    
    self:SetLayer(50) -- underneath GUIMenuNavBar @ 100
    self:AlignBottom()
    self:SetY(kBottomOffsetY)
    self:HookEvent(GetGlobalEventDispatcher(), "OnResolutionChanged", UpdateResolutionScaling)
    UpdateResolutionScaling(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
    self.buttons = {} -- mapping of button name --> button object.
    
end

function GUIMenuExtraButtons:AddButton(name, label, optionalPressedCallback)
    
    RequireType("string", name, "name", 2)
    RequireType("string", label, "label", 2)
    RequireType({"function", "nil"}, optionalPressedCallback, "optionalPressedCallback", 2)
    
    if self.buttons[name] then
        error(string.format("Button named '%s' already exists!", name), 2)
    end
    
    local newButton = CreateGUIObject(name, GUIMenuButton, self.layout,
    {
        label = label,
    })
    if optionalPressedCallback then
        newButton:HookEvent(newButton, "OnPressed", optionalPressedCallback)
    end
    self.buttons[name] = newButton
    
    return newButton
    
end

function GUIMenuExtraButtons:RemoveButton(name)
    
    RequireType("string", name, "name", 2)
    
    if not self.buttons[name] then
        return false
    end
    
    local button = self.buttons[name]
    self.buttons[name] = nil
    button:Destroy()
    
    return true
    
end

--[=[
Event.Hook("Console_debug_add_button", function(name, ...)
    
    if not name then
        Log("usage: debug_add_button name label labelpart2 labelpart3 ..etc.")
        return
    end
    
    local label = {...}
    label = table.concat(label, " ")
    AddMainMenuButton(name, label, function() Log("you clicked the '%s' button!", name) end)

    Log("added button '%s' with label '%s'.", name, label)
    
end)
--]=]
