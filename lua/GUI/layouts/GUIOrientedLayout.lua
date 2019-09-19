-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/layouts/GUIOrientedLayout.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    An abstract base class for object that will contain and arrange objects in a certain way with
--    a particular orientation in mind (eg horizontal or vertical).
--
--  Parameters (* = required)
--      autoArrange
--      backPadding
--      deferredArrange     If true, this layout will _not_ rearrange itself until the end of
--                          the frame.  Saves a lot of performance if it has a lot of objects to
--                          arrange and is updated frequently.  However, any side effects of
--                          _Arrange() will not be seen until the end of the frame.
--      frontPadding
--     *orientation         The orientation of the layout.  Expects either "horizontal" or
--                          "vertical".
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

Script.Load("lua/GUI/layouts/GUILayout.lua")

Script.Load("lua/GUI/wrappers/Oriented.lua")

---@class GUIOrientedLayout : GUILayout
---@field public GetMajorAxis function @From Oriented wrapper
---@field public GetMinorAxis function @From Oriented wrapper
---@field public GetOrientation function @From Oriented wrapper
local baseClass = GUILayout
baseClass = GetOrientedWrappedClass(baseClass)
class "GUIOrientedLayout" (baseClass)
