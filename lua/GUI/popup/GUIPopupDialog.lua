-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/popup/GUIPopupDialog.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Base class for a modal popup dialog box.  Doesn't work on its own, but contains the pieces
--    needed for a derived class to apply proper themeing.
--
--  Parameters (* = required)
--     *buttonConfig    List of GUIObject creation config tables describing the buttons of the
--                      popup.
--      escDisabled     If not true, the user can press esc to close the popup, which will have the
--                      same effect as the default cancel button.
--      title           
--      updateFunc      Function to call to update the popup window.  Called every frame that it is
--                      open.
--  
--  Properties:
--      Title           The text displayed for the title of this dialog box.
--      NOTE: Contents config presets will often add additional properties.
--  
--  Events:
--      OnCancelled     The dialog was close via ESC or the cancel button.
--      OnClosed        The dialog was closed.  Fired _after_ button callbacks -- if any.
--      OnEscape        The dialog was closed via ESC.  Fires immediately before OnClosed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")

---@class GUIPopupDialog : GUIObject
class "GUIPopupDialog" (GUIObject)

GUIPopupDialog.kDarkenColor = Color(0, 0, 0, 0.5)

GUIPopupDialog:AddCompositeClassProperty("Title", "titleText", "Text")

local function DefaultCancelCallback(popup)
    popup:FireEvent("OnCancelled")
    popup:Close()
end

local function DefaultOkayCallback(popup)
    popup:Close()
end

-- Default implementation of a Cancel button.
GUIPopupDialog.CancelButton =
{
    name = "cancel",
    params =
    {
        label = string.upper(Locale.ResolveString("CANCEL")),
    },
    callback = DefaultCancelCallback,
}

-- Default implementation of an Okay button.  Does nothing except close the window.
GUIPopupDialog.OkayButton =
{
    name = "ok",
    params =
    {
        label = string.upper(Locale.ResolveString("OK")),
    },
    callback = DefaultOkayCallback,
}

local function OnResolutionChanged(self, x, y)
    
    self.screenDarkener:SetSize(x, y)
    
    -- mockupRes = 3840 x 2160
    local scale = math.min(x / 3840, y / 2160)
    self:SetScale(scale, scale)
    
end

function GUIPopupDialog:GetDefaultButtonClass()
    error("GUIPopupDialog has no default button class!  You should really consider using GUIMenuPopupDialog instead.")
end

function GUIPopupDialog:CreateButton(config)
    
    -- If a button class wasn't specified, let the popup chooose.
    local prevButtonClass = config.class
    config.class = config.class or self:GetDefaultButtonClass()
    
    local newButton = CreateGUIObjectFromConfig(config, self.buttonHolder)
    self:HookEvent(newButton, "OnPressed", config.callback)
    self.buttons[newButton:GetName()] = newButton
    
    -- Revert config.class to the value it was before we changed it.  Remember, these tables being
    -- passed to us aren't temporary -- if we make changes to them, they'll stick and get used
    -- anywhere else this table is used, so make sure we clean up after ourselves!
    config.class = prevButtonClass
    
    return newButton
    
end

function GUIPopupDialog:GetButton(name)
    
    return self.buttons[name]
    
end

-- Override for different layouts.
function GUIPopupDialog:CreateButtonHolder()
    local result = CreateGUIObject("buttonHolder", GUIListLayout, self, {orientation = "horizontal"})
    return result
end

function GUIPopupDialog:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    -- Ensure that it's a derived class being instantiated.
    AbstractClassCheck(self, "GUIPopupDialog", errorDepth)
    
    -- Ensure escDisabled is a boolean.
    RequireType({"boolean", "nil"}, params.escDisabled, "params.escDisabled", errorDepth)
    
    -- Ensure title is text.
    RequireType({"string", "nil"}, params.title, "params.title", errorDepth)
    
    -- Ensure update function, if specified, is a function.
    RequireType({"function", "nil"}, params.updateFunc, "params.updateFunc", errorDepth)
    
    -- Ensure buttons have been specified, and that each button class is a GUIButton derived type,
    -- and that callback functions have been specified.
    local usedButtonNames = {} -- ensure no duplicate button names.
    RequireType({"table"}, params.buttonConfig, "params.buttonConfig", errorDepth)
    if #params.buttonConfig == 0 then
        error("Expected an array of button configurations for params.buttonConfig, but got a 0-length table (did you accidentally create a dictionary?)", errorDepth)
    end
    for i=1, #params.buttonConfig do
        
        RequireType({"GUIButton", "nil"}, params.buttonConfig[i].class, string.format("params.buttonConfig[%d].class", i), errorDepth)
        RequireType({"function"}, params.buttonConfig[i].callback, string.format("params.buttonConfig[%d].callback", i), errorDepth)
        RequireType({"string"}, params.buttonConfig[i].name, string.format("params.buttonConfig[%d].name", i), errorDepth)
        
        local buttonName = params.buttonConfig[i].name
        
        -- Ensure button name isn't already taken.
        if usedButtonNames[buttonName] then
            error(string.format("There is already a button named '%s'!", buttonName), errorDepth)
        end
        usedButtonNames[buttonName] = true
        
    end
    
    GUIObject.Initialize(self, params, errorDepth)
    
    -- Create the contents.
    self.contentsHolder = CreateGUIObject("contentsHolder", GUIObject, self)
    self.contentsHolder:AlignTop()
    
    -- Create the title text.
    self.titleHolder = self:CreateLocatorGUIItem()
    self.titleHolder:AlignTop()
    self.titleText = CreateGUIObject("titleText", GUIText, self.titleHolder)
    self.titleText:AlignCenter()
    self:SetTitle(params.title or "TITLE")
    
    -- Popup should appear above everything else.
    self:SetLayer(GetLayerConstant("Popup", 1000))
    
    -- Ensure nothing else can be interacted with until this popup is dealt with.
    self:SetModal()
    
    -- Create buttons.
    self.buttons = {} -- mapping of button name --> button.
    self.buttonHolder = self:CreateButtonHolder()
    for i=1, #params.buttonConfig do
        local newButton = self:CreateButton(params.buttonConfig[i])
        self.buttons[newButton:GetName()] = newButton
        self.buttons[#self.buttons+1] = newButton
    end
    
    -- Setup the update function, if provided.
    if params.updateFunc then
        self.OnUpdate =
            function(self, deltaTime, now)
                params.updateFunc(self, deltaTime, now)
            end
        GetGUIUpdateManager():AddObjectToUpdateSet(self)
    end
    
    -- Darken the screen behind the popup.
    self.screenDarkener = self:CreateGUIItem()
    self.screenDarkener:SetLayer(-100)
    self.screenDarkener:SetColor(self.kDarkenColor)
    
    -- Screen darkener should stretch to fill the whole screen.  To make this easier, its transform
    -- should be setup in screen space, not parent-local space.
    self.screenDarkener:SetInheritsParentScaling(false)
    self.screenDarkener:SetInheritsParentPosition(false)
    
    -- Need to adjust the size of the darkener and main object, as well as adjust scaling of popup
    -- part of object.
    self:HookEvent(GetGlobalEventDispatcher(), "OnResolutionChanged", OnResolutionChanged)
    OnResolutionChanged(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
    -- Allow the esc key to be disabled (nil equates to false).
    if params.escDisabled ~= true then
        self:ListenForKeyInteractions()
    end
    
    -- Ensure the mouse cursor is visible for the popup (could potentially popup while the player is
    -- not in the menu).
    MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", Client.GetIsConnected())
    self.cursorInStack = true -- keep track of whether or not we've removed the cursor yet.
    
    -- Ensure we've stopped editing any other widgets so we can focus on this one.
    EndAllGUIEditing()
    
end

function GUIPopupDialog:Uninitialize()
    
    -- Hide the mouse cursor if we haven't already (or at least stop reserving mouse cursor
    -- visibility for this object).
    if self.cursorInStack then
        self.cursorInStack = nil
        MouseTracker_SetIsVisible(false)
    end
    
    GUIObject.Uninitialize(self)
    
end

function GUIPopupDialog:OnKey(key, down)
    
    if key == InputKey.Escape and down then
        self:FireEvent("OnEscape")
        self:FireEvent("OnCancelled")
        self:Close()
    end
    
end

-- Close the popup.  This method should never be overridden.  Instead, override PerformClose() to
-- change _how_ the popup closes.
function GUIPopupDialog:Close()
    
    -- Hide the mouse cursor if we haven't already (or at least stop reserving mouse cursor
    -- visibility for this object).
    if self.cursorInStack then
        self.cursorInStack = nil
        MouseTracker_SetIsVisible(false)
    end
    
    -- Prevent any further interaction with popup.
    self:BlockChildInteractions()
    
    -- Popup no longer blocks other interactions.
    self:ClearModal()
    
    self:FireEvent("OnClosed")
    
    self:PerformClose()
    
end

-- Do whatever the derived class wants to do when a dialog closes.
function GUIPopupDialog:PerformClose()
    
    self:Destroy()
    
end

function GUIPopupDialog:GetContents()
    return self.contents
end
