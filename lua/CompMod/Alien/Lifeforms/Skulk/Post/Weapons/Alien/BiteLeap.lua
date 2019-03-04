function BiteLeap:GetMeleeBase()
    -- Width of box, height of box
    return 0.8, 1.1
end

local kRange = 1.52

CompMod:ReplaceLocal(BiteLeap.GetRange, "kRange", kRange)
CompMod:ReplaceLocal(BiteLeap.OnTag, "kRange", kRange)
