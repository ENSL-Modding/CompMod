if Server then
    local function AddWebCharge(self)
        return false
    end

    debug.setupvaluex(Web.OnCreate, "AddWebCharge", AddWebCharge)
end