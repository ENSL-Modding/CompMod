-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\menu\BigLink.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Because sometimes you just gotta stand out more...
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/Link.lua")

local kFontSize = 67

class 'BigLink' (Link)

function BigLink:Initialize()
    
    Link.Initialize(self)
    
    self:SetFontSize(kFontSize)
    
end

function BigLink:SetFontName(fontName)
    
    Link.SetFontName(self, fontName)
    
end