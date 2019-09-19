-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUIUtils.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Utilities for the new GUI system.  Not menu-specific.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- Everything GUI related will load this file.  Perform a no Server and no Predict-world check here
if Server ~= nil then
    error(string.format("Attempted to load GUI code on Server!"), 2)
end

if Predict ~= nil then
    error(string.format("Attempted to load GUI code on Server!"), 2)
end

Script.Load("lua/GUI/GUIItemExtras.lua")

function GetTypeName(x)
    
    PROFILE("GUIUtils GetTypeName")
    
    if type(x) == "userdata" then
        return x.classname
    elseif type(x) == "cdata" then
        local result = GetCDataClassName(x)
        return result
    else
        local result = type(x)
        return result
    end
end

local function GetTypeListMessage(types)
    assert(type(types) == "table")
    if #types == 1 then
        return types[1]
    elseif #types == 2 then
        local result = string.format("%s or %s", types[1], types[2])
        return result
    else
        local typesCopy = {}
        table.copy(types, typesCopy)
        typesCopy[#typesCopy] = "or "..typesCopy[#typesCopy]
        local result = table.concat(typesCopy, ", ")
        return result
    end
end

local function GetIsClassName(className)
    local cls = _G[className]
    local result = GetIsClass(cls)
    return result
end

-- Takes a type name or list of type names, and ensures that the given value (known locally as
-- name) is of that type, or a derived type.  Throws an error otherwise.
function RequireType(types, value, name, errorDepth)
    
    PROFILE("GUIUtils RequireType")
    
    errorDepth = (errorDepth or 1) + 1
    
    local typeOfValue = GetTypeName(value)
    
    if type(types) == "table" then
        assert(#types > 0)
        for i=1, #types do
            if types[i] == typeOfValue then
                return
            elseif GetIsClassName(typeOfValue) then
                if classisa(typeOfValue, types[i]) then
                    return
                end
            end
        end
        error(string.format("Expected a %s for %s, got %s-type instead.", GetTypeListMessage(types), name, typeOfValue), errorDepth)
    elseif type(types) == "string" then
        if typeOfValue ~= types then
            error(string.format("Expected a %s for %s, got %s-type instead.", types, name, typeOfValue), errorDepth)
        end
    else
        error(string.format("Expected a type name or list of types, got %s-type instead", GetTypeName(types)), errorDepth)
    end
end

-- Returns true if given cls is a spark class.
function GetIsClass(cls)
    return type(cls) == "table" and getmetatable(cls) ~= nil and type(getmetatable(cls).__call) == "function"
end

function ValidateClass(cls, errorDepth)
    
    PROFILE("GUIUtils ValidateClass")
    
    errorDepth = (errorDepth or 1) + 1
    
    if not GetIsClass(cls) then
        if cls == nil then
            error("Got nil for class!  (Did you forget to load a script?)", errorDepth)
        else
            error(string.format("Expected a spark class, got %s-type instead", GetTypeName(cls)), errorDepth)
        end
    end
end

-- Takes a classname, and ensures that the given value (known locally as name) is of that type.
-- Throws an error otherwise.
function RequireIsa(classname, value, name, errorDepth)
    
    PROFILE("GUIUtils RequireIsa")
    
    errorDepth = (errorDepth or 1) + 1
    
    if not GetIsaGUIObject(value) or not value:isa(classname) then
        error(string.format("Expected a %s or derived type for %s, got %s-type instead.", classname, name, GetTypeName(value)), errorDepth)
    end
    
end

-- Takes a classname, and ensures that the given value (known locally as name) is either that same
-- class, or some derived type.
function RequireClassIsa(classname, value, name, errorDepth)
    
    PROFILE("GUIUtils RequireClassIsa")
    
    errorDepth = (errorDepth or 1) + 1
    
    if not GetIsClass(value) or not classisa(value.classname, classname) then
        error(string.format("Expected a %s class or derived class for %s, got %s instead.", classname, name, value and value.classname.."-class"), errorDepth)
    end
end

function RequireHasWrapper(wrapperName, value, name, errorDepth)
    
    PROFILE("GUIUtils RequireHasWrapper")
    
    errorDepth = (errorDepth or 1) + 1
    
    if not GetHasWrapper(value, wrapperName) then
        error(string.format("Expected a '%s' wrapped class for %s, got %s instead.", wrapperName, name, ToString(value)), errorDepth)
    end
    
end

function GetIsaGUIObject(obj)
    return type(obj) == "userdata" and obj:isa("GUIObject")
end

function GetIsaGUIItem(item)
    return type(item) == "userdata" and item:isa("GUIItem")
end

function AssertIsaGUIObject(obj, errorDepth)
    
    PROFILE("GUIUtils AssertIsaGUIObject")
    
    errorDepth = (errorDepth or 1) + 1
    if not GetIsaGUIObject(obj) then
        error(string.format("Expected a GUIObject, got %s.", GetTypeName(obj)), errorDepth)
    end
end

function AssertIsaGUIItem(item, errorDepth)
    
    PROFILE("GUIUtils AssertIsaGUIItem")
    
    errorDepth = (errorDepth or 1) + 1
    if not GetIsaGUIItem(item) then
        error(string.format("Expected a GUIItem, got %s.", GetTypeName(item)), errorDepth)
    end
end

function AssertIsNotDestroyed(guiObject, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    if guiObject:GetIsDestroyed() then
        Log("Attempted to use a GUIObject that had been destroyed!")
        Log("%s", Debug_GetStackTraceForEvent(true))
        error("GUIObject is destroyed!", errorDepth)
    end
end

local function GetIsValidName(name)
    
    PROFILE("GUIUtils GetIsValidName")
    
    if type(name) ~= "string" then
        return false
    end
    
    if #name == 0 then
        return false
    end
    
    if string.find(name, "%.") or
       string.find(name, "%:") or
       string.find(name, "/") or
       string.find(name, " ") then
        
        return false
    end
    
    return true
    
end

-- Returns true if the given name is suitable for a GUIObject.
function GetIsValidGUIObjectName(name)
    local result = GetIsValidName(name)
    return result
end

-- Same as above, but throws errors instead of returning true/false.
function ValidateGUIObjectName(name, extraDepth)
    
    PROFILE("GUIUtils ValidateGUIObjectName")
    
    if GetIsValidGUIObjectName(name) then
        return
    end
    
    error(string.format("'%s' is not a valid GUIObject name.  Name must not be empty, and cannot contain .:/ characters.", name), (extraDepth or 0) + 2)
end

-- Returns true if the given name is suitable for a property
function GetIsValidPropertyName(name)
    local result = GetIsValidName(name)
    return result
end

-- Same as above, but throws errors instead of returning true/false.
function ValidatePropertyName(name, errorDepth)

    PROFILE("GUIUtils ValidatePropertyName")

    errorDepth = (errorDepth or 1) + 1

    if GetIsValidPropertyName(name) then
        return
    end
    
    error(string.format("'%s' is not a valid property name.  Name must not be empty, and cannot contain .:/ characters.", name), errorDepth)
end

local errorDepthInitGUIObjectStack = {}
function GetErrorDepthAtInitGUIObjectCall()
    assert(#errorDepthInitGUIObjectStack > 0)
    return errorDepthInitGUIObjectStack[#errorDepthInitGUIObjectStack]
end

-- Instantiates and initializes a new GUIObject-class-based object of the given class.
-- Can provide a parent gui object to create this object as a child of.
-- Can also pass a table of parameters that the class might use to initilize the object, or that
-- the SetParent() call within uses.
function CreateGUIObject(name, cls, optionalParentGUIObjectOrItem, params, errorDepth)
    
    PROFILE("GUIUtils CreateGUIObject")
    
    errorDepth = (errorDepth or 1) + 1
    
    params = params or {}
    
    ValidateGUIObjectName(name, errorDepth)
    ValidateClass(cls, errorDepth)
    
    -- Validate the optional parent parameter
    if optionalParentGUIObjectOrItem ~= nil then
        if GetIsaGUIObject(optionalParentGUIObjectOrItem) then
            optionalParentGUIObjectOrItem = optionalParentGUIObjectOrItem:GetChildHoldingItem()
        else
            AssertIsaGUIItem(optionalParentGUIObjectOrItem, errorDepth)
        end
    end
    
    -- For debugging, print out the params table if "debugTrace" key is present.\
    if params.debugTrace then
        Log("CreateGUIObject()")
        Log("    name = %s", name)
        Log("    cls = %s", cls.classname)
        Log("    params =")
        Log("    {")
        for key, value in pairs(params) do
            if type(value) == "table" and value.classname then
                Log("        [%s] = %s", key, value.classname)
            else
                Log("        [%s] = %s", key, value)
            end
        end
        Log("    }")
        Log("%s", debug.traceback())
    end
    
    local newObj = cls()
    newObj.name = name
    errorDepthInitGUIObjectStack[#errorDepthInitGUIObjectStack +1] = errorDepth
    newObj:Initialize(params, errorDepth)
    errorDepthInitGUIObjectStack[#errorDepthInitGUIObjectStack] = nil
    
    -- Check to make sure Initialize was actually called for each derived class (by just checking to
    -- see if GUIObject's Initialize was called).  This is a common error.
    if newObj._guiObjectInitCalled then
        newObj._guiObjectInitCalled = nil
    else
        error(string.format("GUIObject.Initialize was not called by class '%s's Initialize method (or one of its derived classes).", cls.classname), errorDepth)
    end
    
    newObj:_PostInit(params, errorDepth)
    
    if optionalParentGUIObjectOrItem then
        newObj:SetParent(optionalParentGUIObjectOrItem, params)
    end
    
    return newObj
end

-- Calculates the top left and bottom right corners of the gui item, in screen-space coordinates.
function GetGUIItemScreenSpaceBounds(item)
    
    PROFILE("GUIUtils GetGUIItemScreenSpaceBounds")
    
    local screenPos = item:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight())
    local size = item:GetSize()
    local absoluteScale = item:GetAbsoluteScale()
    
    local bottomRight = screenPos + size * absoluteScale
    
    return screenPos, bottomRight
    
end

-- Ensure an abstract class isn't being instantiated.
function AbstractClassCheck(self, abstractClassName, errorDepth)
    
    PROFILE("GUIUtils AbstractClassCheck")
    
    errorDepth = (errorDepth or 1) + 1
    
    if self.classname == abstractClassName then
        error(string.format("%s is an abstract class -- it cannot be instantiated!", abstractClassName), errorDepth)
    end
end

-- Ensure a method has been provided by a descendant class.
function RequireMethod(self, methodName, errorDepth)
    
    PROFILE("GUIUtils RequireMethod")
    
    errorDepth = (errorDepth or 1) + 1
    
    if type(self[methodName]) ~= "function" then
        error(string.format("Required method '%s:%s' not provided!", self.classname, methodName), errorDepth)
    end
end

-- Ensure a method has been provided by a descendant class, or is nil (eg must be function-type or
-- nil).
function OptionalMethod(self, methodName, errorDepth)
    
    PROFILE("GUIUtils OptionalMethod")
    
    errorDepth = (errorDepth or 1) + 1
    
    local method = self[methodName]
    if method ~= nil and type(method) ~= "function" then
        error(string.format("Optional method '%s:%s' expected, got %s-type instead!", self.classname, methodName, type(method)), errorDepth)
    end
end

function GUIItemArrayToTable(guiItemArray)
    
    PROFILE("GUIItemArrayToTable")
    
    local result = {}
    for i=0, guiItemArray:GetSize() - 1 do
        table.insert(result, guiItemArray:Get(i))
    end
    return result
end

local function isnan(a)
    if type(a) == "number" then
        return a ~= a
    else
        return false
    end
end

local function FloatsEqual(a, b, tolerance)
    tolerance = tolerance or 0.001
    if isnan(a) or isnan(b) then
        return false -- nan never equals nan.
    end
    return math.abs(a-b) <= tolerance
end

function GetAreValuesTheSame(a, b)
    
    PROFILE("GUIUtils GetAreValuesTheSame")
    
    if type(a) ~= type(b) then
        return false
    end
    
    local aType = GetTypeName(a)
    if aType ~= GetTypeName(b) then
        return false
    end
    
    if aType == "Vector" then
        return FloatsEqual(a.x, b.x) and
               FloatsEqual(a.y, b.y) and
               FloatsEqual(a.z, b.z)
        
    elseif aType == "Color" then
        return FloatsEqual(a.r, b.r) and
               FloatsEqual(a.g, b.g) and
               FloatsEqual(a.b, b.b) and
               FloatsEqual(a.a, b.a)
        
    elseif type(a) == "table" then
        -- cannot compare tables efficiently, and sometimes tables are changed in-place, so just
        -- assume they've always changed.
        return false
        
    elseif type(a) == "number" then
        return (FloatsEqual(a, b))
        
    else
        return a == b
        
    end
    
end

-- Sets up the correct flags for text rendering for this item.
function SetupGUIItemForText(item)
    item:SetOptionFlag(GUIItem.ManageRender)
    item:SetOptionFlag(GUIItem.PerLineTextAlignment)
    item:SetColor(Color(1, 1, 1, 1))
end

-- Modifies the (we assume newly-created) GUIItem so that it won't ever be rendered, but merely
-- used in the structure of the gui heirarchy.
function SetupGUIItemForLocator(item)
    item:ClearOptionFlag(GUIItem.ManageRender)
    item:ClearOptionFlag(GUIItem.PerLineTextAlignment)
    item:SetColor(Color(0, 0, 0, 0))
end

function StringFromUTF8(utf8, optionalEndIndex)
    if #utf8 == 0 then
        return ""
    else
        if type(optionalEndIndex) == "number" then
            local result = table.concat(utf8, "", 1, optionalEndIndex)
            return result
        else
            local result = table.concat(utf8, "")
            return result
        end
    end
end

UTF8FromString = string.UTF8Encode
assert(UTF8FromString)

local function OnTextChanged(self)
    
    local oldSize = self:GetSize()
    self:ForceUpdateTextSize()
    local newSize = self:GetSize()
    
    if oldSize.x ~= newSize.x or oldSize.y ~= newSize.y then
        self:FireEvent("OnSizeChanged", newSize, oldSize)
    end
    
end

-- When a GUIItem's font or text is changed, the actual size reported with GetSize is not updated
-- immediately.  It is only updated automatically by the engine when the text is rendered.  This
-- utility sets up two event hooks to ensure that this object's root item will always update size
-- immediately when font or text is changed.  This should be called before all other callbacks are
-- setup, to ensure the results are not delayed by 1 update.
function SetupAutomaticTextSizeUpdating(obj, textPropertyName)
    textPropertyName = textPropertyName or "Text"
    obj:HookEvent(obj, "On"..textPropertyName.."Changed", OnTextChanged)
    obj:HookEvent(obj, "OnFontNameChanged", OnTextChanged)
end

local function UpdateAbsoluteScale(obj)
    
    local prevAbsoluteScale = obj.__prevAbsoluteScale
    obj.__prevAbsoluteScale = obj:GetAbsoluteScale()
    if prevAbsoluteScale ~= obj.__prevAbsoluteScale and prevAbsoluteScale ~= nil then
        obj:FireEvent("OnAbsoluteScaleChanged", obj.__prevAbsoluteScale, prevAbsoluteScale)
    end
    
end

local function RebuildAbsoluteScaleCallback(obj, newParentObj, oldParentObj)
    
    DisableOnAbsoluteScaleChangedEvent(obj)
    EnableOnAbsoluteScaleChangedEvent(obj)
    
    -- Absolute scale might have changed.
    UpdateAbsoluteScale(obj)
    
end

local function OnAbsoluteScaleChangedCallback(obj)
    
    -- Don't assume anything actually changed.  A zero, for example, could mean a parent's scale
    -- changed, but a child's scale remained the same (0).
    UpdateAbsoluteScale(obj)
    
end

-- Sometimes we need to change based on the absolute scale of the object, not just the local scale.
-- To do this, we (unfortunately) need to hook the OnScaleChanged events for the sender, the
-- sender's parent, grandparent, and so on until we reach a root-level object.  We also need to
-- maintain this through any parent changes that take place along this path.
-- This should only be done when absolutely necessary.
function EnableOnAbsoluteScaleChangedEvent(obj)
    
    AssertIsaGUIObject(obj)
    
    local currentObj = obj
    while currentObj ~= nil do
        
        obj:HookEvent(currentObj, "OnParentChanged", RebuildAbsoluteScaleCallback)
        obj:HookEvent(currentObj, "OnScaleChanged", OnAbsoluteScaleChangedCallback)
        
        currentObj = currentObj:GetParent(true)
        
    end
    
    -- Fire once to set the initial value of absolute scale (so that the event can provide the
    -- previous value whenever it _does_ change).
    UpdateAbsoluteScale(obj)
    
end

-- Undoes all the hooking that was setup to get an OnAbsoluteScaleChanged callback for this object.
function DisableOnAbsoluteScaleChangedEvent(obj)
    
    AssertIsaGUIObject(obj)
    
    obj:UnHookEvent(nil, "OnParentChanged", RebuildAbsoluteScaleCallback)
    obj:UnHookEvent(nil, "OnScaleChanged", OnAbsoluteScaleChangedCallback)
    
end

local function UpdateScreenPosition(obj)
    
    -- Don't assume anything actually changed.  A zero, for example, could mean a parent's scale
    -- changed, but a child's scale remained the same (0).
    local prevScreenPos = obj.__prevScreenPos
    obj.__prevScreenPos = obj:GetScreenPosition()
    if prevScreenPos ~= obj.__prevScreenPos and prevScreenPos ~= nil then
        obj:FireEvent("OnScreenPositionChanged", obj.__prevScreenPos, prevScreenPos)
    end
    
end

local function RebuildScreenPositionCallback(obj, newParentObj, oldParentObj)
    
    DisableOnScreenPositionChangedEvent(obj)
    EnableOnScreenPositionChangedEvent(obj)
    
    -- Screen position might have changed.
    UpdateScreenPosition(obj)

end

local function OnScreenPositionChangedCallback(obj)
    UpdateScreenPosition(obj)
end

-- Sometimes we need to change based on the screen-space coordinates of an object, not just the
-- local space position.  To do this, we (unfortunately) need to hook the following events for the
-- sender, and all the sender's ancestors:
--      OnPositionChanged
--      OnHotSpotChanged
--      OnAnchorChanged
--      OnScaleChanged
--      OnSizeChanged
-- We also need to maintain these hooks through any parent changes that take place along this path.
-- Needless to say this is a bit expensive, and should really only be done when absolutely
-- necessary.
function EnableOnScreenPositionChangedEvent(obj)
    
    AssertIsaGUIObject(obj)
    
    local currentObj = obj
    while currentObj ~= nil do
        
        obj:HookEvent(currentObj, "OnParentChanged",   RebuildScreenPositionCallback)
        obj:HookEvent(currentObj, "OnPositionChanged", OnScreenPositionChangedCallback)
        obj:HookEvent(currentObj, "OnHotSpotChanged",  OnScreenPositionChangedCallback)
        obj:HookEvent(currentObj, "OnAnchorChanged",   OnScreenPositionChangedCallback)
        obj:HookEvent(currentObj, "OnScaleChanged",    OnScreenPositionChangedCallback)
        obj:HookEvent(currentObj, "OnSizeChanged",     OnScreenPositionChangedCallback)
        
        currentObj = currentObj:GetParent(true)
        
    end
    
    -- Fire once to set the initial value of screen position (so that the event can provide the
    -- previous value whenever it _does_ change).
    UpdateScreenPosition(obj)
    
end

-- Undoes all the hooking that was setup to get an OnScreenPositionChanged callback for this object.
function DisableOnScreenPositionChangedEvent(obj)
    
    AssertIsaGUIObject(obj)
    
    obj:UnHookEvent(nil, "OnParentChanged",   RebuildScreenPositionCallback)
    obj:UnHookEvent(nil, "OnPositionChanged", OnScreenPositionChangedCallback)
    obj:UnHookEvent(nil, "OnHotSpotChanged",  OnScreenPositionChangedCallback)
    obj:UnHookEvent(nil, "OnAnchorChanged",   OnScreenPositionChangedCallback)
    obj:UnHookEvent(nil, "OnScaleChanged",    OnScreenPositionChangedCallback)
    obj:UnHookEvent(nil, "OnSizeChanged",     OnScreenPositionChangedCallback)
    
end

local currentPath = {}
local lastObjPath = {}
local function GetIdentificationForErrorMessage()
    if #currentPath > 0 then
        local result = string.format("object %s", table.concat(currentPath, "."))
        return result
    elseif #lastObjPath > 0 then
        local result = string.format("unnamed object (declaration begins after object '%s')", table.concat(lastObjPath, "."))
        return result
    else
        return "unnamed object (first object)"
    end
end

local function DoConfigErrorMessage(errorDepth, message)
    errorDepth = errorDepth + 1
    error(string.format("%s (error at %s)", message, GetIdentificationForErrorMessage()), errorDepth)
end

local function CreateAndConfigureObject(errorDepth, config, optionalParentGUIObjectOrItem)
    errorDepth = errorDepth + 1
    
    local newObj = CreateGUIObject(config.name, config.class, optionalParentGUIObjectOrItem, config.params, errorDepth)
    assert(newObj)
    
    -- Add object field to the parent.
    if optionalParentGUIObjectOrItem then
        if GetIsaGUIObject(optionalParentGUIObjectOrItem) then
            optionalParentGUIObjectOrItem[config.name] = newObj
        end
    end
    
    -- Set the object's properties.
    if config.properties then
        for i=1, #config.properties do
            local propertyDef = config.properties[i]
            local propertyName = propertyDef[1]
            local propertyValue = propertyDef[2]
            
            assert(propertyName)
            assert(propertyValue ~= nil)
            
            if not newObj:GetPropertyExists(propertyName) then
                error(string.format("Property '%s' does not exist!", propertyName), 2)
            end
            newObj:Set(propertyName, propertyValue)
        end
    end
    
    -- Fire the post-init function(s), passing this new object as the first parameter.
    if type(config.postInit) == "table" then
        for i=1, #config.postInit do
            local postInitFunc = config.postInit[i]
            postInitFunc(newObj)
        end
    elseif type(config.postInit) == "function" then
        config.postInit(newObj)
    end
    
    return newObj
    
end

local function CreateGUIObjectFromConfigActual(errorDepth, config, optionalParentGUIObjectOrItem)
    errorDepth = (errorDepth or 1) + 1
    
    -- Basic validation of parameters (this depth only, parameters are checked recursively).
    if type(config) ~= "table" then
        DoConfigErrorMessage(errorDepth, string.format("Expected a config table, got %s-type instead.", GetTypeName(config)))
    end
    
    if type(config.name) ~= "string" then
        DoConfigErrorMessage(errorDepth, string.format("Expected an object name for config.name, got %s-type instead.", GetTypeName(config.name)))
    end
    
    currentPath[#currentPath+1] = config.name
    table.copy(currentPath, lastObjPath)
    
    if not GetIsClass(config.class) then
        DoConfigErrorMessage(errorDepth, string.format("Expected a class for config.class, got %s-type instead.", GetTypeName(config.class)))
    end
    
    if config.properties and type(config.properties) ~= "table" then
        DoConfigErrorMessage(errorDepth, string.format("Expected a table or nil for config.properties, got %s-type instead.", GetTypeName(config.properties)))
    end
    
    if config.properties then
        for i=1, #config.properties do
            local propertyDef = config.properties[i]
            if type(propertyDef) ~= "table" then
                DoConfigErrorMessage(errorDepth, string.format("Expected a table for config.properties[%d], got %s-type instead.", i, GetTypeName(propertyDef)))
            end
            
            if type(propertyDef[1]) ~= "string" then
                DoConfigErrorMessage(errorDepth, string.format("Expected a string for property name in config.properties[%d][1], got %s-type instead.", i, GetTypeName(propertyDef[1])))
            end
            
            if propertyDef[2] == nil then
                DoConfigErrorMessage(errorDepth, string.format("Expected a value for property value in config.properties[%d][2], got nil instead.", i))
            end
        end
    end
    
    if config.postInit and type(config.postInit) ~= "table" and type(config.postInit) ~= "function" then
        DoConfigErrorMessage(errorDepth, string.format("Expected a table, function, or nil for config.postInit, got %s-type instead.", GetTypeName(config.postInit)))
    end
    
    if type(config.postInit) == "table" then
        for i=1, #config.postInit do
            local postInitDef = config.postInit[i]
            if type(postInitDef) ~= "function" then
                DoConfigErrorMessage(errorDepth, string.format("Expected a function for config.postInit[%d], got %s-type instead.", i, GetTypeName(postInitDef)))
            end
        end
    end
    
    if config.children and type(config.children) ~= "table" then
        DoConfigErrorMessage(errorDepth, string.format("Expected a table or nil for config.children, got %s-type instead.", GetTypeName(config.children)))
    end
    
    -- Detect common mistake of declaring a single child in the table that is supposed to be holding an array of children.
    if config.children and config.children.name then
        DoConfigErrorMessage(errorDepth, "Detected improperly nested child objects (children are defined as _an array_ of tables, not just the tables by themselves).")
    end
    
    if config.params and type(config.params) ~= "table" then
        DoConfigErrorMessage(errorDepth, string.format("Expected a table or nil for config.params, got %s-type instead.", GetTypeName(config.params)))
    end
    
    if optionalParentGUIObjectOrItem ~= nil and not GetIsaGUIObject(optionalParentGUIObjectOrItem) and not GetIsaGUIItem(optionalParentGUIObjectOrItem) then
        error(string.format("Expected nil, a GUIItem, or a GUIObject for optionalParentGUIObjectOrItem, got %s-type instead.", GetTypeName(optionalParentGUIObjectOrItem)), errorDepth)
    end
    
    -- Create this object, and configure it, but don't create children just yet.  Wrap it in a
    -- pcall so we can provide better information about where things went wrong (otherwise all we
    -- get is just "this table did bad!")
    -- Re-comment the following block, and un-comment the one after to see the full stack trace
    -- (but without the object name stack information included :( ).
    --[=[
    local result, result2 = pcall(CreateAndConfigureObject, errorDepth, config, optionalParentGUIObjectOrItem)
    local newObj
    if result then
        newObj = result2
    else
        DoConfigErrorMessage(errorDepth, result2)
    end
    --]=]
    ---[=[
    local newObj = CreateAndConfigureObject(errorDepth, config, optionalParentGUIObjectOrItem)
    --]=]
    
    -- Recursively create child objects.
    if config.children then
        for i=1, #config.children do
            local childConfig = config.children[i]
            CreateGUIObjectFromConfigActual(errorDepth, childConfig, newObj)
        end
    end
    
    currentPath[#currentPath] = nil
    
    assert(newObj)
    return newObj
    
end

function CreateGUIObjectFromConfig(config, optionalParentGUIObjectOrItem)
    
    PROFILE("GUIUtils CreateGUIObjectFromConfig")
    
    local result = CreateGUIObjectFromConfigActual(2, config, optionalParentGUIObjectOrItem)
    
    -- Clear the debug tracing stuff, so it doesn't spill over to the next time we load a config.
    currentPath = {}
    lastObjPath = {}
    
    return result
    
end

function EnsureClassPropertyExists(cls, propertyName, defaultValue, noCopy)
    if not cls:GetPropertyExists(propertyName, false) then
        cls:AddClassProperty(propertyName, defaultValue, noCopy)
    end
end

function GetBaseClass(cls)
    
    if cls == nil then
        return nil
    end
    local baseClassName = Script.GetBaseClass(cls.classname)
    local baseClass = baseClassName and _G[baseClassName]
    
    return baseClass
    
end

local paramChangeStack = {}

-- Add/Change a value of a table and keep a record of it so it can be popped off in the same order.
-- This allows us to set options for particular descendants without having to make expensive copies
-- or manually set/reset table fields.  Every call to PushParamChange MUST have a matching call to
-- PopParamChange.
---@generic T
---@param params table
---@param name string
---@param newValue
function PushParamChange(params, name, newValue)
    
    RequireType("table", params, "params", 2)
    RequireType("string", name, "name", 2)
    
    local prevParamValue = params[name]
    params[name] = newValue
    table.insert(paramChangeStack, {name, prevParamValue})
    
end

-- MUST accompany every call to PushParamChange.
---@param params table
---@param name string
function PopParamChange(params, name)
    
    RequireType("table", params, "params", 2)
    RequireType("string", name, "name", 2)
    
    local peekStack = paramChangeStack[#paramChangeStack]
    local peekName = peekStack[1]
    local peekValue = peekStack[2]
    
    if #paramChangeStack == 0 then
        paramChangeStack = {} -- clear stack before error so it doesn't get repeated.
        error("Parameter change stack is empty!  Ensure your PopParamChange() calls mirror your PushParamChange() calls!", 2)
    end
    
    if peekName ~= name then
        paramChangeStack = {} -- clear stack before error so it doesn't get repeated.
        error(string.format("PopParamChange called with name '%s' that doesn't match what is present on the stack! (%s)", name, peekName), 2)
    end
    
    params[name] = peekValue
    table.remove(paramChangeStack, #paramChangeStack)
    
end

-- Combines the key-value pairs of two tables.  If there are collisions, a's table takes precedence.
function CombineParams(a, b)
    assert(type(a) == "table")
    assert(type(b) == "table")
    local result = {}
    for key, value in pairs(b) do
        result[key] = value
    end
    for key, value in pairs(a) do
        result[key] = value
    end
    return result
end

-- HSV == HSB (what photoshop uses) (but NOT HSL...)
function HSVToRGB(hue, sat, val)
    
    local red   = Clamp( 6 * hue - 4, 0, 1) + Clamp(-6 * hue + 2, 0, 1)
    local green = Clamp( 6 * hue    , 0, 1) + Clamp(-6 * hue + 4, 0, 1) - 1
    local blue  = Clamp( 6 * hue - 2, 0, 1) + Clamp(-6 * hue + 6, 0, 1) - 1
    local c = Color(red, green, blue, 1)
    
    -- Apply saturation
    c = c * sat + Color(1, 1, 1, 1) * (1-sat)
    
    -- Apply brightness
    c = c * val
    
    c.a = 1
    
    return c
    
end

function RGBToHSV(color)
    
    local c = Color(color) -- copy
    
    local val = math.max(c.r, c.g, c.b)
    if val == 0 then
        return 0, 0, 0
    end
    
    c.r = c.r / val
    c.g = c.g / val
    c.b = c.b / val
    
    local minVal = math.min(c.r, c.g, c.b)
    local sat = 1 - minVal
    
    c.r = (c.r - minVal) / (1 - minVal)
    c.g = (c.g - minVal) / (1 - minVal)
    c.b = (c.b - minVal) / (1 - minVal)
    
    local hue
    if c.r == 1 then
        if c.b == 0 then
            hue = (c.g) / 6
        else
            hue = ((1 - c.b) + 5) / 6
        end
    elseif c.g == 1 then
        if c.b == 0 then
            hue = ((1 - c.r) + 1) / 6
        else
            hue = (c.b + 2) / 6
        end
    else
        if c.r == 0 then
            hue = ((1 - c.g) + 3) / 6
        else
            hue = (c.r + 4) / 6
        end
    end
    
    return hue, sat, val

end

local function ItemFromObjOrItem(objOrItem)
    local item
    if objOrItem:isa("GUIObject") then
        item = objOrItem:GetRootItem()
    else
        item = objOrItem
    end
    return item
end

local function TraverseToRoot(objOrItem, functor)
    
    local item = ItemFromObjOrItem(objOrItem)
    local idx = 1
    while item do
        functor(item, idx)
        item = item:GetParent()
        idx = idx + 1
    end

end

-- Returns the non-animated property value of the given item.  An item property can only be animated
-- if it is the root item of a GUIObject, otherwise it is already static.
local function GetStaticItemPropertyValue(item, propertyName)
    local owner = GetOwningGUIObject(item)
    if not owner or owner:GetRootItem() ~= item then
        local itemPropertyGetter = g_GUIItemPropertyGetters[propertyName]
        assert(itemPropertyGetter)
        return (itemPropertyGetter(item))
    end
    return (owner:Get(propertyName, true))
end

-- Returns the current property value of the item (returned value is animated by default, so no
-- extra work is required).
local function GetNonStaticItemPropertyValue(item, propertyName)
    local itemPropertyGetter = g_GUIItemPropertyGetters[propertyName]
    assert(itemPropertyGetter)
    return (itemPropertyGetter(item))
end

local function SetItemPropertyValue(item, propertyName, value)
    local itemPropertySetter = g_GUIItemPropertySetters[propertyName]
    assert(itemPropertySetter)
    itemPropertySetter(item, value)
end

local _restorationTable
local _propertyList
local function RemoveNonStaticValuesFunctor(item, idx)
    for i=1, #_propertyList do
        local propertyName = _propertyList[i]
        local staticValue = GetStaticItemPropertyValue(item, propertyName)
        local currentValue = GetNonStaticItemPropertyValue(item, propertyName)
        _restorationTable[i] = _restorationTable[i] or {}
        table.insert(_restorationTable[i], currentValue)
        SetItemPropertyValue(item, propertyName, staticValue)
    end
end

local function RestoreNonStaticValuesFunctor(item, idx)
    for i=1, #_propertyList do
        local propertyName = _propertyList[i]
        local prevValue = _restorationTable[i][idx]
        SetItemPropertyValue(item, propertyName, prevValue)
    end
end

local function RemoveNonStaticValues(objOrItem, propertyList, restorationTable)
    _restorationTable = restorationTable
    _propertyList = propertyList
    TraverseToRoot(objOrItem, RemoveNonStaticValuesFunctor)
end

local function RestoreNonStaticValues(objOrItem, propertyList, restorationTable)
    _restorationTable = restorationTable
    _propertyList = propertyList
    TraverseToRoot(objOrItem, RestoreNonStaticValuesFunctor)
end

-- Returns the absolute scale of the object or item as though all animations were removed/finished.
-- Very expensive.
local kGetStaticAbsoluteScaleRelevantProperties = {"Scale"}
function GetStaticAbsoluteScale(objOrItem)

    PROFILE("GetStaticAbsoluteScale")
    
    RequireType({"GUIItem", "GUIObject"}, objOrItem, "objOrItem", 2)
    
    local restorationTable = {}
    local relevantProperties = kGetStaticAbsoluteScaleRelevantProperties
    RemoveNonStaticValues(objOrItem, relevantProperties, restorationTable)
    
    local result = objOrItem:GetAbsoluteScale()
    
    RestoreNonStaticValues(objOrItem, relevantProperties, restorationTable)

    return result
    
end

-- Returns the screen position of the object or item as though all animations were removed/finished.
-- Very expensive.
local kGetStaticScreenPositionRelevantProperties = {"Anchor", "HotSpot", "Position", "Scale", "Size"}
function GetStaticScreenPosition(objOrItem)
    
    PROFILE("GetStaticScreenPosition")
    
    RequireType({"GUIItem", "GUIObject"}, objOrItem, "objOrItem", 2)
    
    local restorationTable = {}
    local relevantProperties = kGetStaticScreenPositionRelevantProperties
    RemoveNonStaticValues(objOrItem, relevantProperties, restorationTable)
    
    local result = objOrItem:GetScreenPosition()
    
    RestoreNonStaticValues(objOrItem, relevantProperties, restorationTable)
    
    return result

end

function GetStaticAbsoluteSize(objOrItem)
    
    PROFILE("GetStaticAbsoluteSize")
    
    RequireType({"GUIItem", "GUIObject"}, objOrItem, "objOrItem", 2)
    
    local staticAbsoluteScale = GetStaticAbsoluteScale(objOrItem)
    local size
    local item = ItemFromObjOrItem(objOrItem)
    local owner = GetOwningGUIObject(item)
    if owner and owner:GetRootItem() == item then
        size = owner:GetSize(true)
    else
        size = item:GetSize()
    end
    
    return size * staticAbsoluteScale
    
end
