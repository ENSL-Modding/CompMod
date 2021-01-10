function Cyst:GetIsFlameableMultiplier(doer)
    if doer and doer.isa and doer:isa("Welder") then
        print("5x")
        return 5
    else
        return 7
    end
end
