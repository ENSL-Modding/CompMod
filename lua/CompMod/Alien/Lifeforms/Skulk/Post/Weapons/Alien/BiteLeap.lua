function BiteLeap:GetMeleeBase()
    -- Width of box, height of box
    return 0.7, 1
end

local kRange = 1.62

CompMod:ReplaceLocal(BiteLeap.GetRange, "kRange", kRange)
CompMod:ReplaceLocal(BiteLeap.OnTag, "kRange", kRange)
