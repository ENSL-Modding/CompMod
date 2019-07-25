-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\FancyImage.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Concrete image type of FancyElement.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/FancyElement.lua")

class 'FancyImage' (FancyElement)

local function DestroyItem(self)
    
    if self.item then
        GUI.DestroyItem(self.item)
        self.item = nil
    end
    
end

local function ValidateShader(self)
    
    if self.shader then
        self.item:SetShader(self.shader)
        
        for i=1, #self.params do
            local param = self.params[i]
            if type(param.value) == "string" then
                self.item:SetAdditionalTexture(param.name, param.value)
            elseif type(param.value) == "number" then
                self.item:SetFloatParameter(param.name, param.value)
            end
        end
        
        -- shader parameters that are always passed
        self.item:SetFloatParameter("rcpFrameX", 1.0 / self.item:GetSize().x)
        self.item:SetFloatParameter("rcpFrameY", 1.0 / self.item:GetSize().y)
        local _, scale = Fancy_Transform(Vector(0,0,0), 1.0, self:GetResizeMethod())
        self.item:SetFloatParameter("resScale", scale)
    end
    
    if self.pathChanged and self.path then
        self.item:SetTexture(self.path)
        self.pathChanged = false
    end
    
    if self.blendMode then
        self.item:SetBlendTechnique(self.blendMode)
    end
    
    self.item:SetColor(self.color)
    
end

local function ValidateItem(self)
    
    if not self.item then
        self.item = GUI.CreateItem()
    end
    
end

local function UpdateTransform(self)
    
    assert(self.item)
    
    local size = Vector(0,0,0)
    size.x = self.dimensions.x * self:GetAbsoluteScale().x
    size.y = self.dimensions.y * self:GetAbsoluteScale().y
    
    local position = Vector(0,0,0)
    position.x = (self:GetAbsolutePosition().x - (self.anchorPoint.x * self:GetAbsoluteParentScale().x))
    position.y = (self:GetAbsolutePosition().y - (self.anchorPoint.y * self:GetAbsoluteParentScale().y))
    
    local newPosition, newSize = Fancy_Transform(position, size, self:GetResizeMethod()) -- handles screen size adjustments.
    
    self.item:SetPosition(newPosition)
    self.item:SetSize(newSize)
    
    self.item:SetLayer(self.layer)
    
end

-- Implementing from FancyElement.

function FancyImage:GetDisplayedItem()
    
    return self.item
    
end

function FancyImage:UpdateItem()
    
    FancyElement.UpdateItem(self)
    
    if not self.path then
        -- should not be an image visible
        DestroyItem(self)
    else
        -- should be an image visible
        ValidateItem(self)
        UpdateTransform(self)
        self:UpdateHook(self)
        ValidateShader(self)
    end
    
end

function FancyImage:Initialize()
    
    FancyElement.Initialize(self)
    
    self.item = nil
    self.dimensions = nil
    self.path = nil
    self.pathChanged = false
    self.anchorPoint = Vector(0,0,0)
    
    self.shader = nil
    self.params = {}
    self.blendMode = nil
    self.color = Color(1,1,1,1)
    
    getmetatable(self).__tostring = FancyImage.ToString
    
end

function FancyImage:ToString()
    
    local str = FancyElement.ToString(self)
    str = str .. string.format("    item = %s\n    dimensions = %s\n    path = %s\n    pathChanged = %s\n    anchorPoint = %s\n    shader = %s\n    params = %s\n    changedParams = %s\n", self.item, self.dimensions, self.path, self.pathChanged, self.anchorPoint, self.shader, self.params, self.changedParams)
    return str
    
end

function FancyImage:Destroy()
    
    FancyElement.Destroy(self)
    
    self.path = nil
    DestroyItem(self)
    
end

function FancyImage:SetIsVisible(state)
    
    FancyElement.SetIsVisible(self, state)
    
    if self.item then
        self.item:SetIsVisible(state)
    end
    
end

-- FancyImage methods.

function FancyImage:SetImage(path, dimensions, anchorPoint)
    
    if path == self.path and dimensions == self.dimensions and anchorPoint == self.anchorPoint then
        return
    end
    
    self.path = path
    self.pathChanged = true
    
    self.dimensions = dimensions
    self.anchorPoint = anchorPoint
    
    self:UpdateItem(self)
    
end

function FancyImage:SetShader(shaderPath)
    
    if not shaderPath or self.shader == shaderPath then
        return
    end
    
    self.shader = shaderPath
    
    self:UpdateItem()
    
end

function FancyImage:SetShaderParameter(inputTable)
    
    -- invalid input
    if not inputTable or not inputTable.name or not inputTable.value then
        return
    end
    
    -- invalid type
    if not (type(inputTable.value) == "string" or type(inputTable.value) == "number") then
        Log("ERROR!  Only valid shader parameter types are 'string' and 'number'. (was %s)", type(value))
        return
    end
    
    local exists = false
    -- parameter name is already used
    if self.params[inputTable.name] then
        -- attempted to change type
        if type(self.params[self.params[inputTable.name]].value) ~= type(inputTable.value) then
            Log("ERROR!  Cannot change shader parameter type!  (input name = '%s')", inputTable.name)
            return
        end
        
        -- same value
        if self.params[self.params[inputTable.name]].value == inputTable.value then
            return
        end
        
        exists = true
    end
    
    if exists then
        self.params[self.params[inputTable.name]] = inputTable
    else
        self.params[#self.params + 1] = {name = inputTable.name, value = inputTable.value} -- list, to be used when actually adding
        self.params[inputTable.name] = #self.params -- dictionary, to check existence in constant time
    end
    
    self:UpdateItem()
    
end

local recognizedBlendModes = { ["default"] = GUIItem.Default, ["add"] = GUIItem.Add, ["multiply"] = GUIItem.Multiply }
function FancyImage:SetBlendMode(mode)
    
    -- not all images set the blend mode.
    if mode == nil then
        self.blendMode = GUIItem.Default
        return
    end
    
    if not recognizedBlendModes[mode] then
        Log("ERROR: Unrecognized blend mode '%s'.", mode)
    end
    
    self.blendMode = recognizedBlendModes[mode]
    
    self:UpdateItem()
    
end

function FancyImage:SetColor(color)
    
    self.color = color
    
    self:UpdateItem()
    
end

