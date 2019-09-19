-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/layouts/GUILayout.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    An abstract base class for objects that will contain and arrange objects in a certain way.
--@class GUILayout : GUIObject
--  
--  Parameters (* = required)
--      autoArrange
--      backPadding
--      deferredArrange     If true, this layout will _not_ rearrange itself until the end of
--                          the frame.  Saves a lot of performance if it has a lot of objects to
--                          arrange and is updated frequently.  However, any side effects of
--                          _Arrange() will not be seen until the end of the frame.
--      frontPadding
--  
--  Properties
--      AutoArrange         Whether or not the layout will update the arrangement on its own.
--                          If false, the programmer must either call ArrangeNow() or set auto
--                          arrange back to true, otherwise the layout will never update!
--      BackPadding         How much extra space to add to the back of the layout (right padding
--                          in horizontal layout, bottom padding in vertical layout).
--      FrontPadding        How much extra space to add to the front of the layout (left padding
--                          in horizontal layout, top padding in vertical layout).
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")

---@class GUILayout : GUIObject
class "GUILayout" (GUIObject)

GUILayout:AddClassProperty("FrontPadding", 0) -- top/left padding
GUILayout:AddClassProperty("BackPadding", 0) -- bottom/right padding

-- Call Arrange() immediately after any changes that would require it, such as:
    -- Child size changes.
    -- Child "expansion" changes (where applicable).
    -- Children added/removed.
-- Can be expensive if many objects are changing at once.  Consider disabling AutoArrange, making
-- changes, then re-enabling auto arrange, for more efficiency.
GUILayout:AddClassProperty("AutoArrange", true)

-- Returns the list of children, in the order they should be arranged.  Called by Arrange().
-- Returns nil if there is no root item any more (eg object getting destroyed).
local guiItemArray = GUIItemArray()
local function GetChildrenForArrangement(self)
    
    PROFILE("GUILayout:GetChildrenForArrangement()")
    
    local rootItem = self:GetRootItem()
    if rootItem then -- can be nil if object is being destroyed.
        rootItem:GetChildren(guiItemArray)
        local result = GUIItemArrayToTable(guiItemArray)
        return result
    end
    
    return nil
    
end

local function DoDeferredArrange(self)
    
    self._doingDeferredArrange = true
    self:SetNeedsArrange(true)
    self._doingDeferredArrange = nil
    
end

local function ArrangeInternal(self)
    self.needsArrange = false
    
    -- Some layouts are specifically setup to perform their arrangements after all other events
    -- have fired, for performance reasons.  If this layout is set to do this -- and this isn't
    -- during the deferred callback, enqueue it.
    if self.deferredArrange and not self._doingDeferredArrange then
        self:EnqueueDeferredUniqueCallback(DoDeferredArrange)
        return
    end
    
    -- Disable events for owning objects while we arrange them.
    local items = GetChildrenForArrangement(self)
    if not items then
        return
    end
    
    local owners = {}
    for i=1, #items do
        local owner = GetOwningGUIObject(items[i])
        if owner and owner ~= self then -- skip GUIItems owned by this layout.
            table.insert(owners, owner)
            owner:PauseEvents()
        end
    end
    
    self:_Arrange(items)
    
    -- Re-enable events for owning objects.
    for i=1, #owners do
        owners[i]:ResumeEvents()
    end
    
end

local function SetNeedsArrangeInternal(self, state)
    
    state = state or true
    self.needsArrange = state
    
    if self.needsArrange and self:GetAutoArrange() then
        ArrangeInternal(self)
    end
end

local function OnAutoArrangeChanged(self)
    
    if self.needsArrange and self:GetAutoArrange() then
        ArrangeInternal(self)
    end
    
end

local function GetPropertiesList(self, getterName, cacheName)
    
    -- Only need to build this list once -- the returned values of these functions should be
    -- static.
    local propertiesList = _G[self.classname][cacheName]
    
    -- If we don't have a properties list, or if the one we have is merely the copy created by
    -- class inheritance, then we need to create a new one.
    if not propertiesList or propertiesList.classname ~= self.classname then
        
        -- Store the class name in the table, so we know if it's the result of this function
        -- versus the result of the class being derived from a class with this list already built.
        propertiesList = {classname = self.classname}
        
        -- Traverse up the hierarchy until we find GUILayout, calling the getter function as we go
        -- if it differs from its base class (again, due to the static method being copied by class
        -- inheritance).
        
        local cls = _G[self.classname]
        assert(cls)
        assert(cls ~= GUILayout)
        
        local baseClass = GetBaseClass(cls)
        assert(baseClass)
        
        while cls ~= GUILayout do
            
            if cls[getterName] ~= baseClass[getterName] then
                cls[getterName](propertiesList)
            end
            
            cls = baseClass
            
            baseClass = GetBaseClass(cls)
            
        end
        
        GUILayout[getterName](propertiesList)
        
        _G[self.classname][cacheName] = propertiesList
        
    end
    
    return propertiesList
    
end

local function GetRelevantPropertyNamesHelper(self)
    local result = GetPropertiesList(self, "GetRelevantPropertyNames", "_relevantLayoutProperties")
    return result
end

local function GetRelevantChildPropertyNamesHelper(self)
    local result = GetPropertiesList(self, "GetRelevantChildPropertyNames", "_relevantChildProperties")
    return result
end

local function OnChildAdded(self, childItem)
    
    childItem:SetLayer(self.nextLayerValue)
    self.nextLayerValue = self.nextLayerValue + 1
    
    local childObject = GetOwningGUIObject(childItem)
    
    if childObject == self then
        error("Child items of GUILayout objects must be owned by other GUIObjects -- they cannot be owned by the GUILayout.")
    end
    
    -- Listen for certain child property changes, so layout can update accordingly.
    if childObject then
        
        local propertiesList = GetRelevantChildPropertyNamesHelper(self)
        for i=1, #propertiesList do
            if childObject:GetPropertyExists(propertiesList[i]) then
                self:HookEvent(childObject, "On"..propertiesList[i].."Changed", SetNeedsArrangeInternal)
            end
        end
        
    end
    
    SetNeedsArrangeInternal(self)
    
end

local function OnChildRemoved(self, childItem)
    
    -- Stop listening to events from this object.
    local childObject = GetOwningGUIObject(childItem)
    if childObject then
    
        local propertiesList = GetRelevantChildPropertyNamesHelper(self)
        for i=1, #propertiesList do
            if childObject:GetPropertyExists(propertiesList[i]) then
                self:UnHookEvent(childObject, "On"..propertiesList[i].."Changed", SetNeedsArrangeInternal)
            end
        end
        
    end
    
    SetNeedsArrangeInternal(self)
end

function GUILayout:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PROFILE("GUILayout:Initialize")
    
    RequireType({"number", "nil"}, params.frontPadding, "params.frontPadding", errorDepth)
    RequireType({"number", "nil"}, params.backPadding, "params.backPadding", errorDepth)
    RequireType({"boolean", "nil"}, params.autoArrange, "params.autoArrange", errorDepth)
    RequireType({"boolean", "nil"}, params.deferredArrange, "params.deferredArrange", errorDepth)
    
    AbstractClassCheck(self, "GUILayout", errorDepth)
    RequireMethod(self, "_Arrange", errorDepth)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    -- To maintain a consistent child order, assign a unique layer number to each child added so
    -- children always sort in the same way.
    self.nextLayerValue = 0
    
    self:HookEvent(self, "OnChildAdded", OnChildAdded)
    self:HookEvent(self, "OnChildRemoved", OnChildRemoved)
    
    -- Automatically invalidate the layout when any of these properties change.
    local propertiesList = GetRelevantPropertyNamesHelper(self)
    for i=1, #propertiesList do
        self:HookEvent(self, "On"..propertiesList[i].."Changed", SetNeedsArrangeInternal)
    end
    
    -- Keep track of whether or not the arrangment is out of date and needs a call to Arrange().
    self.needsArrange = false
    
    -- Whenever the "AutoArrange" property is switched on, see if an arrangement is needed.
    self:HookEvent(self, "OnAutoArrangeChanged", OnAutoArrangeChanged)
    
    if params.frontPadding then
        self:SetFrontPadding(params.frontPadding)
    end
    
    if params.backPadding then
        self:SetBackPadding(params.backPadding)
    end
    
    if params.autoArrange ~= nil then
        self:SetAutoArrange(params.autoArrange)
    end
    
    if params.deferredArrange then
        self.deferredArrange = true
    end
    
end

-- Called once when adding the first child object.  Collects a list of property names that, when
-- changed on the child, should result in the layout being re-arranged.
function GUILayout.GetRelevantChildPropertyNames(nameTable)
    table.insert(nameTable, "Size")
    table.insert(nameTable, "Scale")
    table.insert(nameTable, "Expansion")
    table.insert(nameTable, "Layer")
    table.insert(nameTable, "Visible")
    
    -- Not necessary, but good to have to avoid issues where the layout has to be invalidated one
    -- more time to make it look correct.  Eg. If you call item:SetSize() _then_ call
    -- item:AlignLeft(), the items will appear in the wrong place because the anchor change by
    -- the layout is overridden.  Would be more efficient to just add some kind of constraint to
    -- items that belong to layouts... but such a mechanism doesn't exist yet, so just do this
    -- instead... can always be added later if needed for performance.
    table.insert(nameTable, "Anchor")
    table.insert(nameTable, "HotSpot")
end

-- Called once when initializing the first instance of this class.  Collects a list of property
-- names that, when changed for the layout, should result in the layout being re-arranged.
function GUILayout.GetRelevantPropertyNames(nameTable)
    table.insert(nameTable, "FrontPadding")
    table.insert(nameTable, "BackPadding")
end

-- Manually set that this layout is out of date and should be arranged again.  Use if something
-- other than child size, child expansion, or a child being added/removed is cause for updating
-- arrangement.
function GUILayout:SetNeedsArrange(state)
    SetNeedsArrangeInternal(self, state)
end

-- Manually trigger a rearrangement of the child objects.  Typically not necessary if AutoArrange
-- is enabled, but can be more efficient to turn off AutoArrange and call this manually.
function GUILayout:ArrangeNow()
    ArrangeInternal(self)
end
