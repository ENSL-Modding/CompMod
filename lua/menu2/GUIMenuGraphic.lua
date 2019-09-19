-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/GUIMenuGraphic.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIObject with menu FX/themeing applied, intended for simple graphics.
--
--  Parameters (* = required)
--      defaultColor    The color of the graphic when not highlighted or disabled.  Defaults to
--                      MenuStyle.kLightGrey.
--      disabledColor   The color of the graphic when disabled.  Defaults to MenuStyle.kDarkGrey.
--      highlightColor  The color of the graphic when highlighted.  Defaults to
--                      MenuStyle.kHighlight.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")
Script.Load("lua/menu2/wrappers/MenuFX.lua")

---@class GUIMenuGraphic : GUIObject
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
---@field protected OnFXStateChangedOverride function @From MenuFX wrapper
local baseClass = GUIObject
baseClass = GetMenuFXWrappedClass(baseClass)
class "GUIMenuGraphic" (baseClass)
