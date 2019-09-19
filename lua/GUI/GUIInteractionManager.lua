-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/GUIInteractionManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Manages interactions with the gui system.  Interactions include:
--      Mouse movement
--      Mouse clicks
--      Mouse wheel
--      Keyboard key presses
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIDebug.lua")
Script.Load("lua/GUI/BaseGUIManager.lua")
Script.Load("lua/UnorderedSet.lua")

--- @class GUIInteractionManager : BaseGUIManager
class "GUIInteractionManager" (BaseGUIManager)

GUIInteractionManager.Interaction_Cursor    = GUIItem.Interaction_1
GUIInteractionManager.Interaction_Wheel     = GUIItem.Interaction_2
GUIInteractionManager.Interaction_Keyboard  = GUIItem.Interaction_3

-- Keep track of which keys are already down so we can ignore repeats.
local downKeys = UnorderedSet()

-- Apparently there is no standard for double-click speed, so we'll just use the default
-- Windows timing.  According to the MSDN docs, this is 500ms.
local kDoubleClickThresholdTime = 0.5

-- Used to receive sorted list of eligible GUIItem event receivers.  Local b/c this should never be
-- used outside of this class.
local guiItemArray = GUIItemArray()

local function DBGCursorLog(formatString, ...)
    if not gCursorEventLog then return end
    Log(formatString, ...)
end

local function DBGCursorHoverLog(formatString, ...)
    if not gHoverEventLog then return end
    Log(formatString, ...)
end

local function DBGClickLog(formatString, ...)
    if not gClickEventLog then return end
    Log(formatString, ...)
end

local function DBGWheelLog(formatString, ...)
    if not gWheelEventLog then return end
    Log(formatString, ...)
end

local function DBGKeyLog(formatString, ...)
    if not gKeyEventLog then return end
    Log(formatString, ...)
end

local function GetStackExists(self, stackName)
    
    PROFILE("GUIInteractionManager.GetStackExists")
    
    return (self.stacks and self.stacks[stackName]) ~= nil

end

local function CreateStack(self, stackName)
    
    PROFILE("GUIInteractionManager.CreateStack")
    
    assert(not GetStackExists(self, stackName))
    self.stacks = self.stacks or {}
    self.stacks[stackName] = {}
    self.stacks[#self.stacks + 1] = stackName

end

local function GetStack(self, stackName)
    
    PROFILE("GUIInteractionManager.GetStack")
    
    assert(GetStackExists(self, stackName))
    return self.stacks[stackName]

end

local function PeekStack(self, stackName)
    
    PROFILE("GUIInteractionManager.PeekStack")
    
    assert(GetStackExists(self, stackName))
    local stack = GetStack(self, stackName)
    return stack[#stack]

end

local function AddObjectToStack(self, stackName, guiObj)
    
    PROFILE("GUIInteractionManager.AddObjectToStack")
    
    assert(GetStackExists(self, stackName))
    assert(guiObj ~= nil)
    local stack = GetStack(self, stackName)
    table.insert(stack, guiObj)

end

local function RemoveObjectFromStack(self, stackName, guiObj)
    
    PROFILE("GUIInteractionManager.RemoveObjectFromStack")
    
    assert(GetStackExists(self, stackName))
    assert(guiObj ~= nil)
    local stack = GetStack(self, stackName)
    local found = false
    for i=#stack, 1, -1 do
        if stack[i] == guiObj then
            table.remove(stack, i)
            found = true
        end
    end
    
    return found

end

local function RemoveObjectFromAllStacks(self, guiObj)
    
    PROFILE("GUIInteractionManager.RemoveObjectFromAllStacks")
    
    assert(guiObj ~= nil)
    for i=1, #self.stacks do
        RemoveObjectFromStack(self, self.stacks[i], guiObj)
    end

end

-------------------------
-- FROM BaseGUIManager --
-------------------------

function GUIInteractionManager:Initialize()
    
    BaseGUIManager.Initialize(self)
    
    -- Receive mouse wheel events from the mouse tracker.
    MouseTracker_ListenToWheel(self)
    
    -- Mapping of GUIItem -> GUIObject which receives events from this item.
    self.cursorListeners = {}
    self.wheelListeners = {}
    self.keyListeners = {}
    self.blockers = {}
    
    -- The object that the mouse is currently over.
    self.hoverObj = nil
    
    -- The object that the mouse was clicked down on.
    self.clickObj = nil
    
    -- If the same item is clicked twice within a short amount of time, the click is passed as a
    -- "double" click.
    self.doubleClickObj = nil
    self.doubleClickTime = 0
    
    -- Detect if calls to add/remove listeners is performed inside of a call to GUIObject:IsPointOverObject()
    self.pointOverObjectCallLock = false
    
    CreateStack(self, "CharacterReceiver")
    CreateStack(self, "ModalObject")

end

local function GetCharacterReceiverObject(self)
    local result = PeekStack(self, "CharacterReceiver")
    return result
end

function GUIInteractionManager:OnObjectDestroyed(guiObject)
    
    if guiObject == self.tempObject then
        self.tempObject = nil
    end
    
    if guiObject == self.hoverObj then
        self.hoverObj = nil
    end
    
    if guiObject == self.clickObj then
        self.clickObj = nil
    end
    
    if guiObject == self.doubleClickObj then
        self.doubleClickObj = nil
    end
    
    RemoveObjectFromAllStacks(self, guiObject)

end

function GUIInteractionManager:Update(deltaTime, now)
    
    if not Client.GetIsWindowFocused() or Client.GetIsSteamOverlayActive() then
        -- We can't keep track of downed keys when we lose focus.  Release them here.
        while #downKeys > 0 do
            local key = downKeys[1]
            self:SendKeyEvent(key, false)
        end
    end
    
    -- Ensure mouse cursor position is up-to-date.
    self:UpdateMouseCursorPosition()
    
end

--------------------
-- PUBLIC METHODS --
--------------------

local function MouseOverItemCheck(self, guiObject, pt)
    
    self.pointOverObjectCallLock = true
    local result = guiObject:IsPointOverObject(pt)
    self.pointOverObjectCallLock = false
    return result

end

local function AddListener(self, guiObject, triggeringItem, listenerTable, itemFlag)
    
    AssertIsaGUIObject(guiObject, 1)
    AssertIsaGUIItem(triggeringItem, 1)
    
    if listenerTable[triggeringItem] ~= nil then
        listenerTable = nil -- else it will dominate the stack trace.
        error("A GUIObject attempted to listen to a GUIItem that was already being listened to!")
    end
    
    if self.pointOverObjectCallLock then
        listenerTable = nil -- else it will dominate the stack trace.
        error("Detected a call to AddListener inside of a call to GUIObject:IsPointOverObject()!  Do you want nil index errors?  Because that's how you get nil index errors!")
    end
    
    listenerTable[triggeringItem] = guiObject
    triggeringItem:SetOptionFlag(itemFlag)

end

local function RemoveListener(self, guiObject, triggeringItem, listenerTable, itemFlag)
    
    AssertIsaGUIObject(guiObject, 1)
    AssertIsaGUIItem(triggeringItem, 1)
    
    if self.pointOverObjectCallLock then
        error("Detected a call to RemoveListener inside of a call to GUIObject:IsPointOverObject()!  Do you want nil index errors?  Because that's how you get nil index errors!")
    end
    
    if listenerTable[triggeringItem] == nil then
        return -- Triggering item was already not being listened to.
    end
    
    if listenerTable[triggeringItem] ~= guiObject then
        error("Triggering item was being listened to by a different GUIObject.", 2)
    end
    
    listenerTable[triggeringItem] = nil
    triggeringItem:ClearOptionFlag(itemFlag)

end

-- See GUIObject:ListenForCursorInteractions()
function GUIInteractionManager:ListenForMouseCursor(guiObject, triggeringItem)
    AddListener(self, guiObject, triggeringItem, self.cursorListeners, GUIInteractionManager.Interaction_Cursor)
end

-- See GUIObject:ListenForWheelInteractions()
function GUIInteractionManager:ListenForMouseWheel(guiObject, triggeringItem)
    AddListener(self, guiObject, triggeringItem, self.wheelListeners, GUIInteractionManager.Interaction_Wheel)
end

-- See GUIObject:ListenForKeyInteractions()
function GUIInteractionManager:ListenForKey(guiObject, triggeringItem)
    AddListener(self, guiObject, triggeringItem, self.keyListeners, GUIInteractionManager.Interaction_Keyboard)
end

-- Causes this GUIItem to block all interactions with its children -- children (and their
-- descendants) will no longer receive keyboard, cursor, or wheel events.  This item, however, will
-- still receive events -- although it is not required to in order to block.
function GUIInteractionManager:BlockChildInteractions(item)
    
    AssertIsaGUIItem(item, 1)
    
    self.blockers[item] = true
    item:SetOptionFlag(GUIItem.Interaction_BlockChildren)

end

-- This GUIItem will no longer block interactions with its descendants.
function GUIInteractionManager:AllowChildInteractions(item)
    
    AssertIsaGUIItem(item, 1)
    
    self.blockers[item] = nil
    item:ClearOptionFlag(GUIItem.Interaction_BlockChildren)

end

-- See GUIObject:StopListeningForCursorInteractions()
function GUIInteractionManager:StopListeningForMouseCursor(guiObject, triggeringItem)
    RemoveListener(self, guiObject, triggeringItem, self.cursorListeners, GUIInteractionManager.Interaction_Cursor)
    
    -- Make sure the object we're no longer listening for isn't a temporary object still in use in
    -- some other function.
    if guiObject == self.tempObject then
        self.tempObject = nil
    end
    
    -- Make sure the object we're no longer listening for isn't the object we're hovering over.
    if guiObject == self.hoverObj then
        self.hoverObj = nil
    end
    
    -- Make sure the object we're no longer listening for isn't the object we clicked down on.
    if guiObject == self.clickObj then
        self.clickObj = nil
    end
    
    -- Make sure the object we're no longer listening for isn't the object we started a double-click on.
    if guiObject == self.doubleClickObj then
        self.doubleClickObj = nil
    end
    
    -- Reference used in ProcessMouseClickEvent() for firing global event after mouse click.
    if guiObject == self.tempClickObj then
        self.tempClickObj = nil
    end

end

-- See GUIObject:StopListeningForWheelInteractions()
function GUIInteractionManager:StopListeningForMouseWheel(guiObject, triggeringItem)
    RemoveListener(self, guiObject, triggeringItem, self.wheelListeners, GUIInteractionManager.Interaction_Wheel)
end

-- See GUIObject:StopListeningForKeyInteractions()
function GUIInteractionManager:StopListeningForKey(guiObject, triggeringItem)
    RemoveListener(self, guiObject, triggeringItem, self.keyListeners, GUIInteractionManager.Interaction_Keyboard)
end

function GUIInteractionManager:AddGUIObjectToCharacterReceiverStack(guiObj)
    
    AssertIsaGUIObject(guiObj)
    AddObjectToStack(self, "CharacterReceiver", guiObj)

end

function GUIInteractionManager:RemoveGUIObjectFromCharacterReceiverStack(guiObj)
    
    AssertIsaGUIObject(guiObj)
    RemoveObjectFromStack(self, "CharacterReceiver", guiObj)

end

function GUIInteractionManager:AddGUIObjectToModalObjectStack(guiObj)
    
    AssertIsaGUIObject(guiObj)
    AddObjectToStack(self, "ModalObject", guiObj)

end

function GUIInteractionManager:RemoveGUIObjectFromModalObjectStack(guiObj)
    
    AssertIsaGUIObject(guiObj)
    RemoveObjectFromStack(self, "ModalObject", guiObj)

end

-------------
-- PRIVATE --
-------------

local function GetModalObject(self)
    local result = PeekStack(self, "ModalObject")
    return result
end

local function GetModalItem(self)
    local modalObject = GetModalObject(self)
    if modalObject ~= nil then
        local result = modalObject:GetRootItem()
        return result
    end
    return nil
end

function GUIInteractionManager:GetModalItem()
    local result = GetModalItem(self)
    return result
end

local function ProcessMouseClickEvent(self)
    
    DBGClickLog("GUIInteractionManager ProcessMouseClickEvent()")
    
    local mousePos = GetGlobalEventDispatcher():GetMousePosition()
    local now = Shared.GetTime()
    GUI.GetInteractionsUnderPoint(guiItemArray, mousePos.x, mousePos.y, GUIInteractionManager.Interaction_Cursor, GetModalItem(self))
    
    -- Log list of items, if logging is enabled.
    if gClickEventLog then
        
        for i=0, guiItemArray:GetSize() - 1 do
            
            local item = guiItemArray:Get(i)
            local bka = Debug_GetBKAForItem(item)
            
            DBGClickLog("    %s) %s", i, bka)
        
        end
    end
    
    for i=0, guiItemArray:GetSize() - 1 do
        
        local triggeringItem = guiItemArray:Get(i)
        
        local guiObject = self.cursorListeners[triggeringItem]
        if guiObject == nil then
            error("triggeringItem for OnMouseClick was not present in the cursor listeners keys!  Was GUIInteractionManager.Interaction_Cursor flag set on an item outside this GUIInteractionManager? (wags finger)")
        end
        
        -- Debug log
        local bka
        if gClickEventLog then
            bka = Debug_GetBKAForItem(triggeringItem)
            DBGClickLog("checking item '%s'...", bka)
        end
        
        if MouseOverItemCheck(self, guiObject, mousePos) then
            
            local double = false
            if guiObject == self.doubleClickObj and now <= self.doubleClickTime and guiObject:GetCanBeDoubleClicked() then
                double = true
            end
            
            if double then
                self.doubleClickObj = nil
                self.clickObj = nil
            else
                self.clickObj = guiObject
                self.doubleClickObj = guiObject
                self.doubleClickTime = now + kDoubleClickThresholdTime
            end
            
            DBGClickLog("MouseOverItemCheck passed for item '%s'.", bka)
            DBGClickLog("Calling OnMouseClick(double=%s) for item '%s'.", double, bka)
            
            -- Store a member reference so it can be invalidated if OnMouseClick results in this
            -- object's destruction.
            self.tempClickObj = guiObject
            
            guiObject:OnMouseClick(double)
            
            if self.tempClickObj then
                SendOnGUIObjectClicked(guiObject)
                self.tempClickObj = nil
            end
            
            -- Event was accepted and consumed
            return true
        
        end
        
        DBGClickLog("MouseOverItemCheck failed for item '%s'.", bka)
    
    end
    
    if GetModalObject(self) then
        -- Cursor wasn't over any objects, but a modal object is present, so we always return true.
        
        local modalObj = GetModalObject(self)
        
        if gClickEventLog then
            DBGClickLog("calling OnOutsideClick for modal item '%s'.", Debug_GetBKAForItem(modalObj:GetRootItem()))
        end
        
        modalObj:OnOutsideClick()
        return true
    end
    
    DBGClickLog("no items found to consume click.")
    
    return false

end

local function ProcessMouseReleaseEvent(self)
    
    DBGClickLog("GUIInteractionManager ProcessMouseReleaseEvent()")
    
    if self.clickObj == nil then
        
        DBGClickLog("no object was clicked down on to consume release event.")
        
        return false -- no item was clicked down on (that we care about).
    end
    
    -- This is a little bit tricky.  We want to first fire the OnMouseRelease or OnMouseClick
    -- methods, but those calls could quite reasonably result in the object being destroyed.  We'll
    -- detect this by storing the object as a member variable which will be set to nil if the
    -- object is destroyed or if it stops being a listener.
    
    self.tempObject = self.clickObj
    
    DBGClickLog("processing release for item '%s'", Debug_GetBKAForItem(self.tempObject:GetRootItem()))
    
    local mousePos = GetGlobalEventDispatcher():GetMousePosition()
    local minCorner, maxCorner = GetGUIItemScreenSpaceBounds(self.tempObject:GetRootItem())
    local mouseOverRect = mousePos.x >= minCorner.x and mousePos.y >= minCorner.y and
            mousePos.x < maxCorner.x and mousePos.y < maxCorner.y
    
    if mouseOverRect and MouseOverItemCheck(self, self.tempObject, mousePos) then
        DBGClickLog("cursor over item, calling OnMouseRelease()...")
        self.tempObject:OnMouseRelease()
    else
        DBGClickLog("cursor over item, calling OnMouseCancel()...")
        self.tempObject:OnMouseCancel()
    end
    
    if self.tempObject == nil then
        -- The temp object was destroyed due to the call to OnMouseRelease() or OnMouseCancel().
        DBGClickLog("item destroyed by above call.  No OnMouseUp() call will be performed.")
        return true
    end
    
    DBGClickLog("Calling OnMouseUp()...")
    
    self.tempObject:OnMouseUp()
    self.tempObject = nil
    
    self.clickObj = nil
    
    return true

end

local function ProcessKeyEvent(self, key, down)
    
    -- If a key is already registered as being down, ignore it.  This is a repeat key press (eg
    -- key held down).
    if down and downKeys:Contains(key) then
        return
    end
    
    -- Keep track of which keys are down and which aren't.
    if down then
        downKeys:Add(key)
    else -- up
        if downKeys:Contains(key) then
            downKeys:RemoveElement(key)
        else
            -- Ignore up presses if we don't have a corresponding earlier down key press.
            return
        end
    end
    
    GUI.GetInteractions(guiItemArray, GUIInteractionManager.Interaction_Keyboard, GetModalItem(self))
    
    -- Log list of items, if logging is enabled.
    if gKeyEventLog then
        
        DBGKeyLog("GUIInteractionManager ProcessKeyEvent()")
        DBGKeyLog("    key = %s", key)
        DBGKeyLog("    down = %s", down)
        
        for i=0, guiItemArray:GetSize() - 1 do
            
            local item = guiItemArray:Get(i)
            local bka = Debug_GetBKAForItem(item)
            
            DBGKeyLog("    %s) %s", i, bka)
        
        end
    end
    
    for i=0, guiItemArray:GetSize() - 1 do
        
        local triggeringItem = guiItemArray:Get(i)
        
        local guiObject = self.keyListeners[triggeringItem]
        if guiObject == nil then
            error("triggeringItem for OnKey was not present in the key listeners keys!  Was GUIInteractionManager.Interaction_Keyboard flag set on an item outside this GUIInteractionManager? (wags finger)")
        end
        
        DBGKeyLog("Calling OnKey for item '%s'...", Debug_GetBKAForItem(guiObject:GetRootItem()))
        
        if guiObject:OnKey(key, down) ~= false then -- equate nil with true
            -- Event was accepted and consumed.
            DBGKeyLog("OnKey returned successful, event consumed")
            
            return true
        else
            DBGKeyLog("OnKey returned false, event not consumed")
        end
    
    end
    
    if GetModalObject(self) ~= nil then
        
        DBGKeyLog("No consumer found for event, but a modal object is present, so new GUI system consumes anyways.")
        
        return true -- always consume the event if a modal object is present.
    end
    
    DBGKeyLog("No consumer found for event, passing to legacy system.")
    
    return false

end

-- Cancels a held-click for the given object.  For example, if the user has clicked down on this
-- object, and that triggers some behavior that will conflict with a potential OnMouseRelease
-- event, we want to cancel the OnMouseRelease before it can happen.  For example, if the user is
-- prompted to enter a keybind, and they click on the keybind, the OnMouseClick will be accepted as
-- their key choice... but if they then release the mouse over the widget, it will begin listening
-- again, which is certainly not what the user intended.  This function cancels a pending click,
-- but only if the pending click belongs to the object passed (don't want objects canceling each
-- others clicks accidentally!)
-- NOTE: This completely cancels the mouse release -- it does NOT result in calls to
-- OnMouseRelease, OnMouseCancel, or OnMouseUp.  Use with care, don't let your objects get sticky!
function GUIInteractionManager:CancelPendingMouseRelease(guiObj)
    
    AssertIsaGUIObject(guiObj)
    
    if self.clickObj and self.clickObj == guiObj then
        self.clickObj = nil
    end

end

-- Called by InputHandler when a key is received from the engine.
function GUIInteractionManager:SendKeyEvent(key, down)
    
    -- Ensure mouse cursor position is up-to-date.
    self:UpdateMouseCursorPosition()
    
    -- Treat mouse buttons differently.
    if key == InputKey.MouseButton0 then
        
        if down then
            local result = ProcessMouseClickEvent(self)
            return result
        else
            local result = ProcessMouseReleaseEvent(self)
            return result
        end
    
    else -- TODO treat RMB as its own special event too?
        
        local result = ProcessKeyEvent(self, key, down)
        return result
    
    end

end

-- Called by MouseTracker when the mouse wheel is rolled up or down.
function GUIInteractionManager:OnMouseWheel(up)
    
    -- Ensure mouse cursor position is up-to-date.
    self:UpdateMouseCursorPosition()
    
    local mousePos = GetGlobalEventDispatcher():GetMousePosition()
    GUI.GetInteractionsUnderPoint(guiItemArray, mousePos.x, mousePos.y, GUIInteractionManager.Interaction_Wheel, GetModalItem(self))
    
    -- Log list of items, if logging is enabled.
    if gWheelEventLog then
        
        DBGWheelLog("GUIInteractionManager:OnMouseWheel()")
        DBGWheelLog("    up = %s", up)
        
        for i=0, guiItemArray:GetSize() - 1 do
            
            local item = guiItemArray:Get(i)
            local bka = Debug_GetBKAForItem(item)
            
            DBGWheelLog("    %s) %s", i, bka)
        
        end
    end
    
    for i=0, guiItemArray:GetSize() - 1 do
        
        local triggeringItem = guiItemArray:Get(i)
        
        local guiObject = self.wheelListeners[triggeringItem]
        if guiObject == nil then
            error("triggeringItem for OnMouseWheel was not present in the wheel listeners keys!  Was GUIInteractionManager.Interaction_Wheel flag set on an item outside this GUIInteractionManager? (wags finger)")
        end
        
        -- Debug log
        if gWheelEventLog then
            local bka = Debug_GetBKAForItem(triggeringItem)
            DBGWheelLog("checking item '%s'...", bka)
        end
        
        if MouseOverItemCheck(self, guiObject, mousePos) then
            
            DBGWheelLog("MouseOverItemCheck passed.")
            DBGWheelLog("Calling OnMouseWheel...")
            
            if guiObject:OnMouseWheel(up) ~= false then
                
                DBGWheelLog("OnMouseWheel returned successful, event consumed.")
                
                return true
            else
                DBGWheelLog("OnMouseWheel returned false, event not consumed.")
            end
        else
            DBGWheelLog("MouseOverItemCheck failed.")
        end
    end
    
    if GetModalObject(self) ~= nil then
        
        -- Cursor wasn't over any objects, but a modal object is present, so we always return true.
        local modalObj = GetModalObject(self)
        
        if gWheelEventLog then
            DBGWheelLog("calling OnOutsideWheel for modal item '%s'.", Debug_GetBKAForItem(modalObj:GetRootItem()))
        end
        
        modalObj:OnOutsideWheel(up)
        return true -- Always consume events when there is a modal object present.
    end
    
    DBGWheelLog("No consumer found for event, passing to legacy system.")
    
    -- Nothing consumed this event.  Toss it back to the InputHandler.
    return false

end

-- Called by InputHandler when a keyboard key is pressed.
function GUIInteractionManager:SendCharacterEvent(wideCharacter)
    
    -- Ensure mouse cursor position is up-to-date.
    self:UpdateMouseCursorPosition()
    
    local receiver = GetCharacterReceiverObject(self)
    if receiver then
        
        local character = GUI.ConvertWideStringToUTF8String(wideCharacter)
        receiver:OnCharacter(character)
        
        return true -- new GUI system is taking the character.
    end
    
    return false -- let legacy GUI system take a crack at it.

end

-- Can be called at any time to ensure the mouse cursor position stored in GlobalEventDispatcher is
-- current.
local lastMouseUpdateTime = -1
function GUIInteractionManager:UpdateMouseCursorPosition()
    
    -- Only perform the actual interactions once per frame.  Check this by comparing the current
    -- time to the last time it was updated.
    local now = Shared.GetTime()
    if now == lastMouseUpdateTime then
        return -- already updated this frame.
    end
    lastMouseUpdateTime = now
    
    -- Update the value stored in the GlobalEventDispatcher.
    local mousePosX, mousePosY = Client.GetCursorPosScreen()
    local screenWidth = Client.GetScreenWidth()
    local screenHeight = Client.GetScreenHeight()
    local mousePos = Vector(Clamp(mousePosX, 0, screenWidth), Clamp(mousePosY, 0, screenHeight), 0)
    GetGlobalEventDispatcher():SetMousePosition(mousePos)
    
    -- If an object is clicked down on, call its OnMouseDrag event.
    if self.clickObj then
        
        DBGCursorHoverLog("Calling OnMouseDrag for item '%s'...", Debug_GetBKAForItem(self.clickObj:GetRootItem()))
        
        self.clickObj:OnMouseDrag()
        
    else
        
        GUI.GetInteractionsUnderPoint(guiItemArray, mousePos.x, mousePos.y, GUIInteractionManager.Interaction_Cursor, GetModalItem(self))
        
        -- Log list of items, if logging is enabled.
        if gHoverEventLog then
            
            DBGCursorHoverLog("GUIInteractionManager:UpdateMouseCursorPosition()")
            
            for i=0, guiItemArray:GetSize() - 1 do
                
                local item = guiItemArray:Get(i)
                local bka = Debug_GetBKAForItem(item)
                
                DBGCursorHoverLog("    %s) %s", i, bka)
            
            end
        end
        
        -- Figure out if the item being hovered over is different from before.
        self.tempObject = nil
        for i=0, guiItemArray:GetSize() - 1 do
            
            local triggeringItem = guiItemArray:Get(i)
            
            local guiObject = self.cursorListeners[triggeringItem]
            if guiObject == nil then
                error("triggeringItem for OnMouseHover was not present in the cursor listeners keys!  Was GUIInteractionManager.Interaction_Cursor flag set on an item outside this GUIInteractionManager? (wags finger)")
            end
            
            -- Debug log
            local bka
            if gHoverEventLog then
                bka = Debug_GetBKAForItem(triggeringItem)
                DBGCursorHoverLog("checking item '%s'...", bka)
            end
            
            if MouseOverItemCheck(self, guiObject, mousePos) then
                
                DBGCursorHoverLog("MouseOverItemCheck passed for item '%s'.", bka)
                
                self.tempObject = guiObject
                break
            end
            
            DBGCursorHoverLog("MouseOverItemCheck failed for item '%s'.", bka)
        
        end
        
        if self.hoverObj ~= self.tempObject then
            -- Hovering item changed.
            
            -- Inform the previously hovered-over object (if any) that it is no longer being hovered over.
            if self.hoverObj ~= nil then
                -- exit the previously hovering item.
                local prevHoverObj = self.hoverObj
                self.hoverObj = nil
                
                DBGCursorLog("Calling OnMouseExit for item '%s'...", Debug_GetBKAForItem(prevHoverObj:GetRootItem()))
                
                prevHoverObj:OnMouseExit()
            end
            
            -- Inform the newly hovered-over object (if any) that it is being hovered over.
            if self.tempObject then
                self.hoverObj = self.tempObject
                
                DBGCursorLog("Calling OnMouseEnter for item '%s'...", Debug_GetBKAForItem(self.hoverObj:GetRootItem()))
                
                self.hoverObj:OnMouseEnter()
            end
        
        end
        
        self.tempObject = nil
        
        -- Inform the hovered-over object that we are still hovering over it.
        if self.hoverObj then
            
            DBGCursorHoverLog("Calling OnMouseHover for item '%s'...", Debug_GetBKAForItem(self.hoverObj:GetRootItem()))
            
            self.hoverObj:OnMouseHover()
        end
    end
end

SetupGUIManager("GUIInteractionManager")