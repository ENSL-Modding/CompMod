-- ======= Copyright (c) 2016, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\KeybindDisplayManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Used to elegantly display keybinds for commands on a player's screen.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIKeybind.lua")

class 'KeybindDisplayManager'

function KeybindDisplayManager:Initialize()
    self.displayed_bindings = {}
    self.color = nil -- default color
end

function KeybindDisplayManager:SetColor(color)
    self.color = color
    self:UpdateColor()
end

function KeybindDisplayManager:UpdateColor()
    for i=1, #self.displayed_bindings do
        self.displayed_bindings[i]:SetColor(self.color)
    end
end

local function GetFriendlyKeyName(name)
    local newName = name
    
    local space_additions = {'Num','Pad','Left','Right','Page','App','Mouse','Button','Wheel','Print', 'Joystick', 'Rotation', 'Pov', 'Slider'}
    for i=1, #space_additions do
        newName = string.gsub(newName, space_additions[i], space_additions[i]..' ')
    end
    
    return newName
end


local function GetKeyIcon(name)

    if name == 'MouseButton0' then
        return 'mouse_left'
    elseif name == 'MouseButton1' then
        return 'mouse_right'
    elseif name == 'MouseButton2' then
        return 'mouse_middle'
    elseif name == 'MouseWheelUp' then
        return 'mouse_wheel_up'
    elseif name == 'MouseWheelDown' then
        return 'mouse_wheel_down'
    elseif string.sub(name,1,11) == 'MouseButton' then
        return 'mouse_unknown'
    elseif name == "MouseX" or name == "MouseY" or name == "MouseZ" then
        return 'mouse_unknown'
    elseif string.sub(name,1,8) == 'Joystick' then
        return 'joystick'
    end
    
    return 'keyboard'
end


-- Multiple keybinds will be shown at once.  It's possible I'll want to hide one, but keep the others, and then
-- that opens up the possibility of adding another keybind, while the others are still active.  This function
-- finds the first unoccupied row index.  Probably waaaaayy overkill... but I'd rather be prepared.
function KeybindDisplayManager:GetFirstAvailableIndex()
    
    local used = {}
    
    for i=1,#self.displayed_bindings do
        used[self.displayed_bindings[i].rowIndex] = true
    end
    
    -- handle overrides
    if self.reserved_rows then
        for i=1,#self.reserved_rows do
            used[self.reserved_rows[i]] = true
        end
    end
    
    for i=0, 100 do -- if there's over 100 bindings, you've got bigger problems
        if used[i] ~= true then
            return i
        end
    end
    
end


function KeybindDisplayManager:AddReservedRow(rowNum)
    self.reserved_rows = self.reserved_rows or {}
    self.reserved_rows[#self.reserved_rows+1] = rowNum
end


function KeybindDisplayManager:ClearReservedRows()
    self.reserved_rows = {}
end


function KeybindDisplayManager:UpdateAllBindings()
    
    -- called when the user changes their bindings in the options menu.
    for i=1, #self.displayed_bindings do
        local bind = self.displayed_bindings[i]
        local keyIcon
        local neatName
        local isLiteral = self.displayed_bindings[i]:GetIsLiteral()
        local name = ((not isLiteral) and BindingsUI_GetInputValue(bind.control)) or bind.control
        if name == "" or name == "None" then
            name = "[unbound]"
            keyIcon = "none"
            neatName = "(Unbound!)"
        else
            keyIcon = GetKeyIcon(name)
            neatName = GetFriendlyKeyName(name)
        end
        
        bind:UpdateKey(keyIcon, neatName)
    end
end


function KeybindDisplayManager:GetIsBindingDisplayed(control, label, include_leaving)
    -- label is optional, ignored if nil, but if not nil, the keybind's action description must match.
    local include_out = include_leaving or false    -- optional paramater to specify if we should include
                                                    -- bindings that are animating out.  Default to false.
    
    for i=1, #self.displayed_bindings do
        local bind = self.displayed_bindings[i]
        if (bind.anim_state == 'out' or bind.anim_state == 'leaving') and include_out == false then
            goto continue
        end
        if bind.control == control then
            if label ~= nil and label == bind.actionDesc then
                return true, bind
            end
            return false
        end
        ::continue::
    end
    
    return false
    
end


-- controlIsNameOverride: optional parameter that forces "name" to just be the string passed to it, rather
-- than attempting to perform a lookup in the bindings.  This is for situations where controls are hard-coded
-- into the game, and not re-bindable (eg commander spacebar to jump to notifications.)
function KeybindDisplayManager:DisplayBinding(control, label, controlIsNameOverride)
    
    local keyIcon
    local neatName
    local name = ((not controlIsNameOverride) and BindingsUI_GetInputValue(control)) or control
    if name == "" or name == "None" then
        name = "[unbound]"
        keyIcon = "none"
        neatName = "(Unbound!)"
    else
        keyIcon = GetKeyIcon(name)
        neatName = GetFriendlyKeyName(name)
    end
    
    -- first look to see if this binding is already being displayed, and if so, re-use this slot
    local result, bind = self:GetIsBindingDisplayed(control, label, true)
    if result == true and bind ~= nil then
        if bind.anim_state == 'out' or bind.anim_state == 'leaving' then
            bind:AnimateIn()
        end
    else
        local new_keybind_panel = GetGUIManager():CreateGUIScript("KeybindPanel")
        new_keybind_panel:SetKeybind(control, keyIcon, neatName, label)
        new_keybind_panel:SetParent(self.displayed_bindings)
        new_keybind_panel:SetIndex(self:GetFirstAvailableIndex()) -- row indexes start at 0.
        new_keybind_panel:SetIsLiteral(controlIsNameOverride == true)
        self.displayed_bindings[#self.displayed_bindings + 1] = new_keybind_panel
        new_keybind_panel:AnimateIn()
        if self.color then
            new_keybind_panel:SetColor(self.color)
        end
    end
end


function KeybindDisplayManager:GetNumActiveBindings()
    local sum = 0
    for i = 1, #self.displayed_bindings do
        local bind = self.displayed_bindings[i]
        if bind.anim_state == 'in' or bind.anim_state == 'arriving' then
            sum = sum + 1
        end
    end
    return sum
end


function KeybindDisplayManager:DestroyBinding(control)
    
    for i = 1, #self.displayed_bindings do
        local bind = self.displayed_bindings[i]
        if bind.control == control and (bind.anim_state == 'in' or bind.anim_state == 'arriving') then
            bind:AnimateOut(    function(_)
                                    GetKeybindDisplayManager():RemoveBindingFromTable(control)
                                end,
                                true)
            break
        end
    end
    
end


function KeybindDisplayManager:SetAllBindingsVisibile(vis)
    
    for i = 1, #self.displayed_bindings do
        self.displayed_bindings[i]:SetVisibilitiesOverride(vis)
    end
    
end


function KeybindDisplayManager:RemoveBindingFromTable(control)
    for i = 1, #self.displayed_bindings do
        local bind = self.displayed_bindings[i]
        if bind.control == control then
            table.remove(self.displayed_bindings, i)
            break
        end
    end
    
end


function KeybindDisplayManager:DestroyAllBindings()
    for i = 1, #self.displayed_bindings do
        local bind = self.displayed_bindings[i]
        if bind.anim_state == 'in' or bind.anim_state == 'arriving' then
            bind:AnimateOut(    function(self)
                                    GetKeybindDisplayManager():RemoveBindingFromTable(bind.control)
                                end,
                                true)
        end
    end
end

local gKeybindDisplayManager
function GetKeybindDisplayManager()
    if not gKeybindDisplayManager then
        gKeybindDisplayManager = KeybindDisplayManager()
        gKeybindDisplayManager:Initialize()
    end
    
    return gKeybindDisplayManager
end

