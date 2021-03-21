local GetAutomaticOrder = debug.getupvaluex(MAC.ProcessFollowAndWeldOrder, "GetAutomaticOrder", true)

local function FindSomethingToDo(self)    
    local target, orderType = GetAutomaticOrder(self)
	
    if target and orderType then
        if self.leashedPosition then
            local tooFarFromLeash = Vector(self.leashedPosition - target:GetOrigin()):GetLength() > 15
            if tooFarFromLeash then
                --DebugPrint("Strayed too far!")
                return false
            end
        else
            self.leashedPosition = GetHoverAt(self, self:GetOrigin())
            --DebugPrint("return position set "..ToString(self.leashedPosition))
        end
        self.autoReturning = false
        self.selfGivenAutomaticOrder = true
        return self:GiveOrder(orderType, target:GetId(), target:GetOrigin(), nil, true, true) ~= kTechId.None  
    elseif self.leashedPosition and not self.autoReturning then
        self.autoReturning = true
        self.selfGivenAutomaticOrder = true
        self:GiveOrder(kTechId.Move, nil, self.leashedPosition, nil, true, true)
        --DebugPrint("returning to "..ToString(self.leashedPosition))
    end
    
    return false
end

debug.setupvaluex(MAC.OnUpdate, "FindSomethingToDo", FindSomethingToDo)

local oldOnOrderGiven = MAC.OnOrderGiven
function MAC:OnOrderGiven(order)
    oldOnOrderGiven(self, order)

    if (not self.selfGivenAutomaticOrder) or self.autoReturning then
        self.leashedPosition = nil
        self.autoReturning = false
    end
    self.selfGivenAutomaticOrder = nil
end
