-- ======= Copyright (c) 2016, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIKeybind.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Displays the keybind for a command on screen.  Should not be used directly, but instead
--    created via the KeybindDisplayManager.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'KeybindPanel' (GUIScript)

KeybindPanel.kDefaultShader = 'shaders/GUIBasic.surface_shader'

KeybindPanel.kMouseButtonsShader = 'shaders/GUIMouseButtonsIcon.surface_shader'
KeybindPanel.kMouseButtonsTexture = PrecacheAsset("ui/mouse_buttons.dds")
KeybindPanel.kMouseButtonsTextureSize = Vector(197,277,0) --image size, before the scaling
KeybindPanel.kMouseButtonsBaseScale = 0.3333

KeybindPanel.kMouseWheelShader = 'shaders/GUIMouseWheelIcon.surface_shader'
KeybindPanel.kMouseWheelTexture = PrecacheAsset('ui/mouse_wheel.dds')
KeybindPanel.kMouseWheelTextureSize = Vector(278,290,0) --image size, before the scaling
KeybindPanel.kMouseWheelBaseScale = 0.3333

KeybindPanel.kKeyShader = "shaders/GUIGreyToAlpha.surface_shader"
KeybindPanel.kKeyTextureSmall = PrecacheAsset("ui/keyboard_key_small.dds")
KeybindPanel.kKeyTextureSmallSize = Vector(278,290,0)
KeybindPanel.kKeyTextureMedium = PrecacheAsset("ui/keyboard_key_med.dds")
KeybindPanel.kKeyTextureMediumSize = Vector(556,290,0)
KeybindPanel.kKeyTextureLarge = PrecacheAsset("ui/keyboard_key_large.dds")
KeybindPanel.kKeyTextureLargeSize = Vector(834,290,0)
KeybindPanel.kKeyBaseScale = 0.25

-- measurements in px based on a 1920x1080 resolution
KeybindPanel.kRightEdge_CenterOffset = 320 --from right side of screen
KeybindPanel.kMargin = 20 -- from above position, give icons (right-aligned) and text(left-aligned) this much margin
KeybindPanel.kRowHeight = 120 -- space between rows of bindings
KeybindPanel.kFirstRowOffset = 360 --from top of screen
KeybindPanel.kMiscBoxHeight = 50 --Height of box drawn around keybind names we don't have icons for
KeybindPanel.kMiscBoxMargin = 15 --Margin of box width on left and right around keybind name
KeybindPanel.kMiscBoxTextNudgeVertical = 6 --Nudge text this much downwards to get it to be centered in the drawn rectangle.

KeybindPanel.kSmallKeyWidth = 30 --If the size of the keybind text exceeds this, we need to try a bigger key
KeybindPanel.kMediumKeyWidth = 100 --If the text is bigger than this, go to the largest key.
KeybindPanel.kKeyTextYOffset = 6 --nudge text this much vertically to get it to sit on the key icon just right.
KeybindPanel.kLargeKeyExceptions = {'Space'} --These keys automatically get the largest key.

KeybindPanel.kShadowOffset = Vector(2, 2, 0) -- offset of the shadow version of each element

local kTextColor = Color(148/255, 207/255, 1, 1)
local kShadowColor = Color(0,0,0,1)

local kTextColorTransparent = Color(kTextColor.r, kTextColor.g, kTextColor.b, 0.5)
local kShadowColorTransparent = Color(0,0,0,0.5)

local kAnimationTime = 0.5

-- eases in, with f(0)=1, f(1)=0
local function InterpIn(t)
    return (1-t) / (2^(5*t))
end

-- accelerates out, with f(0)=0, f(1)=1
local function InterpOut(t)
    return t / (2^((t * -5) + 5))
end


local function GetFontForScale()
    if GUIScaleHeight(1) >= 0.7 then
        return Fonts.kAgencyFB_Medium
    elseif GUIScaleHeight(1) >= 0.45 then
        return Fonts.kAgencyFB_Small
    else
        return Fonts.kAgencyFB_Tiny
    end
end


function KeybindPanel:Initialize()
    
    self.updateInterval = 1/60 --60fps
    
    self.icon = GUIManager:CreateGraphicItem()
    self.icon:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.icon:SetIsVisible(false)
    self.icon:SetColor(kTextColor)
    self.icon:SetLayer(kGUILayerPlayerHUDForeground1)
    
    self.iconShadow = GUIManager:CreateGraphicItem()
    self.iconShadow:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.iconShadow:SetIsVisible(false)
    self.iconShadow:SetColor(kShadowColor)
    self.iconShadow:SetLayer(kGUILayerPlayerHUDBackground)
    
    self.iconText = GUIManager:CreateGraphicItem()
    self.iconText:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.iconText:SetIsVisible(false)
    self.iconText:SetColor(kTextColor)
    self.iconText:SetLayer(kGUILayerPlayerHUDForeground2)
    self.iconText:SetOptionFlag(GUIItem.ManageRender)
    self.iconText:SetFontName(GetFontForScale())
    self.iconText:SetTextAlignmentX(GUIItem.Align_Center)
    self.iconText:SetTextAlignmentY(GUIItem.Align_Center)
    
    self.iconTextShadow = GUIManager:CreateGraphicItem()
    self.iconTextShadow:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.iconTextShadow:SetIsVisible(false)
    self.iconTextShadow:SetColor(kShadowColor)
    self.iconTextShadow:SetLayer(kGUILayerPlayerHUDBackground)
    self.iconTextShadow:SetOptionFlag(GUIItem.ManageRender)
    self.iconTextShadow:SetFontName(GetFontForScale())
    self.iconTextShadow:SetTextAlignmentX(GUIItem.Align_Center)
    self.iconTextShadow:SetTextAlignmentY(GUIItem.Align_Center)
    
    self.actionText = GUIManager:CreateGraphicItem()
    self.actionText:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.actionText:SetIsVisible(false)
    self.actionText:SetColor(kTextColor)
    self.actionText:SetLayer(kGUILayerPlayerHUDForeground1)
    self.actionText:SetOptionFlag(GUIItem.ManageRender)
    self.actionText:SetFontName(GetFontForScale())
    self.actionText:SetTextAlignmentX(GUIItem.Align_Min)
    self.actionText:SetTextAlignmentY(GUIItem.Align_Center)
    
    self.actionTextShadow = GUIManager:CreateGraphicItem()
    self.actionTextShadow:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.actionTextShadow:SetIsVisible(false)
    self.actionTextShadow:SetColor(kShadowColor)
    self.actionTextShadow:SetLayer(kGUILayerPlayerHUDBackground)
    self.actionTextShadow:SetOptionFlag(GUIItem.ManageRender)
    self.actionTextShadow:SetFontName(GetFontForScale())
    self.actionTextShadow:SetTextAlignmentX(GUIItem.Align_Min)
    self.actionTextShadow:SetTextAlignmentY(GUIItem.Align_Center)
    
end


function KeybindPanel:Uninitialize()
    
    GUI.DestroyItem(self.icon)
    GUI.DestroyItem(self.iconShadow)
    GUI.DestroyItem(self.iconText)
    GUI.DestroyItem(self.iconTextShadow)
    GUI.DestroyItem(self.actionText)
    GUI.DestroyItem(self.actionTextShadow)
    self.icon = nil
    self.iconShadow = nil
    self.iconText = nil
    self.iconTextShadow = nil
    self.actionText = nil
    self.actionTextShadow = nil
    
    self.control = nil
    self.neatName = nil
    self.actionDesc = nil
    self.keyIcon = nil
    self.icon_is_drawn = nil
    
end


function KeybindPanel:UpdateKey(keyIcon, neatName)
    
    -- called when the user has reconfigured their keybinds... need to ensure this display is up to date!
    local control = self.control
    local actionDesc = self.actionDesc
    self:Uninitialize()
    self:Initialize()
    self:SetKeybind(control, keyIcon, neatName, actionDesc)
    self:UpdateLayout()
    self:SetVisibilities(true)
    
end


local function DrawRectangle(item, corner1, corner2, color)
    
    item:AddLine(Vector(corner1.x, corner1.y, 0), Vector(corner2.x, corner1.y, 0), color)
    item:AddLine(Vector(corner2.x, corner1.y, 0), Vector(corner2.x, corner2.y, 0), color)
    item:AddLine(Vector(corner2.x, corner2.y, 0), Vector(corner1.x, corner2.y, 0), color)
    item:AddLine(Vector(corner1.x, corner2.y, 0), Vector(corner1.x, corner1.y, 0), color)
    
end


local function DrawRectangleWithThickness(item, corner1, corner2, color, edgeColor, thickness)
    
    local x1 = math.min(corner1.x, corner2.x)
    local y1 = math.min(corner1.y, corner2.y)
    local x2 = math.max(corner1.x, corner2.x)
    local y2 = math.max(corner1.y, corner2.y)
    local offset = math.ceil(thickness/2)
    
    -- draw rectangle shadow
    local shadowOffset = GUIScaleHeight(KeybindPanel.kShadowOffset)
    for i=1, thickness do
        local c = kShadowColor
        local edgeShift = i-offset
        if thickness > 2 and (i==1 or i==thickness) then
            c = kShadowColorTransparent
        end
        DrawRectangle(item, Vector(x1+edgeShift, y1+edgeShift,0) + shadowOffset, Vector(x2-edgeShift, y2-edgeShift, 0) + shadowOffset, c)
    end
    
    -- draw colored rectangle
    for i=1, thickness do
        local c = color
        local edgeShift = i-offset
        if thickness > 2 and (i==1 or i==thickness) then
            c = edgeColor
        end
        DrawRectangle(item, Vector(x1+edgeShift,y1+edgeShift,0), Vector(x2-edgeShift,y2-edgeShift,0), c)
    end
    
end


local function CalcReverseScale(value)
    return value * (1080 / Client.GetScreenHeight())
end


local function DrawMiscButtonRectangle(self)
    
    self.icon:SetShader(KeybindPanel.kDefaultShader)
    self.icon:SetTexture(nil)
    self.icon:SetOptionFlag(GUIItem.ManageRender)
    local iconWidth = self.iconText:GetTextWidth(self.neatName) + GUIScaleHeight(KeybindPanel.kMiscBoxMargin * 2)
    local iconHeight = GUIScaleHeight(KeybindPanel.kMiscBoxHeight)
    self.iconSize = CalcReverseScale(Vector( iconWidth, iconHeight, 0)) --iconSize value is designed to be used as the un-scaled values
    self.icon_is_drawn = true
    self.icon:ClearLines()
    if self.color then
        DrawRectangleWithThickness(self.icon, Vector(0,0,0), Vector( iconWidth, iconHeight, 0), self.color, self.colorTransparent, math.ceil(GUIScaleHeight(3)))
    else
        DrawRectangleWithThickness(self.icon, Vector(0,0,0), Vector( iconWidth, iconHeight, 0), kTextColor, kTextColorTransparent, math.ceil(GUIScaleHeight(3)))
    end
    
end


function KeybindPanel:SetColor(color)
    
    self.color = color
    self.colorTransparent = Color(color.r, color.g, color.b, color.a * 0.5)
    self.icon:SetColor(self.color)
    self.iconText:SetColor(self.color)
    self.actionText:SetColor(self.color)
    self:UpdateLayout(self)
    
end


function KeybindPanel:SetParent(parent)
    self.parent_table = parent
end


function KeybindPanel:SetKeybind(control, keyIcon, neatName, action)
    
    self.control = control
    self.neatName = neatName
    self.actionDesc = action
    self.keyIcon = keyIcon
    
    if self.keyIcon == 'keyboard' then
        local found = false
        -- see if this key is an exception
        for i=1,#KeybindPanel.kLargeKeyExceptions do
            if KeybindPanel.kLargeKeyExceptions[i] == self.neatName then
                self.keyIcon = 'keyboard_large'
                found = true
                break
            end
        end
        
        if found == false then
            if self.iconText:GetTextWidth(self.neatName) > KeybindPanel.kSmallKeyWidth then
                if self.iconText:GetTextWidth(self.neatName) > KeybindPanel.kMediumKeyWidth then
                    self.keyIcon = 'keyboard_large'
                else
                    self.keyIcon = 'keyboard_medium'
                end
            else
                self.keyIcon = 'keyboard_small'
            end
        end
        
        self.icon:SetShader(KeybindPanel.kKeyShader)
        self.iconShadow:SetShader(KeybindPanel.kKeyShader)
        if self.keyIcon == 'keyboard_small' then
            self.icon:SetTexture(KeybindPanel.kKeyTextureSmall)
            self.iconShadow:SetTexture(KeybindPanel.kKeyTextureSmall)
            self.iconSize = KeybindPanel.kKeyTextureSmallSize * KeybindPanel.kKeyBaseScale
        elseif self.keyIcon == 'keyboard_medium' then
            self.icon:SetTexture(KeybindPanel.kKeyTextureMedium)
            self.iconShadow:SetTexture(KeybindPanel.kKeyTextureMedium)
            self.iconSize = KeybindPanel.kKeyTextureMediumSize * KeybindPanel.kKeyBaseScale
        elseif self.keyIcon == 'keyboard_large' then
            self.icon:SetTexture(KeybindPanel.kKeyTextureLarge)
            self.iconShadow:SetTexture(KeybindPanel.kKeyTextureLarge)
            self.iconSize = KeybindPanel.kKeyTextureLargeSize * KeybindPanel.kKeyBaseScale
        end
        self.iconText:SetText(neatName)
        self.iconTextShadow:SetText(neatName)
        self.actionText:SetText(self.actionDesc)
        self.actionTextShadow:SetText(self.actionDesc)
    
    elseif self.keyIcon == 'mouse_left' then
        self.icon:SetShader(KeybindPanel.kMouseButtonsShader)
        self.icon:SetFloatParameter("rIntensity",1.0)
        self.icon:SetFloatParameter("gIntensity",0.0)
        self.icon:SetFloatParameter("bIntensity",0.0)
        self.icon:SetTexture(KeybindPanel.kMouseButtonsTexture)
        self.iconShadow:SetShader(KeybindPanel.kMouseButtonsShader)
        self.iconShadow:SetFloatParameter("rIntensity",1.0)
        self.iconShadow:SetFloatParameter("gIntensity",0.0)
        self.iconShadow:SetFloatParameter("bIntensity",0.0)
        self.iconShadow:SetTexture(KeybindPanel.kMouseButtonsTexture)
        self.iconSize = KeybindPanel.kMouseButtonsTextureSize * KeybindPanel.kMouseButtonsBaseScale
        self.iconText:SetText('')
        self.iconTextShadow:SetText('')
        self.actionText:SetText(self.actionDesc)
        self.actionTextShadow:SetText(self.actionDesc)
    elseif self.keyIcon == 'mouse_right' then
        self.icon:SetShader(KeybindPanel.kMouseButtonsShader)
        self.icon:SetFloatParameter("rIntensity",0.0)
        self.icon:SetFloatParameter("gIntensity",1.0)
        self.icon:SetFloatParameter("bIntensity",0.0)
        self.icon:SetTexture(KeybindPanel.kMouseButtonsTexture)
        self.iconShadow:SetShader(KeybindPanel.kMouseButtonsShader)
        self.iconShadow:SetFloatParameter("rIntensity",0.0)
        self.iconShadow:SetFloatParameter("gIntensity",1.0)
        self.iconShadow:SetFloatParameter("bIntensity",0.0)
        self.iconShadow:SetTexture(KeybindPanel.kMouseButtonsTexture)
        self.iconSize = KeybindPanel.kMouseButtonsTextureSize * KeybindPanel.kMouseButtonsBaseScale
        self.iconText:SetText('')
        self.iconTextShadow:SetText('')
        self.actionText:SetText(self.actionDesc)
        self.actionTextShadow:SetText(self.actionDesc)
    elseif self.keyIcon == 'mouse_middle' then
        self.icon:SetShader(KeybindPanel.kMouseButtonsShader)
        self.icon:SetFloatParameter("rIntensity",0.0)
        self.icon:SetFloatParameter("gIntensity",0.0)
        self.icon:SetFloatParameter("bIntensity",1.0)
        self.icon:SetTexture(KeybindPanel.kMouseButtonsTexture)
        self.iconShadow:SetShader(KeybindPanel.kMouseButtonsShader)
        self.iconShadow:SetFloatParameter("rIntensity",0.0)
        self.iconShadow:SetFloatParameter("gIntensity",0.0)
        self.iconShadow:SetFloatParameter("bIntensity",1.0)
        self.iconShadow:SetTexture(KeybindPanel.kMouseButtonsTexture)
        self.iconSize = KeybindPanel.kMouseButtonsTextureSize * KeybindPanel.kMouseButtonsBaseScale
        self.iconText:SetText('')
        self.iconTextShadow:SetText('')
        self.actionText:SetText(self.actionDesc)
        self.actionTextShadow:SetText(self.actionDesc)
    elseif self.keyIcon == 'mouse_wheel_up' then
        self.icon:SetShader(KeybindPanel.kMouseWheelShader)
        self.icon:SetFloatParameter("rIntensity",1.0)
        self.icon:SetFloatParameter("gIntensity",0.0)
        self.icon:SetTexture(KeybindPanel.kMouseWheelTexture)
        self.iconShadow:SetShader(KeybindPanel.kMouseWheelShader)
        self.iconShadow:SetFloatParameter("rIntensity",1.0)
        self.iconShadow:SetFloatParameter("gIntensity",0.0)
        self.iconShadow:SetTexture(KeybindPanel.kMouseWheelTexture)
        self.iconSize = KeybindPanel.kMouseWheelTextureSize * KeybindPanel.kMouseWheelBaseScale
        self.iconText:SetText('')
        self.iconTextShadow:SetText('')
        self.actionText:SetText(self.actionDesc)
        self.actionTextShadow:SetText(self.actionDesc)
    elseif self.keyIcon == 'mouse_wheel_down' then
        self.icon:SetShader(KeybindPanel.kMouseWheelShader)
        self.icon:SetFloatParameter("rIntensity",0.0)
        self.icon:SetFloatParameter("gIntensity",1.0)
        self.icon:SetTexture(KeybindPanel.kMouseWheelTexture)
        self.iconShadow:SetShader(KeybindPanel.kMouseWheelShader)
        self.iconShadow:SetFloatParameter("rIntensity",0.0)
        self.iconShadow:SetFloatParameter("gIntensity",1.0)
        self.iconShadow:SetTexture(KeybindPanel.kMouseWheelTexture)
        self.iconSize = KeybindPanel.kMouseWheelTextureSize * KeybindPanel.kMouseWheelBaseScale
        self.iconText:SetText('')
        self.iconTextShadow:SetText('')
        self.actionText:SetText(self.actionDesc)
        self.actionTextShadow:SetText(self.actionDesc)
    else
        DrawMiscButtonRectangle(self)
        self.iconText:SetText(self.neatName)
        self.iconTextShadow:SetText(self.neatName)
        self.actionText:SetText(self.actionDesc)
        self.actionTextShadow:SetText(self.actionDesc)
    end
    
end


function KeybindPanel:SetVisibilitiesOverride(state)
    self.vis_override = state
    self:SetVisibilities(nil)
end


function KeybindPanel:SetVisibilities(state)
    
    if state ~= nil then
        self.vis = state
    end
    
    if self.vis_override ~= nil then
        self.icon:SetIsVisible(self.vis_override)
        self.iconShadow:SetIsVisible(self.vis_override)
        self.iconText:SetIsVisible(self.vis_override)
        self.iconTextShadow:SetIsVisible(self.vis_override)
        self.actionText:SetIsVisible(self.vis_override)
        self.actionTextShadow:SetIsVisible(self.vis_override)
    else
        self.icon:SetIsVisible(self.vis)
        self.iconShadow:SetIsVisible(self.vis)
        self.iconText:SetIsVisible(self.vis)
        self.iconTextShadow:SetIsVisible(self.vis)
        self.actionText:SetIsVisible(self.vis)
        self.actionTextShadow:SetIsVisible(self.vis)
    end
end


function KeybindPanel:AnimateIn()
    
    if self.anim_state == 'leaving' then
        self.interp = 1.0 - self.interp
        self.anim_start_time = Shared.GetTime() - (kAnimationTime * self.interp)
    elseif self.anim_state ~= 'arriving' and self.anim_state ~= 'in' then
        self.interp = 0.0
        self.anim_start_time = Shared.GetTime()
    end
    self.anim_state = 'arriving'
    self.do_destroy = nil
    self.callback = nil
    
    self:SetVisibilities(true)
    
end


function KeybindPanel:AnimateOut(finish_callback, do_destroy)
    
    if self.anim_state == 'arriving' then
        self.interp = 1.0 - self.interp
        self.anim_start_time = Shared.GetTime() - (kAnimationTime * self.interp)
    elseif self.anim_state ~= 'leaving' and self.anim_state ~= 'out' then
        self.interp = 0.0
        self.anim_start_time = Shared.GetTime()
    end
    self.anim_state = 'leaving'
    
    self:SetVisibilities(true)
    
    self.callback = finish_callback
    self.do_destroy = do_destroy
    
end


function KeybindPanel:OnResolutionChanged()
    
    self.iconText:SetFontName(GetFontForScale())
    self.iconTextShadow:SetFontName(GetFontForScale())
    self.actionText:SetFontName(GetFontForScale())
    self.actionTextShadow:SetFontName(GetFontForScale())
    self:UpdateLayout()
    
end


function KeybindPanel:SetIndex(index)
    self.rowIndex = index
end


-- is the control hard-coded into the game? (ie NOT a re-bindable control)
function KeybindPanel:GetIsLiteral()
    return self.isLiteral ~= true
end


function KeybindPanel:SetIsLiteral(state)
    self.isLiteral = (state == true)
end


function KeybindPanel:UpdateLayout()
    
    if not self.rowIndex then
        return
    end
    
    if self.icon_is_drawn then
        DrawMiscButtonRectangle(self)
    else
        self.icon:SetSize(GUIScaleHeight(self.iconSize))
        self.iconShadow:SetSize(GUIScaleHeight(self.iconSize))
    end
    
    local rowRoot = GUIScaleHeight(Vector( -KeybindPanel.kRightEdge_CenterOffset , (KeybindPanel.kFirstRowOffset + (KeybindPanel.kRowHeight * self.rowIndex)) , 0 ))
    local iconXOffset = GUIScaleHeight(-self.iconSize.x - KeybindPanel.kMargin)
    local iconYOffset = GUIScaleHeight((math.abs(KeybindPanel.kRowHeight - self.iconSize.y) / 2.0))
    local iconTextXOffset = GUIScaleHeight(-(self.iconSize.x/2) - KeybindPanel.kMargin)
    
    local iconTextYOffset
    if self.icon_is_drawn then
        iconTextYOffset = GUIScaleHeight(KeybindPanel.kRowHeight/2)
    else
        iconTextYOffset = GUIScaleHeight((KeybindPanel.kRowHeight/2) - KeybindPanel.kKeyTextYOffset)
    end
    
    local actionXOffset = GUIScaleHeight(KeybindPanel.kMargin)
    local actionYOffset = GUIScaleHeight(KeybindPanel.kRowHeight/2)
    
    local rowWidth = (rowRoot.x + iconXOffset) * -1
    local rootAnimXOffset = 0
    if self.anim_state == 'leaving' then
        rootAnimXOffset = rowWidth * InterpOut(self.interp)
    elseif self.anim_state == 'arriving' then
        rootAnimXOffset = rowWidth * InterpIn(self.interp)
    elseif self.anim_state == 'out' then
        rootAnimXOffset = rowWidth * 1.0
    end
    
    local shadowOffset = GUIScaleHeight(KeybindPanel.kShadowOffset)
    
    self.icon:SetPosition(rowRoot + Vector(rootAnimXOffset + iconXOffset,iconYOffset,0))
    self.iconShadow:SetPosition(rowRoot + Vector(rootAnimXOffset + iconXOffset,iconYOffset,0) + shadowOffset)
    self.iconText:SetPosition(rowRoot + Vector(rootAnimXOffset + iconTextXOffset,iconTextYOffset,0))
    self.iconTextShadow:SetPosition(rowRoot + Vector(rootAnimXOffset + iconTextXOffset,iconTextYOffset,0) + shadowOffset)
    self.actionText:SetPosition(rowRoot + Vector(rootAnimXOffset + actionXOffset,actionYOffset,0))
    self.actionTextShadow:SetPosition(rowRoot + Vector(rootAnimXOffset + actionXOffset,actionYOffset,0) + shadowOffset)
    
end


function KeybindPanel:Update(deltaTime)
    
    local now = Shared.GetTime()
    
    if self.anim_state == 'leaving' then
    
        self.interp = (now - self.anim_start_time) / kAnimationTime
        if self.interp >= 1.0 then
            self.anim_state = 'out'
            self.interp = 1.0
            if self.callback then
                self.callback()
            end
            if self.do_destroy then
                self:Uninitialize()
                GetGUIManager():DestroyGUIScript(self)
            end
        else
            self:UpdateLayout()
        end
        
    elseif self.anim_state == 'arriving' then
        
        self.interp = (now - self.anim_start_time) / kAnimationTime
        if self.interp >= 1.0 then
            self.anim_state = 'in'
            self.interp = 1.0
        end
        self:UpdateLayout()
        
    end
    
end


