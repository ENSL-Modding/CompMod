-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/GUIMenuText.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIText with menu FX/themeing applied.
--
--  Parameters (* = required)
--      font
--      fontFamily (only if font not defined)
--      fontSize (only if font not defined)
--      text
--      defaultColor    The color of the graphic when not highlighted or disabled.  Defaults to
--                      MenuStyle.kLightGrey.
--      disabledColor   The color of the graphic when disabled.  Defaults to MenuStyle.kDarkGrey.
--      highlightColor  The color of the graphic when highlighted.  Defaults to
--                      MenuStyle.kHighlight.
--
--  Properties:
--      FontFamily      Whether or not this object is currently being dragged by the user.
--      FontSize        Whether or not this object can be dragged by the user.
--
--  Events:
--      OnInternalFontChanged       Fires when the font file used internally (the REAL font file)
--                                  changes.  Typically not necessary except where knowing the
--                                  exact size of a text when rendered is crucial.
--      OnInternalFontScaleChanged  Fires when the scale applied to the internal text object
--                                  changes.  Typically not necessary except where knowing the
--                                  exact size of a text when rendered is crucial.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")
Script.Load("lua/menu2/wrappers/MenuFX.lua")

---@class GUIMenuText : GUIText
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
---@field protected OnFXStateChangedOverride function @From MenuFX wrapper
local baseClass = GUIText
baseClass = GetMenuFXWrappedClass(baseClass)
class "GUIMenuText" (baseClass)
